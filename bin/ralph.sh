#!/bin/bash
set -e

MAX_ITERATIONS=${1:-10}

if [ ! -f "PRD.json" ]; then
	echo "Error: PRD.json not found. Run the 'prd' skill first."
	exit 1
fi

if [ ! -f "prompt.md" ]; then
	echo "Error: prompt.md not found. Run the 'ralph' skill first."
	exit 1
fi

# Initialize progress.txt if missing
if [ ! -f "progress.txt" ]; then
	echo -e "# Progress Log\n\n## Codebase Patterns\n\n## Iteration Log" >progress.txt
fi

for ((i = 1; i <= MAX_ITERATIONS; i++)); do
	echo "=== Iteration $i of $MAX_ITERATIONS ==="

	# Fresh context each iteration - read prompt.md and pipe to opencode
	result=$(cat prompt.md | opencode run -) || true

	echo "$result"

	if [[ "$result" == *"<promise>COMPLETE</promise>"* ]]; then
		echo ""
		echo "PRD complete after $i iterations."
		exit 0
	fi
done

echo ""
echo "Reached max iterations ($MAX_ITERATIONS). Review progress.txt and continue if needed."
