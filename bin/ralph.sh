#!/bin/bash
set -e

if [ -z "$1" ]; then
	echo "Usage: $0 <iterations>"
	exit 1
fi

for ((i = 1; i <= $1; i++)); do
	result=$(opencode run "@PRD.json @progress.txt \
  QUALITY: Production code. Must be maintainable. No shortcuts. Fight entropy. \
  1. Pick the task YOU determine has highest priority - not necessarily the first. \
     Prioritize: architecture > integration > unknowns > features > polish. \
  2. Implement with small, focused changes. One logical change per commit. \
  3. Before committing, run ALL checks (types, tests, lint). Do NOT commit if any fail. \
  4. Update the PRD (set passes: true). \
  5. Append to progress.txt: Task, Decisions, Files changed. Keep concise. \
  6. Commit your changes. \
  ONLY WORK ON A SINGLE TASK. \
  If the PRD is complete, output <promise>COMPLETE</promise>.")

	echo "$result"

	if [[ "$result" == *"<promise>COMPLETE</promise>"* ]]; then
		echo "PRD complete after $i iterations."
		exit 0
	fi
done
