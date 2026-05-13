#!/usr/bin/env node

import { createHash } from "node:crypto";
import { execFile, spawnSync } from "node:child_process";
import {
  existsSync,
  readdirSync,
  readFileSync,
  realpathSync,
  statSync,
} from "node:fs";
import { basename, isAbsolute, join, resolve } from "node:path";
import { promisify } from "node:util";

const execFileAsync = promisify(execFile);
const protectedBranches = new Set(["main", "master", "develop"]);
const settledAgentStates = new Set(["idle", "done"]);
const supportedAgents = new Set(["codex", "claude"]);
const commandName = "wave";

const arguments_ = process.argv.slice(2);
let [command, ...rawOptions] = arguments_;
if (
  command === undefined ||
  (command.startsWith("-") && !["--help", "-h"].includes(command))
) {
  command = "dispatch";
  rawOptions = arguments_;
}

class RebaseStoppedError extends Error {
  constructor(cwd, onto, reason) {
    super(reason);
    this.cwd = cwd;
    this.onto = onto;
    this.reason = reason;
    this.integrated = [];
  }
}

try {
  if (["dispatch", "start"].includes(command)) {
    await dispatch(parseOptions(rawOptions, { agent: true }));
  } else if (["integrate", "land"].includes(command)) {
    await integrate(parseOptions(rawOptions, { agent: false }));
  } else if (["help", "--help", "-h"].includes(command)) {
    printHelp();
  } else {
    fail(`Unknown command: ${command}\n\n${helpText()}`);
  }
} catch (error) {
  if (error instanceof RebaseStoppedError) {
    printRebaseStopped(error);
    process.exitCode = 2;
  } else {
    console.error(`wave: ${messageOf(error)}`);
    process.exitCode = 1;
  }
}

async function dispatch(options) {
  const context = inspectFeature(options);
  const world = await inspectWorld(context);
  classifyTickets(context, world);

  const ready = context.tickets.filter(
    (ticket) =>
      !ticket.integrated &&
      ticket.blockers.every((number) => ticketByNumber(context, number).integrated),
  );
  const blocked = context.tickets.filter(
    (ticket) =>
      !ticket.integrated &&
      ticket.blockers.some((number) => !ticketByNumber(context, number).integrated),
  );

  if (ready.length === 0) {
    printDispatchSummary(context, { dispatched: [], reused: [], blocked, failures: [] });
    return;
  }

  const outcomes = await Promise.all(
    ready.map(async (ticket) => {
      try {
        return await dispatchTicket(context, world, ticket, options.agent);
      } catch (error) {
        return { kind: "failure", ticket, error };
      }
    }),
  );

  const summary = {
    dispatched: outcomes.filter((item) => item.kind === "dispatched"),
    reused: outcomes.filter((item) => item.kind === "reused"),
    failures: outcomes.filter((item) => item.kind === "failure"),
    blocked,
  };
  printDispatchSummary(context, summary);
  if (summary.failures.length > 0) process.exitCode = 1;
}

async function dispatchTicket(context, world, ticket, agentKind) {
  let worktree = ticket.worktree;
  let paneId;

  if (!worktree) {
    const created = await herdr(
      [
        "worktree",
        "create",
        "--workspace",
        world.parentWorkspaceId,
        "--base",
        context.branch,
        "--branch",
        ticket.branch,
        "--label",
        ticket.herdrName,
        "--no-focus",
        "--json",
      ],
      context.root,
    );
    worktree = created.result?.worktree;
    paneId = created.result?.root_pane?.pane_id;
    requireValue(worktree?.path, `Herdr did not return a worktree path for ${ticket.branch}.`);
    requireValue(paneId, `Herdr did not return a root pane for ${ticket.branch}.`);
  } else if (!worktree.open_workspace_id) {
    const opened = await herdr(
      [
        "worktree",
        "open",
        "--workspace",
        world.parentWorkspaceId,
        "--branch",
        ticket.branch,
        "--label",
        ticket.herdrName,
        "--no-focus",
        "--json",
      ],
      context.root,
    );
    worktree = opened.result?.worktree;
    paneId = opened.result?.root_pane?.pane_id;
    requireValue(paneId, `Herdr did not return a root pane for ${ticket.branch}.`);
  }

  const worktreeRoot = canonicalPath(worktree.path);
  requireBranch(worktreeRoot, ticket.branch);

  let agent = ticket.agents[0];
  if (ticket.agents.length > 1) {
    throw new Error(`Multiple Herdr agents are mapped to ${ticket.branch}.`);
  }

  if (agent) {
    if (agent.agent !== agentKind) {
      throw new Error(
        `${ticket.branch} already has a ${agent.agent} agent; requested ${agentKind}.`,
      );
    }
    if (agent.name === undefined) return { kind: "reused", ticket };
    if (agent.name !== ticket.herdrName) {
      throw new Error(
        `${ticket.branch} has unexpected agent name ${JSON.stringify(agent.name)}.`,
      );
    }
    paneId = agent.pane_id;
  } else {
    if (!paneId) {
      const workspaceId = worktree.open_workspace_id;
      requireValue(workspaceId, `No open Herdr workspace exists for ${ticket.branch}.`);
      const panes = await herdr(["pane", "list", "--workspace", workspaceId], context.root);
      const available = (panes.result?.panes ?? []).filter(
        (pane) => !world.agents.some((candidate) => candidate.pane_id === pane.pane_id),
      );
      if (available.length !== 1) {
        throw new Error(
          `${ticket.branch} needs exactly one agent-free pane; found ${available.length}.`,
        );
      }
      paneId = available[0].pane_id;
    }

    const started = await herdr(
      [
        "agent",
        "start",
        ticket.herdrName,
        "--kind",
        agentKind,
        "--pane",
        paneId,
        "--timeout",
        "60000",
      ],
      worktreeRoot,
    );
    agent = started.result?.agent;
    requireValue(agent?.pane_id, `Herdr did not return the started agent for ${ticket.branch}.`);
    paneId = agent.pane_id;
  }

  const prompt =
    agentKind === "claude"
      ? `/implement ${ticket.path}`
      : `Use $implement to implement the ticket at ${ticket.path}.`;
  await herdr(["agent", "prompt", paneId, prompt], context.root);
  await herdr(["agent", "rename", paneId, "--clear"], context.root);
  return { kind: "dispatched", ticket };
}

async function integrate(options) {
  const context = inspectFeature(options);
  const world = await inspectWorld(context);
  classifyTickets(context, world);

  const frontier = context.tickets.filter(
    (ticket) =>
      !ticket.integrated &&
      ticket.blockers.every((number) => ticketByNumber(context, number).integrated),
  );

  if (frontier.length === 0) {
    printIntegrationIdle(context);
    return;
  }

  const candidates = [];
  const pending = [];

  for (const ticket of frontier) {
    if (!ticket.branchExists) {
      pending.push(`${ticketLabel(ticket)} has not been dispatched`);
      continue;
    }
    if (!ticket.progressed) {
      pending.push(`${ticketLabel(ticket)} has no committed ticket work`);
      continue;
    }
    if (!ticket.worktree) {
      pending.push(`${ticketLabel(ticket)} has no worktree`);
      continue;
    }
    if (!ticket.worktree.open_workspace_id) {
      pending.push(`${ticketLabel(ticket)} is not open in Herdr`);
      continue;
    }
    if (ticket.agents.length !== 1) {
      pending.push(
        `${ticketLabel(ticket)} has ${ticket.agents.length} Herdr agents; expected one`,
      );
      continue;
    }

    const agent = ticket.agents[0];
    if (agent.name !== undefined) {
      pending.push(`${ticketLabel(ticket)} still has a pending dispatch marker`);
      continue;
    }
    if (!settledAgentStates.has(agent.agent_status)) {
      pending.push(`${ticketLabel(ticket)} agent is ${agent.agent_status}`);
      continue;
    }

    const worktreeRoot = canonicalPath(ticket.worktree.path);
    stopForExistingRebase(worktreeRoot);
    requireBranch(worktreeRoot, ticket.branch);
    requireClean(worktreeRoot, ticket.branch);
    candidates.push({ ...ticket, worktreeRoot });
  }

  if (pending.length > 0) {
    console.log(`wave: ${context.branch}`);
    console.log("not ready to integrate:");
    for (const item of pending) console.log(`  ${item}`);
    return;
  }

  const integrated = [];
  for (const ticket of candidates.sort((left, right) => left.number - right.number)) {
    try {
      rebase(ticket.worktreeRoot, context.branch);
      requireAncestor(context.root, context.branch, ticket.branch);
      rebase(context.root, ticket.branch);
      requireSameTip(context.root, context.branch, ticket.branch);
      integrated.push(ticket);
    } catch (error) {
      if (error instanceof RebaseStoppedError) {
        error.integrated = integrated;
      }
      throw error;
    }
  }

  printIntegrationSummary(context, integrated);
}

function inspectFeature(options) {
  const root = canonicalPath(git(process.cwd(), ["rev-parse", "--show-toplevel"]));
  const branch = git(root, ["symbolic-ref", "--quiet", "--short", "HEAD"]);
  if (!branch) fail("Run from an attached feature worktree.");
  if (protectedBranches.has(branch)) {
    fail(`Refusing to run on protected branch ${branch}.`);
  }

  stopForExistingRebase(root);
  requireClean(root, branch);

  const issuesDirectory = findIssuesDirectory(root, branch, options.issues);
  const tickets = readTickets(issuesDirectory);
  validateTicketGraph(tickets);

  for (const ticket of tickets) {
    ticket.branch = `${branch}-${ticket.number}`;
    ticket.herdrName = herdrName(ticket.branch);
    git(root, ["check-ref-format", "--branch", ticket.branch]);
  }

  return { root, branch, issuesDirectory, tickets };
}

async function inspectWorld(context) {
  const [worktreesResponse, agentsResponse] = await Promise.all([
    herdr(["worktree", "list", "--cwd", context.root, "--json"], context.root),
    herdr(["agent", "list"], context.root),
  ]);
  const parentWorkspaceId = worktreesResponse.result?.source?.source_workspace_id;
  requireValue(parentWorkspaceId, "Herdr did not return the repository parent workspace.");

  const worktrees = worktreesResponse.result?.worktrees ?? [];
  const featureMatches = worktrees.filter(
    (worktree) =>
      worktree.branch === context.branch &&
      canonicalPath(worktree.path) === context.root,
  );
  if (featureMatches.length !== 1) {
    fail(`Herdr did not resolve exactly one worktree for ${context.branch}.`);
  }

  return {
    parentWorkspaceId,
    worktrees,
    agents: agentsResponse.result?.agents ?? [],
  };
}

function classifyTickets(context, world) {
  for (const ticket of context.tickets) {
    ticket.branchExists = refExists(context.root, ticket.branch);
    ticket.progressed =
      ticket.branchExists && branchHasProgress(context.root, ticket.branch);
    ticket.integrated =
      ticket.branchExists &&
      ticket.progressed &&
      isAncestor(context.root, ticket.branch, context.branch);

    const worktrees = world.worktrees.filter(
      (worktree) =>
        worktree.branch === ticket.branch ||
        rebaseHeadBranch(worktree.path) === ticket.branch,
    );
    if (worktrees.length > 1) {
      fail(`Multiple worktrees are mapped to ${ticket.branch}.`);
    }
    ticket.worktree = worktrees[0];
    ticket.agents = ticket.worktree
      ? world.agents.filter(
          (agent) =>
            agent.workspace_id === ticket.worktree.open_workspace_id ||
            canonicalOptionalPath(agent.cwd) === canonicalPath(ticket.worktree.path),
        )
      : [];
  }
}

function findIssuesDirectory(root, branch, explicitPath) {
  if (explicitPath) {
    const directory = canonicalPath(
      isAbsolute(explicitPath) ? explicitPath : resolve(root, explicitPath),
    );
    requireDirectory(directory, `Ticket directory does not exist: ${directory}`);
    return directory;
  }

  const scratch = join(root, ".scratch");
  const branchTail = basename(branch);
  const preferred = [
    join(scratch, branchTail, "issues"),
    join(scratch, branch.replaceAll("/", "-"), "issues"),
  ].filter((path, index, paths) => paths.indexOf(path) === index);
  const preferredMatches = preferred.filter(isDirectory);
  if (preferredMatches.length === 1) return canonicalPath(preferredMatches[0]);
  if (preferredMatches.length > 1) {
    fail(`Multiple ticket directories match ${branch}; pass --issues PATH.`);
  }

  const discovered = isDirectory(scratch)
    ? readdirSync(scratch)
        .map((name) => join(scratch, name, "issues"))
        .filter(isDirectory)
    : [];
  if (discovered.length === 1) return canonicalPath(discovered[0]);
  if (discovered.length === 0) {
    fail(`No ticket directory found for ${branch}; expected .scratch/${branchTail}/issues.`);
  }
  fail(
    `Multiple ticket directories exist (${discovered.join(", ")}); pass --issues PATH.`,
  );
}

function readTickets(directory) {
  const tickets = [];
  for (const file of readdirSync(directory).sort()) {
    const match = file.match(/^(\d+)(?:[-_. ].*)?\.md$/i);
    if (!match) continue;

    const number = Number(match[1]);
    if (!Number.isSafeInteger(number) || number < 1) {
      fail(`Invalid ticket number in ${file}.`);
    }

    const path = canonicalPath(join(directory, file));
    const markdown = readFileSync(path, "utf8");
    const blockedLine = markdown.match(/^\*\*Blocked by:\*\*\s*(.+)$/im)?.[1];
    if (!blockedLine) fail(`${file} is missing a "Blocked by" line.`);

    let blockers = [];
    if (!/^\s*none\b/i.test(blockedLine)) {
      blockers = [...blockedLine.matchAll(/\b(\d+)\b/g)].map((item) => Number(item[1]));
      blockers = [...new Set(blockers)];
      if (blockers.length === 0) fail(`${file} has no parseable blocker numbers.`);
    }

    tickets.push({ number, file, path, blockers });
  }

  if (tickets.length === 0) fail(`No numbered Markdown tickets found in ${directory}.`);
  tickets.sort((left, right) => left.number - right.number);
  return tickets;
}

function validateTicketGraph(tickets) {
  const seen = new Set();
  for (const ticket of tickets) {
    if (seen.has(ticket.number)) fail(`Duplicate ticket number ${ticket.number}.`);
    seen.add(ticket.number);
  }

  for (const ticket of tickets) {
    for (const blocker of ticket.blockers) {
      if (!seen.has(blocker)) {
        fail(`${ticket.file} references missing blocker ${blocker}.`);
      }
      if (blocker === ticket.number) fail(`${ticket.file} blocks itself.`);
    }
  }

  const visiting = new Set();
  const visited = new Set();
  function visit(number, trail) {
    if (visiting.has(number)) {
      fail(`Ticket dependency cycle: ${[...trail, number].join(" -> ")}.`);
    }
    if (visited.has(number)) return;
    visiting.add(number);
    const ticket = tickets.find((item) => item.number === number);
    for (const blocker of ticket.blockers) visit(blocker, [...trail, number]);
    visiting.delete(number);
    visited.add(number);
  }
  for (const ticket of tickets) visit(ticket.number, []);
}

function rebase(cwd, onto) {
  const result = run("git", ["rebase", onto], cwd, { allowFailure: true });
  if (result.status === 0) return;
  if (rebaseInProgress(cwd)) {
    throw new RebaseStoppedError(cwd, onto, commandFailure("git", ["rebase", onto], result));
  }
  throw new Error(commandFailure("git", ["rebase", onto], result));
}

function stopForExistingRebase(cwd) {
  if (rebaseInProgress(cwd)) {
    throw new RebaseStoppedError(cwd, undefined, "A rebase is already in progress.");
  }
}

function rebaseInProgress(cwd) {
  return ["rebase-merge", "rebase-apply"].some((name) => {
    const path = git(cwd, ["rev-parse", "--git-path", name]);
    return existsSync(isAbsolute(path) ? path : resolve(cwd, path));
  });
}

function rebaseHeadBranch(cwd) {
  for (const directoryName of ["rebase-merge", "rebase-apply"]) {
    const gitPath = git(cwd, ["rev-parse", "--git-path", directoryName]);
    const directory = isAbsolute(gitPath) ? gitPath : resolve(cwd, gitPath);
    const headName = join(directory, "head-name");
    if (!existsSync(headName)) continue;
    const ref = readFileSync(headName, "utf8").trim();
    return ref.startsWith("refs/heads/") ? ref.slice("refs/heads/".length) : undefined;
  }
  return undefined;
}

function requireClean(cwd, label) {
  const status = git(cwd, ["status", "--porcelain", "--untracked-files=normal"]);
  if (status) fail(`${label} worktree is not clean:\n${indent(status)}`);
}

function requireBranch(cwd, expected) {
  const actual = git(cwd, ["symbolic-ref", "--quiet", "--short", "HEAD"]);
  if (actual !== expected) {
    fail(`Expected ${expected} in ${cwd}; found ${actual || "detached HEAD"}.`);
  }
}

function requireAncestor(cwd, ancestor, descendant) {
  if (!isAncestor(cwd, ancestor, descendant)) {
    fail(`${ancestor} is not an ancestor of ${descendant} after rebase.`);
  }
}

function requireSameTip(cwd, left, right) {
  const leftTip = git(cwd, ["rev-parse", left]);
  const rightTip = git(cwd, ["rev-parse", right]);
  if (leftTip !== rightTip) fail(`${left} and ${right} do not have the same tip.`);
}

function refExists(cwd, branch) {
  return (
    run("git", ["show-ref", "--verify", "--quiet", `refs/heads/${branch}`], cwd, {
      allowFailure: true,
    }).status === 0
  );
}

function isAncestor(cwd, ancestor, descendant) {
  return (
    run("git", ["merge-base", "--is-ancestor", ancestor, descendant], cwd, {
      allowFailure: true,
    }).status === 0
  );
}

function branchHasProgress(cwd, branch) {
  const reflog = run(
    "git",
    ["reflog", "show", "--format=%H", `refs/heads/${branch}`],
    cwd,
    { allowFailure: true },
  );
  if (reflog.status !== 0) return false;
  return reflog.stdout.trim().split("\n").filter(Boolean).length > 1;
}

function git(cwd, args) {
  return checkedOutput("git", args, cwd);
}

async function herdr(args, cwd) {
  let stdout;
  try {
    ({ stdout } = await execFileAsync("herdr", args, {
      cwd,
      encoding: "utf8",
      maxBuffer: 10 * 1024 * 1024,
    }));
  } catch (error) {
    const detail = String(error.stderr || error.stdout || error.message).trim();
    throw new Error(`herdr ${args.slice(0, 2).join(" ")} failed${detail ? `: ${detail}` : ""}`);
  }
  try {
    return JSON.parse(stdout);
  } catch {
    throw new Error(`herdr ${args.slice(0, 2).join(" ")} returned invalid JSON.`);
  }
}

function checkedOutput(program, args, cwd) {
  const result = run(program, args, cwd, { allowFailure: true });
  if (result.status !== 0) throw new Error(commandFailure(program, args, result));
  return result.stdout.trim();
}

function run(program, args, cwd, options = {}) {
  const result = spawnSync(program, args, {
    cwd,
    encoding: "utf8",
    maxBuffer: 10 * 1024 * 1024,
  });
  if (result.error) throw result.error;
  const normalized = {
    status: result.status ?? 1,
    stdout: result.stdout ?? "",
    stderr: result.stderr ?? "",
  };
  if (!options.allowFailure && normalized.status !== 0) {
    throw new Error(commandFailure(program, args, normalized));
  }
  return normalized;
}

function commandFailure(program, args, result) {
  const detail = String(result.stderr || result.stdout).trim();
  return `${program} ${args.join(" ")} failed${detail ? `: ${detail}` : ""}`;
}

function parseOptions(args, capabilities) {
  const options = {
    agent: process.env.FRONTIER_AGENT || "codex",
    issues: undefined,
  };

  for (let index = 0; index < args.length; index += 1) {
    const argument = args[index];
    if (argument === "--help" || argument === "-h") {
      printHelp();
      process.exit(0);
    } else if (argument === "--issues") {
      options.issues = args[++index];
      if (!options.issues) fail("--issues requires a path.");
    } else if (argument.startsWith("--issues=")) {
      options.issues = argument.slice("--issues=".length);
    } else if (argument === "--agent" && capabilities.agent) {
      options.agent = args[++index];
      if (!options.agent) fail("--agent requires codex or claude.");
    } else if (argument.startsWith("--agent=") && capabilities.agent) {
      options.agent = argument.slice("--agent=".length);
    } else {
      fail(`Unknown option: ${argument}`);
    }
  }

  if (capabilities.agent && !supportedAgents.has(options.agent)) {
    fail(`Unsupported agent ${JSON.stringify(options.agent)}; use codex or claude.`);
  }
  return options;
}

function herdrName(branch) {
  let name = branch.toLowerCase().replaceAll("/", "-").replace(/[^a-z0-9_-]/g, "-");
  name = name.replace(/-+/g, "-");
  if (!/^[a-z]/.test(name)) name = `t-${name}`;
  if (name.length <= 32) return name;
  const hash = createHash("sha256").update(branch).digest("hex").slice(0, 8);
  return `${name.slice(0, 23).replace(/[-_]+$/, "")}-${hash}`;
}

function ticketByNumber(context, number) {
  return context.tickets.find((ticket) => ticket.number === number);
}

function printDispatchSummary(context, summary) {
  console.log(`wave: ${context.branch}`);
  printTicketGroup("dispatched", summary.dispatched.map((item) => item.ticket));
  printTicketGroup("reused", summary.reused.map((item) => item.ticket));
  printTicketGroup(
    "integrated",
    context.tickets.filter((ticket) => ticket.integrated),
  );
  if (summary.blocked.length > 0) {
    console.log("blocked:");
    for (const ticket of summary.blocked) {
      const remaining = ticket.blockers.filter(
        (number) => !ticketByNumber(context, number).integrated,
      );
      console.log(`  ${ticketLabel(ticket)} by ${remaining.join(", ")}`);
    }
  }
  if (summary.failures.length > 0) {
    console.log("failed:");
    for (const item of summary.failures) {
      console.log(`  ${ticketLabel(item.ticket)}: ${messageOf(item.error)}`);
    }
  }
  if (context.tickets.every((ticket) => ticket.integrated)) console.log("complete");
}

function printIntegrationSummary(context, integrated) {
  console.log(`wave: ${context.branch}`);
  printTicketGroup("integrated", integrated);
  console.log(`feature tip: ${git(context.root, ["rev-parse", "--short", "HEAD"])}`);
  refreshIntegrationState(context);
  if (context.tickets.every((ticket) => ticket.integrated)) {
    console.log("complete");
    return;
  }
  const next = context.tickets.filter(
    (ticket) =>
      !ticket.integrated &&
      ticket.blockers.every((number) => ticketByNumber(context, number).integrated),
  );
  printTicketGroup("next wave", next);
}

function printIntegrationIdle(context) {
  refreshIntegrationState(context);
  console.log(`wave: ${context.branch}`);
  if (context.tickets.every((ticket) => ticket.integrated)) {
    console.log("complete");
    return;
  }
  const ready = context.tickets.filter(
    (ticket) =>
      !ticket.integrated &&
      ticket.blockers.every((number) => ticketByNumber(context, number).integrated),
  );
  printTicketGroup("next wave", ready);
}

function refreshIntegrationState(context) {
  for (const ticket of context.tickets) {
    ticket.integrated =
      refExists(context.root, ticket.branch) &&
      branchHasProgress(context.root, ticket.branch) &&
      isAncestor(context.root, ticket.branch, context.branch);
  }
}

function printTicketGroup(label, tickets) {
  if (tickets.length === 0) return;
  console.log(`${label}:`);
  for (const ticket of tickets) console.log(`  ${ticketLabel(ticket)}`);
}

function ticketLabel(ticket) {
  return `${String(ticket.number).padStart(2, "0")} ${ticket.branch}`;
}

function printRebaseStopped(error) {
  if (error.integrated?.length) printTicketGroup("integrated before conflict", error.integrated);
  console.error(`wave: rebase stopped in ${error.cwd}`);
  if (error.reason) console.error(indent(error.reason));
  console.error("resolve the conflicts, then run:");
  console.error(`  git -C ${shellQuote(error.cwd)} add <resolved-files>`);
  console.error(`  git -C ${shellQuote(error.cwd)} rebase --continue`);
  console.error(`  ${commandName} land`);
  console.error("or abort with:");
  console.error(`  git -C ${shellQuote(error.cwd)} rebase --abort`);
}

function printHelp() {
  console.log(helpText());
}

function helpText() {
  return `Usage:
  wave [--agent codex|claude] [--issues PATH]
  wave land [--issues PATH]

Dispatch starts every currently unblocked ticket in parallel.
Land rebases one manually verified wave into the feature branch.

Run from a clean feature worktree. By default tickets are read from
.scratch/<feature>/issues and dispatch uses Codex.`;
}

function canonicalPath(path) {
  return realpathSync(path);
}

function canonicalOptionalPath(path) {
  if (!path || !existsSync(path)) return undefined;
  return canonicalPath(path);
}

function isDirectory(path) {
  try {
    return statSync(path).isDirectory();
  } catch {
    return false;
  }
}

function requireDirectory(path, message) {
  if (!isDirectory(path)) fail(message);
}

function requireValue(value, message) {
  if (!value) fail(message);
  return value;
}

function shellQuote(value) {
  return `'${String(value).replaceAll("'", "'\"'\"'")}'`;
}

function indent(value) {
  return String(value)
    .split("\n")
    .map((line) => `  ${line}`)
    .join("\n");
}

function messageOf(error) {
  return error instanceof Error ? error.message : String(error);
}

function fail(message) {
  throw new Error(message);
}
