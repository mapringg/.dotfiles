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
    execSync("killall 'Google Chrome'", { stdio: "ignore" });
  } else {
    execSync("pkill -f 'chrome|chromium'", { stdio: "ignore" });
  }
} catch {}

await new Promise((r) => setTimeout(r, 1000));

execSync("mkdir -p ~/.cache/scraping", { stdio: "ignore" });

if (useProfile) {
  const profileSource = isMac
    ? `${process.env["HOME"]}/Library/Application Support/Google/Chrome/`
    : `${process.env["HOME"]}/.config/google-chrome/`;
  execSync(`rsync -a --delete "${profileSource}" ~/.cache/scraping/`, {
    stdio: "pipe",
  });
}

function findChromePath() {
  if (isMac) {
    const paths = [
      "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
      "/Applications/Chromium.app/Contents/MacOS/Chromium",
    ];
    for (const p of paths) {
      if (existsSync(p)) return p;
    }
    return paths[0];
  }
  const linuxPaths = [
    "/usr/bin/google-chrome-stable",
    "/usr/bin/google-chrome",
    "/usr/bin/chromium-browser",
    "/usr/bin/chromium",
    "/snap/bin/chromium",
  ];
  for (const p of linuxPaths) {
    if (existsSync(p)) return p;
  }
  return "google-chrome";
}

spawn(
  findChromePath(),
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
  console.error("✗ Failed to connect to Chrome");
  process.exit(1);
}

const scriptDir = dirname(fileURLToPath(import.meta.url));
const watcherPath = join(scriptDir, "watch.js");
spawn(process.execPath, [watcherPath], {
  detached: true,
  stdio: "ignore",
}).unref();

console.log(
  `✓ Chrome started on :9222${useProfile ? " with your profile" : ""}`,
);
