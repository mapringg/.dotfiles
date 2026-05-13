#!/usr/bin/env node

import {
  copyFileSync,
  existsSync,
  mkdirSync,
  readFileSync,
  writeFileSync,
} from "node:fs";
import { dirname, join } from "node:path";

const codexHome =
  process.env.CODEX_HOME ?? join(process.env.HOME ?? "", ".codex");
const configPath = join(codexHome, "config.toml");

const settings = {
  root: {
    model: '"gpt-5.6-sol"',
    model_reasoning_effort: '"medium"',
    model_verbosity: '"low"',
    model_reasoning_summary: '"none"',
    personality: '"none"',
    approval_policy: '"never"',
    sandbox_mode: '"danger-full-access"',
  },
  history: {
    persistence: '"save-all"',
  },
  tui: {
    notifications: "false",
    animations: "false",
    show_tooltips: "false",
  },
  analytics: {
    enabled: "false",
  },
  feedback: {
    enabled: "false",
  },
  features: {
    apps: "false",
    goals: "false",
    hooks: "false",
    memories: "false",
    multi_agent: "false",
    personality: "false",
    remote_plugin: "false",
    fast_mode: "false",
  },
};

const obsoleteRootKeys = new Set(["approvals_reviewer"]);

function keyPattern(key) {
  return new RegExp(`^\\s*${key}\\s*=`);
}

function sectionBounds(lines, section) {
  if (section === "root") {
    const end = lines.findIndex((line) => /^\s*\[/.test(line));
    return [0, end === -1 ? lines.length : end];
  }

  const header = `[${section}]`;
  const start = lines.findIndex((line) => line.trim() === header);
  if (start === -1) return null;

  const relativeEnd = lines
    .slice(start + 1)
    .findIndex((line) => /^\s*\[/.test(line));
  const end = relativeEnd === -1 ? lines.length : start + 1 + relativeEnd;
  return [start + 1, end];
}

function applySection(lines, section, values) {
  let bounds = sectionBounds(lines, section);

  if (!bounds) {
    while (lines.at(-1)?.trim() === "") lines.pop();
    lines.push("", `[${section}]`);
    for (const [key, value] of Object.entries(values)) {
      lines.push(`${key} = ${value}`);
    }
    return;
  }

  for (const [key, value] of Object.entries(values)) {
    bounds = sectionBounds(lines, section);
    const [start, end] = bounds;
    const existing = lines
      .slice(start, end)
      .findIndex((line) => keyPattern(key).test(line));
    const desired = `${key} = ${value}`;

    if (existing === -1) {
      lines.splice(end, 0, desired);
    } else {
      lines[start + existing] = desired;
    }
  }
}

function compareText(left, right) {
  if (left < right) return -1;
  if (left > right) return 1;
  return 0;
}

function assignmentKey(line) {
  const keyPart = String.raw`(?:"(?:\\.|[^"])*"|'[^']*'|[A-Za-z0-9_-]+)`;
  const match = line.match(
    new RegExp(String.raw`^\s*(${keyPart}(?:\s*\.\s*${keyPart})*)\s*=`),
  );
  return match?.[1].trim();
}

function sortAssignments(lines) {
  const assignmentIndexes = [];
  const assignments = [];

  for (const [index, line] of lines.entries()) {
    const key = assignmentKey(line);
    if (key === undefined) continue;
    assignmentIndexes.push(index);
    assignments.push({ key, line });
  }

  assignments.sort((left, right) => compareText(left.key, right.key));
  for (const [index, assignment] of assignments.entries()) {
    lines[assignmentIndexes[index]] = assignment.line;
  }

  return lines;
}

function sortConfig(lines) {
  const sections = [];
  const firstHeader = lines.findIndex((line) => /^\s*\[/.test(line));
  const rootEnd = firstHeader === -1 ? lines.length : firstHeader;
  const root = sortAssignments(lines.slice(0, rootEnd));

  for (let start = rootEnd; start < lines.length; ) {
    let end = start + 1;
    while (end < lines.length && !/^\s*\[/.test(lines[end])) end += 1;

    const body = sortAssignments(lines.slice(start + 1, end));
    while (body.at(-1)?.trim() === "") body.pop();
    sections.push({
      header: lines[start],
      name: lines[start].trim().replace(/^\[\[?|\]\]?$/g, ""),
      body,
    });
    start = end;
  }

  sections.sort((left, right) => compareText(left.name, right.name));
  while (root.at(-1)?.trim() === "") root.pop();

  const sorted = [...root];
  for (const section of sections) {
    if (sorted.length > 0) sorted.push("");
    sorted.push(section.header, ...section.body);
  }
  return sorted;
}

mkdirSync(dirname(configPath), { recursive: true });
const original = existsSync(configPath) ? readFileSync(configPath, "utf8") : "";
const lines = original.replace(/\n$/, "").split("\n");

if (lines.length === 1 && lines[0] === "") lines.pop();

const rootEnd = sectionBounds(lines, "root")[1];
for (let index = rootEnd - 1; index >= 0; index -= 1) {
  const key = lines[index].match(/^\s*([A-Za-z0-9_-]+)\s*=/)?.[1];
  if (key && obsoleteRootKeys.has(key)) lines.splice(index, 1);
}

for (const [section, values] of Object.entries(settings)) {
  applySection(lines, section, values);
}

const updated = `${sortConfig(lines).join("\n").replace(/^\n+/, "")}\n`;

if (updated === original) {
  console.log(`setup-codex: settings already current: ${configPath}`);
  process.exit(0);
}

if (existsSync(configPath)) {
  const stamp = new Date().toISOString().replace(/[:.]/g, "-");
  const backupPath = `${configPath}.backup-${stamp}`;
  copyFileSync(configPath, backupPath);
  console.log(`setup-codex: backed up settings: ${backupPath}`);
}

writeFileSync(configPath, updated, { mode: 0o600 });
console.log(`setup-codex: updated settings: ${configPath}`);
console.log("setup-codex: preserved machine-local project trust");
