---
name: ralph
description: Set up autonomous coding workflow. Use when asked to create a PRD, prepare for ralph, or set up AFK iteration.
---

Set up Ralph workflow for autonomous AI iteration.

## Workflow

1. **Gather context** - Ask 3-5 clarifying questions with lettered options
2. **Generate PRD.json** - Structured task array
3. **Generate prompt.md** - Iteration instructions
4. **Generate progress.txt** - Empty log

## Clarifying Questions

Ask ONLY essential questions. Examples:
- "Primary action? (A) View (B) Create/edit (C) Both (D) Other"
- "Stack? (A) Frontend (B) Backend (C) Full-stack (D) Existing patterns"
- "Tests? (A) Unit (B) Integration (C) E2E (D) All"

## PRD.json Format

```json
[
  {
    "category": "architecture",
    "description": "What this task accomplishes",
    "steps": ["Step to verify 1", "Step to verify 2"],
    "passes": false
  }
]
```

## Categories (priority order)

1. **architecture** - schemas, types, core abstractions
2. **integration** - APIs, database, external services
3. **unknown** - spikes, research, unclear requirements
4. **feature** - user-facing functionality
5. **polish** - UX improvements, refactoring, docs

## Task Sizing

**Right-sized** (one iteration):
- Add database column + migration
- Create single API endpoint
- Build one UI component
- Write tests for one module

**Too big** (split it):
- Build entire dashboard
- Full auth system
- Complete CRUD flow

**Rule**: Can't describe in 2-3 sentences? Split it.

## prompt.md

```markdown
@PRD.json @progress.txt

QUALITY: Production code. Must be maintainable. No shortcuts. Fight entropy.

1. Read the PRD and progress file.
2. Pick the task YOU determine has highest priority - not necessarily the first.
   Prioritize: architecture > integration > unknown > feature > polish.
3. Implement with small, focused changes. One logical change per commit.
4. Before committing, run ALL checks (types, tests, lint). Do NOT commit if any fail.
5. Update PRD.json: set passes: true for completed task.
6. Append to progress.txt:
   ## Iteration N
   - Task: [description]
   - Decisions: [key choices made]
   - Files: [files changed]
   - Blockers: [issues encountered]
   - Notes: [anything for future iterations]
7. Commit changes.
8. If ALL tasks pass, output: <promise>COMPLETE</promise>

ONLY WORK ON A SINGLE TASK PER ITERATION.
```

## progress.txt

```markdown
# Progress Log

## Codebase Patterns
(Patterns discovered during implementation)

## Iteration Log
```

## After Setup

Suggest workflow:
1. `git checkout -b feature/[name]`
2. `ralph-once.sh` - single iteration to calibrate
3. `ralph.sh N` - N iterations for AFK work
4. Review commits when back
5. Delete progress.txt after sprint
