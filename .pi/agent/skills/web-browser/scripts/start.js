#!/usr/bin/env node

import { execSync, spawn } from "node:child_process";
import { existsSync } from "node:fs";
import { platform } from "node:os";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const isMac = platform() === "darwin";

const useProfile = process.argv[2] === "--profile";

if (process.argv[2] && process.argv[2] !== "--profile") {
  console.log("Usage: start.ts [--profile]");
  console.log("\nOptions:");
  console.log(
    "  --profile  Copy your default Chrome profile (cookies, logins)",
  );
  console.log("\nExamples:");
  console.log("  start.ts            # Start with fresh profile");
  console.log("  start.ts --profile  # Start with your Chrome profile");
  process.exit(1);
}

try {
  if (isMac) {
    execSync("killall 'Chromium' 'Brave Browser' 2>/dev/null || true", { stdio: "ignore", shell: true });
  } else {
    execSync("pkill -f 'chromium|brave' 2>/dev/null || true", { stdio: "ignore", shell: true });
  }
} catch {}

await new Promise((r) => setTimeout(r, 1000));

execSync("mkdir -p ~/.cache/scraping", { stdio: "ignore" });

function findChromePath() {
  if (isMac) {
    const paths = [
      "/Applications/Chromium.app/Contents/MacOS/Chromium",
      "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser",
    ];
    for (const p of paths) {
      if (existsSync(p)) return p;
    }
    return paths[1];
  }
  const linuxPaths = [
    "/usr/bin/chromium-browser",
    "/usr/bin/chromium",
    "/snap/bin/chromium",
    "/usr/bin/brave-browser",
    "/usr/bin/brave",
    "/snap/bin/brave",
  ];
  for (const p of linuxPaths) {
    if (existsSync(p)) return p;
  }
  return "chromium";
}

const browserPath = findChromePath();
const isBrave = browserPath.toLowerCase().includes("brave");
const isChromium = browserPath.toLowerCase().includes("chromium");
const browserName = isBrave ? "Brave" : "Chromium";

function getProfileSource() {
  if (isMac) {
    if (isBrave) return `${process.env["HOME"]}/Library/Application Support/BraveSoftware/Brave-Browser/`;
    if (isChromium) return `${process.env["HOME"]}/Library/Application Support/Chromium/`;
    return `${process.env["HOME"]}/Library/Application Support/Chromium/`;
  }
  if (isBrave) return `${process.env["HOME"]}/.config/BraveSoftware/Brave-Browser/`;
  if (isChromium) return `${process.env["HOME"]}/.config/chromium/`;
  return `${process.env["HOME"]}/.config/chromium/`;
}

if (useProfile) {
  const profileSource = getProfileSource();
  execSync(`rsync -a --delete "${profileSource}" ~/.cache/scraping/`, {
    stdio: "pipe",
  });
}

spawn(
  browserPath,
  [
    "--remote-debugging-port=9222",
    `--user-data-dir=${process.env["HOME"]}/.cache/scraping`,
    "--profile-directory=Default",
    "--disable-search-engine-choice-screen",
    "--no-first-run",
    "--disable-features=ProfilePicker",
  ],
  { detached: true, stdio: "ignore" },
).unref();

let connected = false;
for (let i = 0; i < 30; i++) {
  try {
    const response = await fetch("http://localhost:9222/json/version");
    if (response.ok) {
      connected = true;
      break;
    }
  } catch {
    await new Promise((r) => setTimeout(r, 500));
  }
}

if (!connected) {
  console.error(`✗ Failed to connect to ${browserName}`);
  process.exit(1);
}

const scriptDir = dirname(fileURLToPath(import.meta.url));
const watcherPath = join(scriptDir, "watch.js");
spawn(process.execPath, [watcherPath], {
  detached: true,
  stdio: "ignore",
}).unref();

console.log(
  `✓ ${browserName} started on :9222${useProfile ? " with your profile" : ""}`,
);
