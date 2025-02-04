#!/bin/bash

# Check if required commands are installed
for cmd in fzf fd; do
    if ! command -v $cmd &> /dev/null; then
        echo "Error: $cmd is not installed. Please install it first." >&2
        exit 1
    fi
done

# Function to copy to clipboard based on OS
copy_to_clipboard() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        pbcopy
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v wl-copy &> /dev/null; then
            wl-copy
        else
            echo "Error: wl-copy is not installed. Please install wl-clipboard first." >&2
            exit 1
        fi
    else
        echo "Error: Unsupported operating system" >&2
        exit 1
    fi
}

# Function to process a single file
process_file() {
    local file_path="$1"

    # Check if the file exists
    if [ ! -f "$file_path" ]; then
        echo "Error: File not found: $file_path" >&2
        return 1
    fi

    # Extract the file extension
    local extension="${file_path##*.}"

    # Output the filename as a header
    echo "### File: $file_path"

    # Output the opening triple backticks with the file extension
    echo '```'"$extension"

    # Read and output the file content
    cat "$file_path" || {
        echo "Error: Unable to read file: $file_path" >&2
        return 1
    }

    # Output the closing triple backticks on a new line
    echo
    echo '```'

    # Add a newline for separation
    echo
}

# Use fd to find files and directories, sort them by last modified time, then use fzf to select
selected_items=$(fd -t f -t d -0 | xargs -0 ls -td | fzf --multi)

# Check if any items were selected
if [ -z "$selected_items" ]; then
    echo "No items selected. Exiting."
    exit 0
fi

# Process each selected item and store the output
output=$(echo "$selected_items" | while read -r item; do
    if [ -d "$item" ]; then
        # If it's a directory, process all files in it
        find "$item" -type f | while read -r file; do
            process_file "$file"
        done
    else
        # If it's a file, process it directly
        process_file "$item"
    fi
done)

# Copy the output to clipboard
echo "$output" | copy_to_clipboard

# Also print the output to the terminal
echo "$output"

echo "Output has been copied to clipboard."
