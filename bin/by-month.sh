
#!/bin/bash

# Check if a month argument is provided
if [ -z "$1" ]; then
    echo "Please provide a month in the format MM (e.g., 03 for March)"
    exit 1
fi

# Get the current year
year=$(date +%Y)

# Construct the date range for the given month
start_date="$year-$1-01"
end_date=$(date -d "$start_date +1 month" +%Y-%m-%d)

# Check if we're in a Git repository
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "Error: Not in a Git repository"
    exit 1
fi

# Determine the sort order
sort_order="--reverse"
if [ "$2" == "-c" ]; then
    sort_order=""
fi

# Determine the log format
log_format="%s"
if [ "$2" == "-t" ]; then
    log_format="%ad"
    date_format="--date=format:%m-%d-%Y"
else
    date_format=""
fi

# Get the current user's Git email
author_email=$(git config user.email)

# Get the commits by the current user
commits=$(git log $sort_order --since="$start_date" --until="$end_date" --no-merges --author="$author_email" --format="$log_format" $date_format 2>/dev/null)

# Check if git log command was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to retrieve Git commits"
    exit 1
fi

# Check if any commits were found
if [ -z "$commits" ]; then
    echo "No commits found for $1 $year"
    exit 0
fi

# Copy to clipboard based on OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "$commits" | pbcopy
    echo "Commits for $1 $year have been copied to clipboard"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if command -v wl-copy &> /dev/null; then
        echo "$commits" | wl-copy
        echo "Commits for $1 $year have been copied to clipboard"
    else
        echo "Error: wl-copy is not installed. Please install wl-clipboard first." >&2
        exit 1
    fi
else
    echo "Error: Unsupported operating system" >&2
    exit 1
fi
