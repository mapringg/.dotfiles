#!/bin/bash

opencode run "@PRD.json @progress.txt \
QUALITY: Production code. Must be maintainable. No shortcuts. Fight entropy. \
1. Read the PRD and progress file. \
2. Pick the task YOU determine has highest priority - not necessarily the first. \
   Prioritize: architecture > integration > unknown > feature > polish. \
3. Implement with small, focused changes. One logical change per commit. \
4. Before committing, run ALL checks (types, tests, lint). Do NOT commit if any fail. \
5. Update the PRD (set passes: true). \
6. Append to progress.txt in format: '## Iteration N\\n- Task: [desc]\\n- Decisions: [x]\\n- Files: [x]\\n- Blockers: [x]\\n- Notes: [x]'. Keep concise. \
7. Commit your changes. \
ONLY DO ONE TASK AT A TIME."
