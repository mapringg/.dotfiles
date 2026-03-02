# Initialize All Applicable Best Practices

Run all applicable init helpers for the detected stack. This workflow is accessed via `/faster` → Init → Initialize project.

## Instructions

Analyze the current repository to detect which frameworks and tools are in use, then run ALL applicable init helpers from `~/.claude/skills/faster/reference/init/helpers/`.

**This command uses parallel subagents for efficient detection.**

## How Init Helpers Work

**Init helpers live at `~/.claude/skills/faster/reference/init/helpers/init-{name}.md` and write to `.claude/rules/{name}.md`:**

1. Each init helper creates/overwrites a single file in `.claude/rules/`
2. Files use YAML frontmatter with `paths:` patterns for conditional loading
3. **ALWAYS run all applicable inits** — never skip because "file already exists"
4. Running an init overwrites with the latest content
5. **This is safe to run repeatedly** — designed to be re-run to update guidelines
6. To run an init: read `~/.claude/skills/faster/reference/init/helpers/init-{name}.md` and follow its instructions

**Why this matters:**

- Guidelines evolve over time
- Running init setup ensures all guidelines are current
- No need to check if content "matches" — just overwrite

## Phase 1: Check for Monorepo

**Before detecting frameworks, check if this is a monorepo:**

### Monorepo indicators

- `pnpm-workspace.yaml`
- `turbo.json`
- `nx.json`
- `lerna.json`
- `workspaces` field in root `package.json`
- Multiple subdirectories with their own `package.json`, `composer.json`, `go.mod`, or `Cargo.toml`
- Common monorepo directory patterns: `apps/`, `packages/`, `libs/`, `services/`

### If monorepo detected

```
This appears to be a monorepo:
  - Found: pnpm-workspace.yaml, turbo.json
  - Apps: apps/web, apps/api, apps/desktop

Monorepos need layered .claude/rules/ at each level.
Set up layered rules for each workspace? [Y/n]
```

- If user confirms → set up layered rules for each workspace (run applicable inits per workspace)
- If user declines → continue with root-level init only (will only set up root rules)

## Phase 2: Discover Available Helpers & Detect Stack

**This phase is fully dynamic — no hardcoded framework list.**

### Step 1: Scan for helpers

List all files in `~/.claude/skills/faster/reference/init/helpers/init-*.md` to discover every available init helper.

### Step 2: Read detection rules

For each discovered helper, read its `## Detection` section. This section contains:

- Files, packages, or config entries that indicate the framework is in use
- **Skip if** conditions (e.g., skip `init-react` if React Native detected)
- **AND** conditions for combo inits (e.g., `init-tanstack-cloudflare` requires both TanStack AND wrangler config)
- **Note** annotations with extra context

### Step 3: Detect frameworks in parallel

Launch **parallel subagents** to check the repository against all discovered detection rules. Group by category for efficiency:

**Subagent 1: Package manifest detection**

```
Read package.json, composer.json, Cargo.toml, go.mod, pyproject.toml,
requirements.txt, build.gradle, pom.xml, pubspec.yaml, mix.exs,
Package.swift, build.zig.zon — whatever exists.

Check for these package/dependency indicators:
[list all package-based detection rules extracted from helpers]

Return which packages were found.
```

**Subagent 2: File & directory detection**

```
Check for these files and directories:
[list all file/directory-based detection rules extracted from helpers]

Return which files/directories were found.
```

**Wait for all subagents**, then match results against each helper's detection rules to build the queue.

### Step 4: Apply skip/override rules

After building the initial queue, apply **Skip if** rules:

- If a helper says "Skip if X detected", remove it from the queue when X is also queued
- If a helper has **AND** conditions, only keep it if ALL conditions are met

## Phase 3: Check Existing State

1. **Check for `.claude/rules/` directory**: Does it exist? What files are in it?

**DO NOT check if files "already exist" or "match latest"** — just run all inits. They overwrite with current content.

### Check for Stale Rules

Look for `.claude/rules/{name}.md` files that have a corresponding `init-{name}` helper, but the framework was NOT detected in Phase 2.

If stale rules found, ask the user:

```
Found rules for tech no longer in the project:
  - .claude/rules/tauri.md — no Tauri indicators found
  - .claude/rules/vue.md — no Vue indicators found

Remove these stale files? [Y/n]
```

If confirmed, delete the stale `.claude/rules/*.md` files.

## Phase 4: Report Findings

Present to the user:

```
Detected stack:
  - React 19 (package.json)
  - Tailwind CSS v4 (package.json)
  - TanStack Query (package.json)

Will create/update:
  - .claude/rules/react.md
  - .claude/rules/tailwind.md
  - .claude/rules/tanstack-query.md

Stale rules to remove:
  - .claude/rules/vue.md (no longer in project)

Proceed? [Y/n]
```

## Phase 5: Execute

If user confirms:

1. **Create `.claude/rules/` directory** if it doesn't exist

2. **Remove stale rules first** (if any were identified)
   - Delete the stale `.claude/rules/*.md` files

3. **Execute EVERY SINGLE queued init helper in sequence**:

   For each queued init, read `~/.claude/skills/faster/reference/init/helpers/init-{name}.md` and follow its instructions to write the corresponding `.claude/rules/{name}.md` file. If no helper file exists for a detected framework, skip it and note it in the report.

   **CRITICAL: DO NOT STOP AFTER ONE INIT**

   - Execute init #1, wait for completion
   - Execute init #2, wait for completion
   - Execute init #3, wait for completion
   - ... continue until ALL inits are done

   **Order**: backend → backend extensions → frontend → utilities

   Example:

   ```
   Executing init-react... done (.claude/rules/react.md)
   Executing init-tailwind... done (.claude/rules/tailwind.md)
   Executing init-tanstack-query... done (.claude/rules/tanstack-query.md)
   All 3 inits completed.
   ```

4. **Report completion with count**: "Ran X inits, created X rule files, removed Y stale files"

**Note on auto-loading:** Rules in `.claude/rules/` with `paths:` frontmatter automatically load when you work on matching files. No `@` imports needed in CLAUDE.md — this keeps context usage low by only loading relevant rules.

## Phase 6: Suggest Next Steps

After initialization:

- Remind user to review the added content
- Suggest customizing project-specific sections in CLAUDE.md
- Note any frameworks detected but not having an init helper

## Notes

- Always ask before running commands (don't auto-execute)
- If no frameworks detected, inform user and suggest manual setup
- Order matters: backend before frontend
- If a framework is detected but uncertain, ask the user to confirm

## Adding New Helpers

To add a new init helper, just create `~/.claude/skills/faster/reference/init/helpers/init-{name}.md` with a `## Detection` section. Setup will automatically discover and use it — no need to update this file.

See [add.md](add.md) for the full workflow.

## Common Mistakes to Avoid

- **DON'T** skip an init because "the file already exists" — run it anyway, it overwrites with latest content
- **DON'T** stop after running one init — run ALL detected inits in sequence
- **DON'T** check if content "matches" before running — overwriting is the point
- **DON'T** ask "should I run init-X?" for each one — show the full list upfront, get one confirmation, run all
- **DON'T** add `@` imports to CLAUDE.md for rules with `paths:` frontmatter — let them auto-load
