#!/bin/bash

if [ "$#" -ne 3 ]; then
  echo "Usage: $0 <middle_file> <specifier> <output_file>"
  exit 1
fi

middle_file=$1
specifier=$2
output_file=$3

header_file="${specifier}_header.html"
footer_file="${specifier}_footer.html"

if [ ! -f "$middle_file" ]; then
  echo "Middle file $middle_file does not exist."
  exit 1
fi

if [ ! -f "$header_file" ]; then
  echo "Header file $header_file does not exist."
  exit 1
fi

if [ ! -f "$footer_file" ]; then
  echo "Footer file $footer_file does not exist."
  exit 1
fi

{
  cat "$header_file"
  cat "$middle_file"
  cat "$footer_file"
} > "$output_file"