#!/bin/bash

# Check if the input directory is provided as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 <input_directory>"
  exit 1
fi

input_dir="$1"
output_file="$input_dir/username_dist.html"  # Set the output file to the input directory

# Check if the header and footer files exist in the html_components directory
header_file="html_components/username_dist_header.html"
footer_file="./html_components/username_dist_footer.html"

# if [ ! -f "$header_file" ]; then
#   echo "Header file $header_file does not exist."
#   exit 1
# fi

# if [ ! -f "$footer_file" ]; then
#   echo "Footer file $footer_file does not exist."
#   exit 1
# fi

# Temporary file to hold the data rows
temp_file=$(mktemp)

# Find all failed login attempts and process them
find "$input_dir" -type f -name "failed_login_data.txt" -exec cat {} + | \
awk '{print $4}' | sort | uniq -c | \
awk '{print "data.addRow([\x27" $2 "\x27, " $1 "]);"}' > "$temp_file"

# Use wrap_contents.sh to add the header and footer
./bin/wrap_contents.sh "$temp_file" "username_dist" "$output_file"

# Check if the output file was created successfully
if [ ! -f "$output_file" ]; then
  echo "Error: Output file $output_file was not created."
  exit 1
fi

# Clean up the temporary file
rm "$temp_file"

echo "Output written to $output_file"