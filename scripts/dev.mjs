#!/usr/bin/env node

import { execFileSync, spawn } from "node:child_process";
import {
  closeSync,
  constants as fsConstants,
  copyFileSync,
  existsSync,
  mkdirSync,
  openSync,
  readFileSync,
  readdirSync,
  renameSync,
  statSync,
  writeFileSync,
} from "node:fs";
import http from "node:http";
import net from "node:net";
import { homedir } from "node:os";
import { basename, join, resolve } from "node:path";
import { createInterface } from "node:readline/promises";
import { parseEnv } from "node:util";

const STATE_DIRECTORY = join(
  process.env.XDG_STATE_HOME || join(homedir(), ".local", "state"),
  "dev-orchestrator",
);
const STATE_FILE = join(STATE_DIRECTORY, "state.json");
const FRONTDOOR_LOG = join(STATE_DIRECTORY, "frontdoor.log");
const FRONTDOOR_PORT = 3000;
const FIRST_APP_PORT = 4100;
const PORTLESS_PORT = 1355;
const DEFAULT_STARTUP_TIMEOUT_MS = 20_000;
const STARTUP_LOG_LINES = 30;
const SCRIPT_PATH = resolve(process.argv[1]);

mkdirSync(STATE_DIRECTORY, { recursive: true, mode: 0o700 });

const [command = "start", ...args] = process.argv.slice(2);

try {
  if (command === "__frontdoor") {
    await runFrontdoor();
  } else if (["start", "up"].includes(command)) {
    await startCurrentCheckout();
  } else if (["list", "ls"].includes(command)) {
    listRunning();
  } else if (["switch", "use"].includes(command)) {
    await switchCheckout(args.join(" "));
  } else if (["stop", "down"].includes(command)) {
    await stopCheckout(args);
  } else if (["log", "logs"].includes(command)) {
    showLogs(args.join(" "));
  } else if (["help", "--help", "-h"].includes(command)) {
    printHelp();
  } else {
    throw new Error(`Unknown command: ${command}`);
  }
} catch (error) {
  logError(error instanceof Error ? error.message : String(error));
  process.exitCode = 1;
}

async function startCurrentCheckout() {
  const startupTimeoutMs = positiveIntegerEnv(
    "DEV_STARTUP_TIMEOUT_MS",
    DEFAULT_STARTUP_TIMEOUT_MS,
  );
  await ensurePortlessProxy();
  const checkout = inspectCheckout(process.cwd());
  const state = cleanState(loadState());
  const existing = state.checkouts[checkout.id];

  if (existing && existing.services.every((service) => processIsAlive(service.pid))) {
    selectCheckout(state, existing);
    saveState(state);
    await ensureFrontdoor(state, existing);
    printSelected(existing, "Already running");
    return;
  }

  const usedPorts = new Set(
    Object.values(state.checkouts).flatMap((entry) => entry.services.map((service) => service.port)),
  );
  const services = [];
  const removeSignalHandlers = installStartupSignalHandlers(services);

  try {
    for (const service of checkout.services) {
      const port = await allocatePort(usedPorts);
      usedPorts.add(port);
      const routeName =
        checkout.services.length === 1
          ? checkout.projectName
          : `${service.name}.${checkout.projectName}`;
      const url = portlessUrl(routeName, service.directory);
      const environment = serviceEnvironment(checkout, service, port, url, services);
      const logFile = join(STATE_DIRECTORY, `${safeId(checkout.id)}-${slug(service.name)}.log`);
      const pid = spawnService(checkout, service, routeName, port, environment, logFile);
      const started = { name: service.name, port, pid, url, logFile };
      services.push(started);

      log(
        `starting ${service.name}; waiting up to ${formatDuration(startupTimeoutMs)} for port ${port}`,
      );
      if (!(await waitForPort(port, startupTimeoutMs))) {
        throw startupError(service.name, port, logFile, startupTimeoutMs);
      }
    }
  } catch (error) {
    await cleanupServices(services);
    throw error;
  } finally {
    removeSignalHandlers();
  }

  const entry = {
    ...checkout,
    services,
    startedAt: new Date().toISOString(),
  };
  state.checkouts[checkout.id] = entry;
  selectCheckout(state, entry);
  saveState(state);
  await ensureFrontdoor(state, entry);
  printSelected(entry, "Started");
}

function inspectCheckout(directory) {
  const root = git(directory, ["rev-parse", "--show-toplevel"]);
  if (!root) throw new Error("Run dev from inside a Git repository.");

  const rootPackage = readJson(join(root, "package.json"));
  const primaryRoot = primaryWorktree(root);
  const projectName = slug(basename(root));
  const branch = git(root, ["branch", "--show-current"]) || "detached";
  const commonDirectory = git(root, ["rev-parse", "--git-common-dir"]);
  const linkedWorktree = commonDirectory !== ".git";
  const workspaceServices = discoverWorkspaceServices(root, primaryRoot);
  const services = workspaceServices.length
    ? workspaceServices
    : [inspectService(root, primaryRoot, ".", rootPackage)];
  const frontdoor = services.some((service) =>
    service.envFiles.some((file) => envHasKey(file, "OAUTH2_CALLBACK_URL")),
  );

  return {
    id: root,
    root,
    primaryRoot,
    projectName,
    label: linkedWorktree ? `${basename(root)} (${branch})` : basename(root),
    branch,
    linkedWorktree,
    packageManager: packageManager(rootPackage),
    frontdoor,
    services,
  };
}

function discoverWorkspaceServices(root, primaryRoot) {
  const appsDirectory = join(root, "apps");
  if (!existsSync(appsDirectory)) return [];

  return directories(appsDirectory)
    .map((name) => {
      const directory = join(appsDirectory, name);
      const packageFile = join(directory, "package.json");
      if (!existsSync(packageFile)) return undefined;
      return inspectService(directory, join(primaryRoot, "apps", name), `apps/${name}`, readJson(packageFile));
    })
    .filter((service) => service?.devScript);
}

function inspectService(directory, primaryDirectory, path, packageJson) {
  const envFiles = [".env", ".env.local"]
    .map((name) => {
      const localFile = join(directory, name);
      const primaryFile = join(primaryDirectory, name);
      if (existsSync(localFile)) return localFile;
      if (existsSync(primaryFile)) {
        try {
          copyFileSync(primaryFile, localFile, fsConstants.COPYFILE_EXCL);
          log(`copied ${shortHome(primaryFile)} → ${shortHome(localFile)}`);
        } catch (error) {
          if (!(error instanceof Error) || error.code !== "EEXIST") throw error;
        }
        return localFile;
      }
      return undefined;
    })
    .filter(Boolean);

  return {
    name: packageJson.name || basename(directory),
    path,
    directory,
    packageJson,
    devScript: packageJson.scripts?.dev,
    envFiles,
  };
}

function serviceEnvironment(checkout, service, port, url, startedServices) {
  const loaded = Object.assign({}, ...service.envFiles.map(loadEnv));
  const environment = {
    ...process.env,
    ...loaded,
    PORT: String(port),
    PORTLESS_APP_PORT: String(port),
  };

  if (checkout.frontdoor) {
    environment.OAUTH2_CALLBACK_URL = `http://localhost:${FRONTDOOR_PORT}/auth/callback`;
  }

  if (checkout.services.length === 1) {
    if (service.packageJson.dependencies?.["next-auth"]?.startsWith("^4")) {
      environment.NEXTAUTH_URL = url;
    }
    if (Object.hasOwn(loaded, "NEXT_PUBLIC_APP_URL")) {
      environment.NEXT_PUBLIC_APP_URL = url;
    }
  }

  const api = startedServices.find((candidate) => candidate.name === "api");
  if (service.name === "web" && api) {
    environment.API_URL = `http://127.0.0.1:${api.port}`;
  }

  return environment;
}

function spawnService(checkout, service, routeName, port, environment, logFile) {
  const command = developmentCommand(checkout.packageManager, service);
  const log = openSync(logFile, "a", 0o600);
  const child = spawn(
    "portless",
    [
      "run",
      "--name",
      routeName,
      "--app-port",
      String(port),
      "mise",
      "-C",
      service.directory,
      "exec",
      "--",
      ...command,
    ],
    {
      cwd: service.directory,
      env: environment,
      detached: true,
      stdio: ["ignore", log, log],
    },
  );
  closeSync(log);
  child.unref();
  return child.pid;
}

function developmentCommand(manager, service) {
  if (!service.devScript) throw new Error(`${service.path} has no dev script.`);

  if (/^next dev\b/.test(service.devScript) && /(?:^|\s)(?:-p|--port)(?:\s|=)/.test(service.devScript)) {
    const tokens = service.devScript.split(/\s+/);
    const withoutPort = [];
    for (let index = 0; index < tokens.length; index += 1) {
      if (["-p", "--port"].includes(tokens[index])) {
        index += 1;
      } else if (!tokens[index].startsWith("--port=")) {
        withoutPort.push(tokens[index]);
      }
    }
    return manager === "pnpm" ? ["pnpm", "exec", ...withoutPort] : ["npx", ...withoutPort];
  }

  if (manager === "pnpm") return ["pnpm", "run", "dev"];
  if (manager === "bun") return ["bun", "run", "dev"];
  if (manager === "yarn") return ["yarn", "run", "dev"];
  return ["npm", "run", "dev"];
}

function listRunning() {
  const state = cleanState(loadState());
  saveState(state);
  const entries = Object.values(state.checkouts);
  if (!entries.length) {
    log("nothing is running");
    return;
  }

  for (const entry of entries) {
    const marker = state.activeId === entry.id ? "*" : " ";
    console.log(`${marker} ${entry.label}`);
    for (const service of entry.services) {
      console.log(`    ${service.name}: ${service.url} → :${service.port}`);
    }
    if (entry.frontdoor && state.frontdoors[String(FRONTDOOR_PORT)] === entry.id) {
      console.log(`    front door: http://localhost:${FRONTDOOR_PORT}`);
    }
  }
}

async function switchCheckout(query) {
  const state = cleanState(loadState());
  const entries = Object.values(state.checkouts);
  if (!entries.length) throw new Error("Nothing is running. Run dev inside a project first.");
  const entry = await chooseEntry(entries, query);
  if (!entry) return;
  selectCheckout(state, entry);
  saveState(state);
  await ensureFrontdoor(state, entry);
  printSelected(entry, "Selected");
}

async function stopCheckout(args) {
  const state = cleanState(loadState());
  const entries = Object.values(state.checkouts);

  if (args.includes("--all")) {
    await stopAllCheckouts(state, entries);
    return;
  }

  const query = args.filter((arg) => !arg.startsWith("-")).join(" ");
  let entry;

  if (query) {
    entry = matchEntry(entries, query);
  } else {
    const root = git(process.cwd(), ["rev-parse", "--show-toplevel"]);
    entry = state.checkouts[root] || state.checkouts[state.activeId];
  }

  if (!entry) {
    if (entries.length === 0) {
      await stopUnusedInfrastructure(state);
      saveState(state);
      log("nothing is running");
      return;
    }
    throw new Error("No matching running checkout.");
  }

  await cleanupServices(entry.services, 5_000);

  delete state.checkouts[entry.id];
  if (state.activeId === entry.id) state.activeId = undefined;
  for (const [port, id] of Object.entries(state.frontdoors)) {
    if (id === entry.id) delete state.frontdoors[port];
  }
  await stopUnusedInfrastructure(state);
  saveState(state);
  log(`stopped ${entry.label}`);
}

async function stopAllCheckouts(state, entries) {
  if (!entries.length) {
    await stopUnusedInfrastructure(state);
    saveState(state);
    log("nothing is running");
    return;
  }

  await cleanupServices(
    entries.flatMap((entry) => entry.services),
    5_000,
  );

  state.checkouts = {};
  state.activeId = undefined;
  state.frontdoors = {};
  await stopUnusedInfrastructure(state);
  saveState(state);
  log(`stopped ${entries.length} checkout${entries.length === 1 ? "" : "s"}`);
}

async function stopUnusedInfrastructure(state) {
  const remaining = Object.values(state.checkouts);
  const frontdoorCheckouts = remaining.filter((entry) => entry.frontdoor);

  if (frontdoorCheckouts.length) {
    const selected = state.frontdoors[String(FRONTDOOR_PORT)];
    if (!frontdoorCheckouts.some((entry) => entry.id === selected)) {
      state.frontdoors[String(FRONTDOOR_PORT)] = frontdoorCheckouts[0].id;
    }
  } else {
    delete state.frontdoors[String(FRONTDOOR_PORT)];
    if (state.frontdoorPid && processIsAlive(state.frontdoorPid)) {
      terminateProcessGroup(state.frontdoorPid);
      await waitForProcessExit([state.frontdoorPid], 2_000);
      if (processIsAlive(state.frontdoorPid)) {
        terminateProcessGroup(state.frontdoorPid, "SIGKILL");
      }
    }
    delete state.frontdoorPid;
  }

  if (remaining.length === 0 && (await portIsOpen(PORTLESS_PORT))) {
    try {
      execFileSync("portless", ["proxy", "stop", "-p", String(PORTLESS_PORT)], {
        stdio: "ignore",
      });
    } catch {
      // Retry on the next invocation.
    }
  }
}

function showLogs(query) {
  const state = cleanState(loadState());
  const entries = Object.values(state.checkouts);
  const root = git(process.cwd(), ["rev-parse", "--show-toplevel"]);
  const entry = query
    ? matchEntry(entries, query)
    : state.checkouts[root] || state.checkouts[state.activeId];
  if (!entry) throw new Error("No matching running checkout.");

  log(`following ${entry.label} logs (Ctrl-C to stop)`);
  const labelWidth = Math.max(...entry.services.map((service) => service.name.length));

  for (const service of entry.services) {
    const prefix = `${service.name.padEnd(labelWidth)} | `;
    const child = spawn("tail", ["-n", "100", "-f", service.logFile], {
      stdio: ["ignore", "pipe", "pipe"],
    });
    pipeWithPrefix(child.stdout, process.stdout, prefix);
    pipeWithPrefix(child.stderr, process.stderr, prefix);
    child.on("error", (error) => {
      console.error(`${prefix}error: could not follow logs: ${error.message}`);
      process.exitCode = 1;
    });
    child.on("exit", (code) => {
      if (code) process.exitCode = code;
    });
  }
}

function pipeWithPrefix(input, output, prefix) {
  let pending = "";
  input.setEncoding("utf8");
  input.on("data", (chunk) => {
    pending += chunk;
    let newline;
    while ((newline = pending.indexOf("\n")) !== -1) {
      output.write(`${prefix}${pending.slice(0, newline + 1)}`);
      pending = pending.slice(newline + 1);
    }
  });
  input.on("end", () => {
    if (pending) output.write(`${prefix}${pending}\n`);
  });
}

async function chooseEntry(entries, query) {
  if (query) return matchEntry(entries, query);
  if (!process.stdin.isTTY) throw new Error("Pass a checkout name when input is not interactive.");

  entries.forEach((entry, index) => console.log(`${index + 1}. ${entry.label}`));
  const input = createInterface({ input: process.stdin, output: process.stdout });
  const answer = (await input.question("Select> ")).trim();
  input.close();
  const index = Number(answer) - 1;
  return entries[index] || matchEntry(entries, answer);
}

function matchEntry(entries, query) {
  const lowered = query.toLowerCase();
  const matches = entries.filter((entry) =>
    `${entry.label} ${entry.branch} ${entry.root}`.toLowerCase().includes(lowered),
  );
  if (matches.length !== 1) {
    throw new Error(matches.length ? `Ambiguous checkout: ${query}` : `Checkout not found: ${query}`);
  }
  return matches[0];
}

function selectCheckout(state, entry) {
  state.activeId = entry.id;
  if (entry.frontdoor) state.frontdoors[String(FRONTDOOR_PORT)] = entry.id;
}

async function ensureFrontdoor(state, entry) {
  if (!entry.frontdoor) return;
  if (state.frontdoorPid && processIsAlive(state.frontdoorPid)) return;
  if (await portIsOpen(FRONTDOOR_PORT)) {
    throw new Error(`Port ${FRONTDOOR_PORT} is already in use by another process.`);
  }

  const log = openSync(FRONTDOOR_LOG, "a", 0o600);
  const child = spawn(process.execPath, [SCRIPT_PATH, "__frontdoor"], {
    detached: true,
    stdio: ["ignore", log, log],
  });
  closeSync(log);
  child.unref();
  state.frontdoorPid = child.pid;
  saveState(state);
  if (!(await waitForPort(FRONTDOOR_PORT, 5_000))) {
    throw new Error(`The front door failed to start. See ${shortHome(FRONTDOOR_LOG)}`);
  }
}

async function runFrontdoor() {
  const server = http.createServer((request, response) => {
    const target = activeFrontdoorTarget();
    if (!target) {
      response.writeHead(503, { "Content-Type": "text/plain; charset=utf-8" });
      response.end("No front-door checkout is selected. Run: dev switch\n");
      return;
    }

    const upstream = http.request(
      {
        hostname: "127.0.0.1",
        port: target.port,
        method: request.method,
        path: request.url,
        headers: {
          ...request.headers,
          host: `localhost:${FRONTDOOR_PORT}`,
          "x-forwarded-host": `localhost:${FRONTDOOR_PORT}`,
          "x-forwarded-proto": "http",
        },
      },
      (upstreamResponse) => {
        response.writeHead(upstreamResponse.statusCode || 502, upstreamResponse.headers);
        upstreamResponse.pipe(response);
      },
    );
    upstream.on("error", (error) => {
      if (!response.headersSent) response.writeHead(502, { "Content-Type": "text/plain" });
      response.end(`Selected checkout is unavailable: ${error.message}\n`);
    });
    request.pipe(upstream);
  });

  server.on("upgrade", (request, socket, head) => {
    const target = activeFrontdoorTarget();
    if (!target) return socket.destroy();
    const upstream = net.connect(target.port, "127.0.0.1", () => {
      let headers = `${request.method} ${request.url} HTTP/${request.httpVersion}\r\n`;
      for (let index = 0; index < request.rawHeaders.length; index += 2) {
        const name = request.rawHeaders[index];
        const value = name.toLowerCase() === "host" ? `localhost:${FRONTDOOR_PORT}` : request.rawHeaders[index + 1];
        headers += `${name}: ${value}\r\n`;
      }
      upstream.write(`${headers}\r\n`);
      if (head.length) upstream.write(head);
      socket.pipe(upstream).pipe(socket);
    });
    upstream.on("error", () => socket.destroy());
  });

  server.listen(FRONTDOOR_PORT, "127.0.0.1");
}

function activeFrontdoorTarget() {
  const state = cleanState(loadState());
  const id = state.frontdoors[String(FRONTDOOR_PORT)];
  const entry = state.checkouts[id];
  if (!entry) return undefined;
  return entry.services.find((service) => service.name === "web") || entry.services[0];
}

async function ensurePortlessProxy() {
  if (await portIsOpen(PORTLESS_PORT)) return;
  execFileSync("portless", ["proxy", "start", "--no-tls", "-p", String(PORTLESS_PORT)], {
    stdio: "inherit",
  });
}

function prunePortless() {
  try {
    execFileSync("portless", ["prune"], { stdio: "ignore" });
  } catch {
    // Best-effort cleanup; retry on the next invocation.
  }
}

function portlessUrl(name, cwd) {
  return execFileSync("portless", ["get", name], { cwd, encoding: "utf8" }).trim();
}

async function allocatePort(usedPorts) {
  for (let port = FIRST_APP_PORT; port < 50_000; port += 1) {
    if (!usedPorts.has(port) && !(await portIsOpen(port))) return port;
  }
  throw new Error("No free development port found.");
}

function waitForPort(port, timeoutMs) {
  const deadline = Date.now() + timeoutMs;
  return new Promise((resolvePromise) => {
    const attempt = () => {
      const socket = net.connect(port, "127.0.0.1");
      socket.once("connect", () => {
        socket.destroy();
        resolvePromise(true);
      });
      socket.once("error", () => {
        socket.destroy();
        if (Date.now() >= deadline) resolvePromise(false);
        else setTimeout(attempt, 150);
      });
    };
    attempt();
  });
}

function startupError(serviceName, port, logFile, timeoutMs) {
  const recentLog = tailLines(logFile, STARTUP_LOG_LINES);
  const detail = recentLog
    ? `\n\nRecent ${serviceName} output:\n${recentLog}`
    : "\n\nThe service produced no output.";
  return new Error(
    `${serviceName} did not listen on port ${port} within ${formatDuration(
      timeoutMs,
    )}. Check its dependencies or increase DEV_STARTUP_TIMEOUT_MS.${detail}\n\nFull log: ${shortHome(
      logFile,
    )}`,
  );
}

function tailLines(file, count) {
  try {
    return readFileSync(file, "utf8").trimEnd().split(/\r?\n/).slice(-count).join("\n");
  } catch {
    return "";
  }
}

function portIsOpen(port) {
  return new Promise((resolvePromise) => {
    const socket = net.connect(port, "127.0.0.1");
    socket.once("connect", () => {
      socket.destroy();
      resolvePromise(true);
    });
    socket.once("error", () => {
      socket.destroy();
      resolvePromise(false);
    });
  });
}

function loadState() {
  if (!existsSync(STATE_FILE)) return { checkouts: {}, frontdoors: {} };
  try {
    return JSON.parse(readFileSync(STATE_FILE, "utf8"));
  } catch {
    return { checkouts: {}, frontdoors: {} };
  }
}

function saveState(state) {
  const temporary = join(STATE_DIRECTORY, `.state-${process.pid}.json`);
  writeFileSync(temporary, `${JSON.stringify(state, null, 2)}\n`, { mode: 0o600 });
  renameSync(temporary, STATE_FILE);
}

function cleanState(state) {
  state.checkouts ||= {};
  state.frontdoors ||= {};
  for (const [id, entry] of Object.entries(state.checkouts)) {
    if (!entry.services.every((service) => processIsAlive(service.pid))) {
      delete state.checkouts[id];
      if (state.activeId === id) state.activeId = undefined;
      for (const [port, selectedId] of Object.entries(state.frontdoors)) {
        if (selectedId === id) delete state.frontdoors[port];
      }
    }
  }
  return state;
}

function processIsAlive(pid) {
  if (!pid) return false;
  try {
    process.kill(pid, 0);
    return true;
  } catch {
    return false;
  }
}

function installStartupSignalHandlers(services) {
  let handlingSignal = false;
  const handlers = new Map();

  for (const [signal, exitCode] of [
    ["SIGINT", 130],
    ["SIGTERM", 143],
  ]) {
    const handler = () => {
      if (handlingSignal) return;
      handlingSignal = true;
      logError(`startup interrupted by ${signal}; cleaning up`);
      void cleanupServices(services).finally(() => process.exit(exitCode));
    };
    handlers.set(signal, handler);
    process.once(signal, handler);
  }

  return () => {
    for (const [signal, handler] of handlers) process.removeListener(signal, handler);
  };
}

async function cleanupServices(services, gracefulTimeoutMs = 2_000) {
  const pids = services.map((service) => service.pid);
  for (const pid of pids) terminateProcessGroup(pid);
  await waitForProcessExit(pids, gracefulTimeoutMs);
  for (const pid of pids.filter(processIsAlive)) terminateProcessGroup(pid, "SIGKILL");
  await waitForProcessExit(pids, 1_000);
  prunePortless();
}

function terminateProcessGroup(pid, signal = "SIGTERM") {
  try {
    process.kill(-pid, signal);
  } catch {
    try {
      process.kill(pid, signal);
    } catch {
      // The process has already exited.
    }
  }
}

async function waitForProcessExit(pids, timeoutMs) {
  const deadline = Date.now() + timeoutMs;
  while (pids.some(processIsAlive) && Date.now() < deadline) {
    await new Promise((resolvePromise) => setTimeout(resolvePromise, 100));
  }
}

function loadEnv(file) {
  return parseEnv(readFileSync(file, "utf8"));
}

function positiveIntegerEnv(name, fallback) {
  const raw = process.env[name]?.trim();
  if (!raw) return fallback;
  const value = Number(raw);
  if (!Number.isSafeInteger(value) || value <= 0) {
    throw new Error(`${name} must be a positive integer (milliseconds).`);
  }
  return value;
}

function formatDuration(milliseconds) {
  return milliseconds % 1000 === 0 ? `${milliseconds / 1000}s` : `${milliseconds}ms`;
}

function envHasKey(file, key) {
  return readFileSync(file, "utf8")
    .split(/\r?\n/)
    .some((line) => line.startsWith(`${key}=`));
}

function primaryWorktree(root) {
  const output = git(root, ["worktree", "list", "--porcelain"]);
  const first = output.split(/\r?\n/).find((line) => line.startsWith("worktree "));
  return first ? first.slice("worktree ".length) : root;
}

function packageManager(packageJson) {
  return packageJson.packageManager?.split("@")[0] || "npm";
}

function readJson(file) {
  return JSON.parse(readFileSync(file, "utf8"));
}

function directories(root) {
  return readdirSync(root)
    .map((name) => join(root, name))
    .filter((path) => {
      try {
        return statSync(path).isDirectory();
      } catch {
        return false;
      }
    })
    .map((path) => basename(path));
}

function git(directory, args) {
  try {
    return execFileSync("git", ["-C", directory, ...args], { encoding: "utf8" }).trim();
  } catch {
    return "";
  }
}

function printSelected(entry, verb) {
  log(`${verb.toLowerCase()} ${entry.label}`);
  for (const service of entry.services) console.log(`  ${service.name}: ${service.url}`);
  console.log(
    entry.frontdoor
      ? `  Open: http://localhost:${FRONTDOOR_PORT}`
      : `  Open: ${entry.services.find((service) => service.name === "web")?.url || entry.services[0].url}`,
  );
}

function log(message) {
  console.log(`dev: ${message}`);
}

function logError(message) {
  console.error(`dev: error: ${message}`);
}

function printHelp() {
  console.log("Usage:");
  console.log("  dev                 start/reuse and select the current checkout");
  console.log("  dev switch [name]   select another running checkout");
  console.log("  dev list            list running checkouts and URLs");
  console.log("  dev log(s) [name]   follow checkout logs, labeled by service");
  console.log("  dev stop [name]     stop a checkout");
  console.log("  dev stop --all      stop every checkout and shared infrastructure");
  console.log("");
  console.log("Environment:");
  console.log("  DEV_STARTUP_TIMEOUT_MS  per-service startup timeout (default: 20000)");
}

function safeId(value) {
  let hash = 0;
  for (const character of value) hash = (hash * 31 + character.charCodeAt(0)) >>> 0;
  return `${slug(basename(value))}-${hash.toString(16)}`;
}

function slug(value) {
  return value
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-|-$/g, "");
}

function shortHome(path) {
  return path.startsWith(homedir()) ? `~${path.slice(homedir().length)}` : path;
}
