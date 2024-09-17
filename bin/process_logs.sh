#!/bin/bash

# Create a temporary directory
temp_dir=$(mktemp -d)

# Check if the temporary directory was created
if [[ ! "$temp_dir" || ! -d "$temp_dir" ]]; then
    echo "Could not create temp dir"
    exit 1
fi

# Function to clean up the temporary directory
function cleanup {
    rm -rf "$temp_dir"
    echo "Deleted temp working directory $temp_dir"
}

# Register the cleanup function to be called on the EXIT signal
trap cleanup EXIT

# Loop over each .tgz file in the current directory
for tar_file in *.tgz; 
do
    # Check if there are no .tgz files
    if [ "$tar_file" == "*.tgz" ]; then
        echo "No .tgz files found"
        break
    fi

    # Extract the tar file into the temporary directory
    tar -xzf "$tar_file" -C "$temp_dir"
    
    # Perform operations on the extracted files
    echo "Processing $tar_file"
    
    # Call process_client_logs.sh on the extracted files
    ./process_client_logs.sh "$temp_dir"

    # Call create_hours_dist.sh on the extracted files
    ./create_hours_dist.sh "$temp_dir"

    # Call create_country_dist.sh on the extracted files
    ./create_country_dist.sh "$temp_dir"

    # Call assemble_report.sh on the extracted files
    ./assemble_report.sh "$temp_dir"

    # Call wrap_contents.sh on the extracted files
    ./wrap_contents.sh "$temp_dir"

    # Move the output file to the current directory
    mv "$temp_dir"/failed_login_summary.html "${tar_file%.tgz}_failed_login_summary.html"
    
done

# Call create_username_dist.sh after processing all tar files
./create_username_dist.sh "$temp_dir"