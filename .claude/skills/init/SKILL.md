---
name: init
disable-model-invocation: true
description: Initialize project rules for your detected stack, or manage init helpers (create, update, reconcile, research). Use '/init' to get started.
argument-hint: "[topic]"
---

# Init

Set up project rules or manage init helpers.

## Instructions

**Always ask the user what they want to do.** Use `AskUserQuestion` with these options:

- **Question**: "What would you like to do?"
- **Options**:
  1. **Initialize project** — "Detect your stack and set up all framework rules"
  2. **Create new init** — "Add a helper for a framework we don't support yet"
  3. **Update an init** — "Add learnings or new content to an existing init helper"
  4. **Reconcile** — "Sync local project rules with master init helpers (two-way)"

If `$ARGUMENTS` contains a URL or mentions "research", also offer:
  5. Research options as appropriate

## After User Chooses

Read the corresponding file and follow its instructions:

| Choice | Read this file |
|--------|---------------|
| Initialize project | [setup.md](setup.md) |
| Create new init | [add.md](add.md) |
| Update an init | [update.md](update.md) |
| Reconcile | [reconcile.md](reconcile.md) |
| Research frameworks | [research.md](research.md) |
| Research from URL | [research-url.md](research-url.md) |

Pass any `$ARGUMENTS` through to the action file.
