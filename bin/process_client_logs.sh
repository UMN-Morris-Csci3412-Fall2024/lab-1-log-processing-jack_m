#!/bin/bash

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <directory>"
  exit 1
fi

# Check if the directory exists and is not empty
if [ ! -d "$1" ] || [ -z "$(ls -A "$1")" ]; then
  echo "Directory $1 does not exist or is empty"
  exit 1
fi

# Process the log files
find "$1" -type f -exec cat {} + | awk '
  /Failed password for invalid user/ {
    split($0, a, " ")
    split(a[3], t, ":")
    print a[1], a[2], t[1], a[11], a[13]
  }
  /Failed password for / && !/invalid user/ && !/Accepted password/ {
    split($0, a, " ")
    split(a[3], t, ":")
    print a[1], a[2], t[1], a[9], a[11]
  }
' > "$1/failed_login_data.txt"