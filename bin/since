#!/bin/bash

# Check if a date argument is provided
if [ -z "$1" ]; then
    echo "Please provide a date in the format YYYY-MM-DD"
    exit 1
fi

# Check if we're in a Git repository
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "Error: Not in a Git repository"
    exit 1
fi

# Get the commits
commits=$(git log --since="$1" --no-merges --format="%s" 2>/dev/null)

# Check if git log command was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to retrieve Git commits"
    exit 1
fi

# Check if any commits were found
if [ -z "$commits" ]; then
    echo "No commits found since $1"
    exit 0
fi

# Copy to clipboard based on OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "$commits" | pbcopy
    echo "Commits since $1 have been copied to clipboard"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if command -v wl-copy &> /dev/null; then
        echo "$commits" | wl-copy
        echo "Commits since $1 have been copied to clipboard"
    else
        echo "Error: wl-copy is not installed. Please install wl-clipboard first." >&2
        exit 1
    fi
else
    echo "Error: Unsupported operating system" >&2
    exit 1
fi
