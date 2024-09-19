#!/bin/bash

# Check if the input directory is provided as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 <input_directory>"
  exit 1
fi

input_dir="$1"

# Temporary file to hold the data rows
temp_file=$(mktemp)

# Process each sub-directory
for sub_dir in "$input_dir"/*; do
  if [ -d "$sub_dir" ]; then
    failed_login_file="$sub_dir/failed_login_data.txt"
    if [ -f "$failed_login_file" ]; then
      echo "Processing $failed_login_file"
      # Extract the username column, sort, and count occurrences
      awk '{print $4}' "$failed_login_file" | sort | uniq -c | \
      awk '{print "data.addRow([\x27" $2 "\x27, " $1 "]);"}' >> "$temp_file"
    else
      echo "File $failed_login_file does not exist"
    fi
  else
    echo "Directory $sub_dir does not exist"
  fi
done

# Combine the header, data rows, and footer
{
  cat "$input_dir/username_dist_header.html"
  cat "$temp_file"
  cat "$input_dir/username_dist_footer.html"
} > "$input_dir/username_dist.html"

# Clean up the temporary file
rm "$temp_file"

echo "Output written to $input_dir/username_dist.html"