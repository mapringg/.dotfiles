# ISSUES

Local issue files from `.scratch/` and recent commits are provided above in `<issues>` and `<recent-commits>` blocks. Parse them to understand the open issues and prior work.

You will work on the AFK issues only, not the HITL ones.

If all AFK tasks are complete, output <promise>NO MORE TASKS</promise>.

# TASK SELECTION

Pick the next task. Prioritize tasks in this order:

1. Critical bugfixes
2. Development infrastructure

Getting development infrastructure like tests and types and dev scripts ready is an important precursor to building features.

3. Tracer bullets for new features

Tracer bullets are small slices of functionality that go through all layers of the system, allowing you to test and validate your approach early. This helps in identifying potential issues and ensures that the overall architecture is sound before investing significant time in development.

TL;DR - build a tiny, end-to-end slice of the feature first, then expand it out.

4. Polish and quick wins
5. Refactors

# EXPLORATION

Explore the repo and fill your context window with relevant information that will allow you to complete the task. Pay extra attention to test files that touch the relevant parts of the code.

# IMPLEMENTATION

Use /tdd to complete the task.

# FEEDBACK LOOPS

Before committing, run the feedback loops:

- `npm run test` to run the tests
- `npm run typecheck` to run the type checker

# COMMIT

Make a git commit. The commit message must:

1. Start with `AFK:` prefix
2. Include key decisions made
3. Include files changed
4. Blockers or notes for next iteration

# THE ISSUE

If the task is complete, move the issue file to `.scratch/done/`.

If the task is not complete, add a note to the issue file with what was done.

# FINAL RULES

ONLY WORK ON A SINGLE TASK.
