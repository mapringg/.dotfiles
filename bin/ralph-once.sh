#!/bin/bash

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

echo "=== Single Iteration (HITL Mode) ==="
cat prompt.md | opencode run -
