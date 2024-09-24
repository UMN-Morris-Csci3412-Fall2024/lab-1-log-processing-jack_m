#!/bin/bash

# Check if the directory argument is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <directory>"
    exit 1
fi

input_dir=$1
output_file="$input_dir/failed_login_summary.html"

# Check if the required files exist
country_file="$input_dir/country_dist.html"
hours_file="$input_dir/hours_dist.html"
username_file="$input_dir/username_dist.html"
header_file="$input_dir/summary_header.html"
footer_file="html_components/summary_footer.html"

if [ ! -f "$country_file" ]; then
  echo "$0: Country distribution file $country_file does not exist."
  exit 1
fi

if [ ! -f "$hours_file" ]; then
  echo "$0: Hours distribution file $hours_file does not exist."
  exit 1
fi

if [ ! -f "$username_file" ]; then
  echo "$0: Username distribution file $username_file does not exist."
  exit 1
fi

if [ ! -f "$header_file" ]; then
  echo "$0: Header file $header_file does not exist."
  exit 1
fi

if [ ! -f "$footer_file" ]; then
  echo "$0: Footer file $footer_file does not exist."
  exit 1
fi

# Temporary file to hold the combined content
temp_file=$(mktemp)
echo "Temporary file created: $temp_file"

# Concatenate the contents of the three HTML files
echo "Concatenating the contents of the three HTML files..."
cat "$country_file" "$hours_file" "$username_file" > "$temp_file"

# Use wrap_contents.sh to add the overall HTML header and footer
echo "Wrapping the combined content with the overall HTML header and footer..."
./bin/wrap_contents.sh "$temp_file" "$header_file" "$footer_file" "$output_file"
echo "Report created: $output_file"

# Clean up the temporary file
echo "Cleaning up temporary file..."
rm "$temp_file"
echo "Temporary file removed."