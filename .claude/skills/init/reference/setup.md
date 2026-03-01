# Initialize All Applicable Best Practices

Run all applicable init helpers for the detected stack.

## Instructions

Analyze the current repository to detect which frameworks and tools are in use, then run ALL applicable init helpers from `~/.claude/skills/init/helpers/`.

**This command uses parallel subagents for efficient detection.**

## How Init Helpers Work

**Init helpers live at `~/.claude/skills/init/helpers/init-{name}.md` and write to `.claude/rules/{name}.md`:**

1. Each init helper creates/overwrites a single file in `.claude/rules/`
2. Files use YAML frontmatter with `paths:` patterns for conditional loading
3. **ALWAYS run all applicable inits** — never skip because "file already exists"
4. Running an init overwrites with the latest content
5. **This is safe to run repeatedly** — designed to be re-run to update guidelines
6. To run an init: read `~/.claude/skills/init/helpers/init-{name}.md` and follow its instructions

**Why this matters:**

- Guidelines evolve over time
- Running `/init` ensures all guidelines are current
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
Run `/init-monorepo` instead? [Y/n]
```

- If user confirms → set up layered rules for each workspace (if `/init-monorepo` exists, run it; otherwise handle manually)
- If user declines → continue with `/init` (will only set up root rules)

## Phase 2: Detect Stack

Check for these indicators:

### Laravel

- `artisan` file in root
- `composer.json` with `laravel/framework`
- `app/Http/Controllers/` directory
- **If found**: Queue `init-laravel-app`

### Laravel Package

- `src/` directory exists
- `composer.json` with `orchestra/testbench` in require-dev
- **If found**: Queue `init-laravel-app-package`
- **Note**: Skip `init-laravel-app` if Laravel Package detected (different patterns)

### Filament

- `composer.json` with `filament/filament`
- `app/Filament/` directory
- **If found**: Queue `init-filament`

### Livewire

- `composer.json` with `livewire/livewire`
- `app/Livewire/` directory or `resources/views/livewire/`
- **If found**: Queue `init-livewire`

### Inertia.js

- `composer.json` with `inertiajs/inertia-laravel`
- `package.json` with `@inertiajs/vue3` or `@inertiajs/react`
- `HandleInertiaRequests.php` middleware
- **If found**: Queue `init-inertia`

### Spring Boot

- `pom.xml` with `spring-boot-starter` dependencies
- `build.gradle` or `build.gradle.kts` with `org.springframework.boot` plugin
- `src/main/java/` directory structure
- `application.yml` or `application.properties` in `src/main/resources/`
- **If found**: Queue `init-spring-boot`

### Vue

- `package.json` with `vue` (v3+)
- `.vue` files in `src/` or `resources/js/`
- `vite.config.*` with Vue plugin
- **If found**: Queue `init-vue`

### React

- `package.json` with `react` (v18+/v19+)
- `.tsx` or `.jsx` files in `src/`
- `vite.config.*` or `next.config.*` with React
- **If found**: Queue `init-react`
- **Note**: If Next.js detected, mention that init-react assumes client components only

### Base UI

- `package.json` with `@base-ui/react`
- Files importing from `@base-ui/react/*`
- **If found**: Queue `init-baseui`
- **Note**: Base UI is a headless component library; typically used alongside React

### React Native

- `package.json` with `react-native`
- `metro.config.js` or `metro.config.ts`
- `android/` and `ios/` directories
- `app.json` with `expo` or React Native config
- **If found**: Queue `init-react-native`
- **Note**: Skip `init-react` if React Native detected (different patterns)

### Tauri

- `src-tauri/` directory
- `tauri.conf.json`
- `Cargo.toml` with `tauri`
- **If found**: Queue `init-tauri`

### NativePHP Desktop

- `composer.json` with `nativephp/desktop`
- `config/nativephp.php` file
- `app/Providers/NativeAppServiceProvider.php`
- **If found**: Queue `init-nativephp-desktop`

### Go CLI (Cobra)

- `go.mod` file present
- `github.com/spf13/cobra` in go.mod dependencies
- **If found**: Queue `init-go-cli`
- **Note**: Skip if Charm (Bubble Tea) detected (use `init-charm` for TUI apps instead)

### Charm (Bubble Tea)

- `go.mod` with `github.com/charmbracelet/bubbletea`
- `github.com/charmbracelet/lipgloss`
- `github.com/charmbracelet/huh`
- **If found**: Queue `init-charm`
- **Note**: If both Cobra and Charm detected, use `init-charm` (TUI patterns supersede basic CLI)

### libvaxis (Zig TUI)

- `build.zig.zon` with `libvaxis` dependency
- `.zig` files with `\@import("vaxis")` or `\@import("vxfw")`
- **If found**: Queue `init-zig-libvaxis`

### Tailwind CSS

- `package.json` with `tailwindcss` or `@tailwindcss/vite` or `@tailwindcss/postcss`
- `tailwind.config.js` or `tailwind.config.ts` (v3) or CSS file with `\@import "tailwindcss"` (v4)
- `postcss.config.*` with tailwindcss plugin
- **If found**: Queue `init-tailwind`

### Ink (React CLI)

- `package.json` with `ink`
- `.tsx` files with Ink imports (`import { Box, Text } from 'ink'`)
- **If found**: Queue `init-ink`
- **Note**: Skip `init-react` if Ink detected (different patterns for CLI vs web)

### TanStack Query

- `package.json` with `@tanstack/react-query`
- Files importing from `@tanstack/react-query` (useQuery, useMutation)
- **If found**: Queue `init-tanstack-query`

### Tauri + TanStack Query + Specta

- `src-tauri/` directory (Tauri detected)
- **AND** `package.json` with `@tanstack/react-query`
- **AND** `Cargo.toml` with `tauri-specta` or `specta` in dependencies
- **If found**: Queue `init-tauri-tanstack-specta`
- **Note**: This is a combo init for the integration glue; also queue `init-tauri` and `init-tanstack-query` separately

### TanStack (Start/Router)

- `package.json` with `@tanstack/react-start` or `@tanstack/react-router`
- **If found**: Queue `init-tanstack`

### TanStack + Cloudflare

- `wrangler.jsonc` or `wrangler.toml` present
- **AND** `package.json` with `@tanstack/react-start` or `@tanstack/react-router`
- **If found**: Queue `init-tanstack-cloudflare`

### Cloudflare Durable Objects

- `wrangler.jsonc` or `wrangler.toml` with `durable_objects` configuration
- `.ts` files extending `DurableObject` from `cloudflare:workers`
- Files using `DurableObjectNamespace` or `ctx.acceptWebSocket()`
- **If found**: Queue `init-cloudflare-durable-object`

### MCP TypeScript

- `package.json` with `@modelcontextprotocol/sdk`
- `.ts` files importing from `@modelcontextprotocol/sdk`
- **If found**: Queue `init-mcp-typescript`

### Motion Canvas (4K Animation)

- `package.json` with `@motion-canvas/core` or `@motion-canvas/2d`
- `src/project.ts` with `makeProject` import
- **If found**: Queue `init-motion4k`

### Swift (Base)

- `Package.swift` or `*.xcodeproj`/`*.xcworkspace` present
- Any `.swift` files in the project
- **If found**: Queue `init-swift` (universal Swift guidelines)
- **Then**: Check for SwiftUI and/or AppKit below

### SwiftUI

- Swift project detected (above)
- Any `.swift` file contains `import SwiftUI`
- **If found**: Queue `init-swift-swiftui`
- **Note**: Requires `init-swift` to run first

### AppKit

- Swift project detected (above)
- Any `.swift` file contains `import AppKit`
- **If found**: Queue `init-swift-appkit`
- **Note**: Requires `init-swift` to run first; if both SwiftUI and AppKit detected, run both

### PySide6 (Qt for Python)

- `requirements.txt` or `pyproject.toml` with `PySide6`
- `.py` files with `from PySide6` imports
- **If found**: Queue `init-pyside6`

### Dockerfile

- `Dockerfile` or `Dockerfile.*` in root or subdirectories
- `docker-compose.yml` or `docker-compose.yaml`
- `.dockerignore` file
- **If found**: Queue `init-dockerfile`

### Swift-RS FFI

- `Cargo.toml` with `swift-rs` in dependencies
- `swift-lib/` or similar Swift package directory alongside `src-tauri/`
- `build.rs` with `SwiftLinker` usage
- **If found**: Queue `init-swift-rs-ffi`
- **Note**: Typically used with Tauri; queue after `init-tauri`

### Parallel Detection Strategy

To speed up detection, launch **parallel subagents** using the `Agent` tool with `subagent_type=Explore`:

**Subagent 1: Backend Detection**

```
Detect backend frameworks in this repository.

Check for:
- Laravel: artisan file, composer.json with laravel/framework, app/Http/Controllers/
- Laravel Package: src/ + orchestra/testbench in composer.json
- Filament: composer.json with filament/filament, app/Filament/
- Livewire: composer.json with livewire/livewire, app/Livewire/
- Inertia: composer.json with inertiajs/inertia-laravel
- Spring Boot: pom.xml with spring-boot-starter, build.gradle with org.springframework.boot, src/main/java/, application.yml or application.properties

Return list of detected frameworks with evidence.
```

**Subagent 2: Frontend Detection**

```
Detect frontend frameworks in this repository.

Check for:
- Vue: package.json with vue (v3+), .vue files
- React: package.json with react (v18+/v19+), .tsx/.jsx files
- React Native: package.json with react-native, metro.config.*, android/ + ios/
- Base UI: package.json with @base-ui/react
- Tailwind: package.json with tailwindcss, tailwind.config.* or CSS with \@import "tailwindcss"
- TanStack Query: package.json with @tanstack/react-query
- MCP TypeScript: package.json with @modelcontextprotocol/sdk
- Motion Canvas: package.json with @motion-canvas/core or @motion-canvas/2d

Return list of detected frameworks with evidence.
```

**Subagent 3: Desktop/CLI Detection**

```
Detect desktop and CLI frameworks in this repository.

Check for:
- Tauri: src-tauri/, tauri.conf.json, Cargo.toml with tauri
- NativePHP Desktop: composer.json with nativephp/desktop, config/nativephp.php
- Go CLI (Cobra): go.mod with github.com/spf13/cobra
- Charm (Bubble Tea): go.mod with github.com/charmbracelet/bubbletea
- libvaxis (Zig TUI): build.zig.zon with libvaxis dependency
- Ink: package.json with ink
- PySide6: requirements.txt or pyproject.toml with PySide6

Return list of detected frameworks with evidence.
```

**Subagent 4: Swift Detection**

```
Detect Swift frameworks in this repository.

Check for:
- Swift base: Package.swift or *.xcodeproj/*.xcworkspace, .swift files
- SwiftUI: .swift files with import SwiftUI
- AppKit: .swift files with import AppKit
- Swift-RS FFI: Cargo.toml with swift-rs, build.rs with SwiftLinker

Return list of detected frameworks with evidence.
```

**Wait for all subagents to complete**, then merge results and proceed to Phase 3.

## Phase 3: Check Existing State

1. **Check for `.claude/rules/` directory**: Does it exist? What files are in it?
2. **Check for CLAUDE.md, AGENTS.md, GEMINI.md**: Do they exist?

**DO NOT check if files "already exist" or "match latest"** — just run all inits. They overwrite with current content.

### Check for Stale Rules

Look for `.claude/rules/{name}.md` files for tech that's NO LONGER in the project:

- `.claude/rules/tauri.md` but no `src-tauri/` directory
- `.claude/rules/react.md` but no React in package.json
- `.claude/rules/laravel.md` but no `artisan` file
- `.claude/rules/vue.md` but no Vue in package.json
- etc.

If stale rules found, ask the user:

```
Found rules for tech no longer in the project:
  - .claude/rules/tauri.md — no src-tauri/ directory found
  - .claude/rules/vue.md — no Vue in package.json

Remove these stale files? [Y/n]
```

If confirmed, delete the stale `.claude/rules/*.md` files.

## Phase 4: Report Findings

Present to the user:

```
Detected stack:
  - Laravel 11 (composer.json)
  - Filament v3 (composer.json)
  - Vue 3 (package.json)

Will create/update:
  - .claude/rules/laravel.md
  - .claude/rules/filament.md
  - .claude/rules/vue.md

Stale rules to remove:
  - .claude/rules/tauri.md (no longer in project)

Proceed? [Y/n]
```

## Phase 5: Execute

If user confirms:

1. **Create `.claude/rules/` directory** if it doesn't exist

2. **Remove stale rules first** (if any were identified)
   - Delete the stale `.claude/rules/*.md` files

3. **Execute EVERY SINGLE queued init helper in sequence**:

   For each queued init, read `~/.claude/skills/init/helpers/init-{name}.md` and follow its instructions to write the corresponding `.claude/rules/{name}.md` file. If no helper file exists for a detected framework, skip it and note it in the report.

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

4. **Run the built-in `/init` command**
   - This sets up the foundational CLAUDE.md file
   - Running after framework inits means `/init` can be aware of what's in `.claude/rules/`
   - Avoids duplicate content between CLAUDE.md and framework-specific rules

5. **Report completion with count**: "Ran X inits, created X rule files, removed Y stale files"

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
- If a framework is detected but no init helper exists at `~/.claude/skills/init/helpers/init-{name}.md`, note this in the report (e.g., "Detected Next.js but no init-nextjs helper available")

## Common Mistakes to Avoid

- **DON'T** skip an init because "the file already exists" — run it anyway, it overwrites with latest content
- **DON'T** stop after running one init — run ALL detected inits in sequence
- **DON'T** check if content "matches" before running — overwriting is the point
- **DON'T** ask "should I run init-X?" for each one — show the full list upfront, get one confirmation, run all
- **DON'T** add `@` imports to CLAUDE.md for rules with `paths:` frontmatter — let them auto-load
