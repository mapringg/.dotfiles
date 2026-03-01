---
name: ship
description: Ships your work — runs tests, cleans up code, and commits. Use when you're done with a feature, fix, or any piece of work you want to commit.
---

# Ship

Finalize and ship your recent work.

## Instructions

**Always ask the user what they want to do.** Use `AskUserQuestion`:

- **Question**: "What do you want to ship?"
- **Options**:
  1. **Full pipeline** — "Run tests, clean up false starts, then commit"
  2. **Skip tests** — "Clean up and commit without running tests"
  3. **Just commit** — "Generate a commit message and commit"

## After User Chooses

Execute the chosen steps sequentially. Read the corresponding files and follow their instructions completely before moving to the next step.

### Full pipeline

1. Read and follow [tests.md](reference/tests.md)
2. Read and follow [finalize.md](reference/finalize.md)
3. Read and follow [commit.md](reference/commit.md)

### Skip tests

1. Read and follow [finalize.md](reference/finalize.md)
2. Read and follow [commit.md](reference/commit.md)

### Just commit

1. Read and follow [commit.md](reference/commit.md)
