#!/usr/bin/env node

import { spawnSync } from "node:child_process";
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const CACHE_DIR = join(tmpdir(), "pi-share-cache");

const args = process.argv.slice(2);
const input = args.find((a) => !a.startsWith("--"));
const flags = new Set(args.filter((a) => a.startsWith("--")));

if (!input) {
  console.error(
    "Usage: node fetch-session.mjs <url-or-gist-id> [--header|--entries|--system|--tools]",
  );
  process.exit(1);
}

function getCachePath(gistId) {
  return join(CACHE_DIR, `${gistId}.json`);
}

function readCache(gistId) {
  const path = getCachePath(gistId);
  if (existsSync(path)) {
    return JSON.parse(readFileSync(path, "utf-8"));
  }
  return null;
}

function writeCache(gistId, data) {
  mkdirSync(CACHE_DIR, { recursive: true });
  writeFileSync(getCachePath(gistId), JSON.stringify(data));
}

function extractGistId(input) {
  const queryMatch = input.match(/[?&]([a-f0-9]{32})/i);
  if (queryMatch) return queryMatch[1];

  const pathMatch = input.match(/\/session\/?([a-f0-9]{32})/i);
  if (pathMatch) return pathMatch[1];

  if (/^[a-f0-9]{32}$/i.test(input)) return input;

  const gistMatch = input.match(/gist\.github\.com\/[^/]+\/([a-f0-9]+)/i);
  if (gistMatch) return gistMatch[1];

  throw new Error(`Cannot extract gist ID from: ${input}`);
}

async function fetchSessionHtml(gistId) {
  const gistRes = await fetch(`https://api.github.com/gists/${gistId}`);
  if (!gistRes.ok) {
    if (gistRes.status === 404)
      throw new Error("Session not found (gist deleted or invalid ID)");
    throw new Error(`GitHub API error: ${gistRes.status}`);
  }

  const gist = await gistRes.json();
  const file = gist.files?.["session.html"];
  if (!file) {
    const available = Object.keys(gist.files || {}).join(", ") || "none";
    throw new Error(`No session.html in gist. Available: ${available}`);
  }

  if (file.truncated && file.raw_url) {
    const rawRes = await fetch(file.raw_url);
    if (!rawRes.ok) throw new Error("Failed to fetch raw content");
    return rawRes.text();
  }

  return file.content;
}

function extractSessionData(html) {
  const match = html.match(
    /<script[^>]*id="session-data"[^>]*>([^<]+)<\/script>/,
  );
  if (match) {
    const base64 = match[1].trim();
    const json = Buffer.from(base64, "base64").toString("utf-8");
    return JSON.parse(json);
  }

  throw new Error(
    "No session data found in HTML. This may be an older export format without embedded data.",
  );
}

function truncate(text, maxLen = 150) {
  if (!text || text.length <= maxLen) return text;
  return `${text.slice(0, maxLen)}...`;
}

function extractForSummary(data) {
  const turns = [];
  let turnNumber = 0;

  for (const entry of data.entries) {
    if (entry.type !== "message") continue;

    const msg = entry.message;
    if (!msg || !msg.role) continue;

    if (msg.role === "user") {
      turnNumber++;
      const textParts = (msg.content || [])
        .filter((c) => c.type === "text")
        .map((c) => c.text)
        .join("\n");

      if (textParts.trim()) {
        turns.push({
          turn: turnNumber,
          role: "human",
          text: textParts,
        });
      }
    } else if (msg.role === "assistant") {
      const textParts = [];
      const toolCalls = [];

      for (const block of msg.content || []) {
        if (block.type === "text" && block.text) {
          textParts.push(truncate(block.text, 200));
        } else if (block.type === "toolCall") {
          let summary = block.toolName;
          if (block.args) {
            if (block.args.path) {
              summary += `: ${truncate(block.args.path, 100)}`;
            } else if (block.args.command) {
              summary += `: ${truncate(block.args.command, 100)}`;
            } else {
              const argsStr = JSON.stringify(block.args);
              summary += `: ${truncate(argsStr, 100)}`;
            }
          }
          toolCalls.push(summary);
        }
      }

      if (textParts.length || toolCalls.length) {
        turns.push({
          turn: turnNumber,
          role: "assistant",
          text: textParts.length ? textParts[0] : null,
          tools: toolCalls.length ? toolCalls : null,
        });
      }
    } else if (msg.role === "toolResult") {
      const hasError = (msg.content || []).some((c) => c.isError);
      if (hasError) {
        turns.push({
          turn: turnNumber,
          role: "tool_error",
          text: "Tool returned an error",
        });
      }
    }
  }

  return {
    sessionId: data.header?.id,
    timestamp: data.header?.timestamp,
    cwd: data.header?.cwd,
    turns,
  };
}

function formatForSummary(condensed) {
  const lines = [];

  lines.push(`Session: ${condensed.sessionId || "unknown"}`);
  lines.push(`Time: ${condensed.timestamp || "unknown"}`);
  lines.push(`Directory: ${condensed.cwd || "unknown"}`);
  lines.push("");
  lines.push("=== Conversation ===");
  lines.push("");

  for (const turn of condensed.turns) {
    if (turn.role === "human") {
      lines.push(`[Turn ${turn.turn}] HUMAN:`);
      lines.push(turn.text);
      lines.push("");
    } else if (turn.role === "assistant") {
      lines.push(`[Turn ${turn.turn}] ASSISTANT (condensed):`);
      if (turn.text) {
        lines.push(`  Response: ${turn.text}`);
      }
      if (turn.tools?.length) {
        lines.push(`  Tools used: ${turn.tools.join(", ")}`);
      }
      lines.push("");
    } else if (turn.role === "tool_error") {
      lines.push(`[Turn ${turn.turn}] ⚠️ Tool error occurred`);
      lines.push("");
    }
  }

  return lines.join("\n");
}

async function generateHumanSummary(data) {
  const condensed = extractForSummary(data);
  const formatted = formatForSummary(condensed);

  const prompt = `You are analyzing a coding agent session transcript. Your task is to summarize what the HUMAN did, not what the AI agent did.

Focus on:
1. What was the human's initial goal/request?
2. How many times did they have to re-prompt or steer the agent?
3. What kind of steering did they do? (corrections, clarifications, changes of direction, expressing frustration, etc.)
4. Did the human have to intervene when things went wrong?
5. How specific vs vague were their instructions?

Write a ~300 word summary in third person ("The user asked...", "They then had to clarify...").
Include a brief note about what domain/tools were involved for context, but keep focus on the human's actions and experience.

Here is the condensed session transcript:

${formatted}`;

  try {
    const result = spawnSync(
      "pi",
      [
        "--provider",
        "vercel-ai-gateway",
        "--model",
        "anthropic/claude-haiku-4.5",
        "--no-tools",
        "--no-session",
        "-p",
        prompt,
      ],
      {
        encoding: "utf-8",
        maxBuffer: 10 * 1024 * 1024,
        timeout: 60000,
      },
    );

    if (result.error) {
      throw result.error;
    }
    if (result.status !== 0) {
      throw new Error(result.stderr || "pi command failed");
    }

    return result.stdout.trim();
  } catch (err) {
    throw new Error(`Failed to generate summary: ${err.message}`);
  }
}

async function main() {
  try {
    const gistId = extractGistId(input);

    let data = null;
    if (!flags.has("--no-cache")) {
      data = readCache(gistId);
    }

    if (!data) {
      const html = await fetchSessionHtml(gistId);
      data = extractSessionData(html);
      writeCache(gistId, data);
    }

    if (flags.has("--header")) {
      console.log(JSON.stringify(data.header));
    } else if (flags.has("--entries")) {
      for (const entry of data.entries) {
        console.log(JSON.stringify(entry));
      }
    } else if (flags.has("--system")) {
      console.log(data.systemPrompt || "");
    } else if (flags.has("--tools")) {
      console.log(JSON.stringify(data.tools || []));
    } else if (flags.has("--human-summary")) {
      const summary = await generateHumanSummary(data);
      console.log(summary);
    } else {
      console.log(JSON.stringify(data));
    }
  } catch (err) {
    console.error(err.message);
    process.exit(1);
  }
}

main();
