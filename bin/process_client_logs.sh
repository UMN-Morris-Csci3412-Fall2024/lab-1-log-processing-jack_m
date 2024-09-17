#!/bin/bash

# Check if the directory is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <log_directory>"
    exit 1
fi

LOG_DIR="$1"
OUTPUT_FILE="$LOG_DIR/failed_login_data.txt"

# Move to the specified directory
cd "$LOG_DIR" || exit 1

# Ensure the output file is empty
> "$OUTPUT_FILE"

# Gather the contents of all the log files, extract relevant lines, and process them
grep -E "Failed password for invalid user|Failed password" *.log | awk '{print $1, $2, $3, $4, $11}' | sed 's/:[0-9][0-9]//g' > "$OUTPUT_FILE"