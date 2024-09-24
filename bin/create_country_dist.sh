#!/bin/bash

# Check if the directory argument is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <directory>"
    exit 1
fi

input_dir=$1
output_file="$input_dir/country_dist.html"

# Check if the header and footer files exist in the html_components directory
header_file="html_components/country_dist_header.html"
footer_file="html_components/country_dist_footer.html"

if [ ! -f "$header_file" ]; then
  echo "$0: Header file $header_file does not exist."
  exit 1
fi

if [ ! -f "$footer_file" ]; then
  echo "$0: Footer file $footer_file does not exist."
  exit 1
fi

# Temporary files to hold intermediate data
temp_file=$(mktemp)
temp_file_countries=$(mktemp)
temp_file_data=$(mktemp)

echo "Temporary files created: $temp_file, $temp_file_countries, $temp_file_data"

# Extract IP addresses from failed_login_data.txt files
echo "Extracting IP addresses from failed_login_data.txt files..."
find "$input_dir" -type f -name "failed_login_data.txt" -exec awk '{print $5}' {} + > "$temp_file"
echo "IP addresses extracted to: $temp_file"

# Sort IP addresses and join with country_IP_map.txt to get country codes
echo "Sorting IP addresses and joining with country_IP_map.txt to get country codes..."
sort "$temp_file" | join -1 1 -2 1 -o 2.2 - <(sort etc/country_IP_map.txt) > "$temp_file_countries"
echo "Country codes obtained and stored in: $temp_file_countries"

# Count occurrences of each country code
echo "Counting occurrences of each country code..."
sort "$temp_file_countries" | uniq -c | awk '{print "data.addRow([\x27"$2"\x27, "$1"]);"}' > "$temp_file_data"
echo "Country code occurrences counted and stored in: $temp_file_data"

# Create the header and footer content
header_content=$(mktemp)
footer_content=$(mktemp)

{
  echo "<!-- ++++++++++++ START OF COUNTRY HEADER +++++++++++++++++++++++++++++++ -->"
  echo "google.setOnLoadCallback(drawCountryDistribution);"
  echo "function drawCountryDistribution() {"
  echo "  var data = new google.visualization.DataTable();"
  echo "  data.addColumn('string', 'Country');"
  echo "  data.addColumn('number', 'Number of failed logins');"
  echo "<!-- ++++++++++++ END OF COUNTRY HEADER +++++++++++++++++++++++++++++++ -->"
} > "$header_content"

{
  echo "<!-- ++++++++++++ START OF COUNTRY FOOTER +++++++++++++++++++++++++++++++ -->"
  echo "  var chart = new google.visualization.GeoChart(document.getElementById('country_dist_div'));"
  echo "  chart.draw(data, {width: 800, height: 500, title: 'Failed logins by country'});"
  echo "}"
  echo "<!-- ++++++++++++ END OF COUNTRY FOOTER +++++++++++++++++++++++++++++++ -->"
} > "$footer_content"

# Wrap the data with header and footer using wrap_contents.sh
echo "Wrapping the data with header and footer using wrap_contents.sh..."
./bin/wrap_contents.sh "$temp_file_data" "$header_content" "$footer_content" "$output_file"
echo "Data wrapped and output file created: $output_file"

# Check if the output file was created successfully
if [ ! -f "$output_file" ]; then
  echo "$0: Error: Output file $output_file was not created."
  exit 1
fi

# Clean up temporary files
echo "Cleaning up temporary files..."
rm "$temp_file" "$temp_file_countries" "$temp_file_data" "$header_content" "$footer_content"
echo "Temporary files removed."

echo "Output written to $output_file"