# Idiomatic Audit

Analyze a codebase and audit for idiomatic usage of detected languages and frameworks.

## The Core Problem

Non-idiomatic code fights against a language or framework's design philosophy, leading to harder maintenance, missed optimizations, and confusion for developers familiar with community conventions. Idiomatic code leverages built-in features and established patterns, improving readability and reducing defects.

## What This Command Detects

| Pattern | Description |
| --- | --- |
| **Language Idiom Violations** | Using non-preferred constructs for the language |
| **Framework Convention Violations** | Ignoring framework directory structure, patterns, or APIs |
| **Anti-patterns** | Reinventing framework features or using legacy patterns |
| **Performance Idiom Misses** | Missing framework-specific optimizations |
| **Consistency Issues** | Mixed paradigms or inconsistent style within the codebase |

## Phase 1: Discover the Codebase

Examine project root to identify the technology stack:

1. **Check manifest files** (in priority order):
   - `package.json` → Node.js ecosystem (check for React, Vue, Next.js, etc.)
   - `composer.json` → PHP (check for Laravel, Symfony, etc.)
   - `Cargo.toml` → Rust
   - `go.mod` → Go
   - `pyproject.toml`, `setup.py`, `requirements.txt` → Python (check for Django, FastAPI, Flask, etc.)
   - `Gemfile` → Ruby (check for Rails, Sinatra, etc.)
   - `*.csproj`, `*.sln` → .NET/C#
   - `build.gradle`, `pom.xml` → Java/Kotlin (check for Spring, etc.)
   - `pubspec.yaml` → Dart/Flutter
   - `mix.exs` → Elixir/Phoenix
   - `Package.swift` → Swift

2. **Check config files** for framework signals:
   - `artisan`, `config/app.php` → Laravel
   - `next.config.*` → Next.js
   - `nuxt.config.*` → Nuxt
   - `vite.config.*`, `vue.config.*` → Vue
   - `tailwind.config.*` → Tailwind CSS
   - `tsconfig.json` → TypeScript

3. **Sample source files** to confirm language usage and detect patterns.

4. **Check for existing guidelines** in `.claude/rules/` — note any that may conflict with or supplement community idioms.

**Output**: Create a stack summary listing primary language, framework(s), and notable tools.

## Phase 2: Parallel Audit (Using Subagents)

**Launch 5 subagents in parallel.** See [idiomatic-subagents.md](idiomatic-subagents.md) for detailed prompts.

| Subagent | Focus |
| --- | --- |
| 1 | Language idioms (preferred constructs, error handling, type usage) |
| 2 | Framework conventions (directory structure, component patterns, routing, ORM) |
| 3 | Anti-patterns (reinventing framework features, legacy patterns, ignored conventions) |
| 4 | Performance idioms (framework-specific optimizations, memory/resource management) |
| 5 | Consistency (inconsistent style within the codebase, mixed paradigms) |

Pass tech stack and existing guidelines from Phase 1 to each subagent.

## Phase 3: Prioritize Findings

| Priority | Issue | Rationale |
| --- | --- | --- |
| **P1 Critical** | Core idiom violation causing bugs | Incorrect usage that leads to errors |
| **P2 High** | Framework convention violation | Missed optimizations, maintainability risk |
| **P3 Medium** | Non-idiomatic patterns | Works but not best practice |
| **P4 Low** | Style preferences | Minor readability improvements |

## Phase 4: Present Findings

```markdown
## Idiomatic Audit Results

### Stack Detected
- **Language**: [language + version if detectable]
- **Framework**: [framework(s)]
- **Notable Tools**: [build tools, linters, etc.]

### Summary
- X language idiom violations
- X framework convention violations
- X anti-patterns
- X performance idiom misses
- X consistency issues

### Guideline Conflicts
[If .claude/rules/ exists, note any intentional deviations from community idioms]

### P1 Critical
| Issue | Location | Current | Idiomatic |
|-------|----------|---------|-----------|
| ... | file:line | ... | ... |

### P2 High
...
```

## Phase 5: Fix Options

1. **Fix critical only** — Address idiom violations causing bugs
2. **Fix critical + high** — Include framework convention fixes
3. **Fix all** — Apply all idiomatic improvements
4. **Report only** — Just the audit, no changes

When fixing: show before/after with idiomatic alternative, explain the benefit.

## Notes

- Be specific: cite file paths and line numbers
- Explain why: describe the idiomatic alternative and its benefits
- Respect context: some "non-idiomatic" choices may be intentional
- Consider consistency: existing patterns in the codebase may take precedence over general idioms
- Defer to project rules: if `.claude/rules/` contradicts an idiom, note it but don't flag as a violation
