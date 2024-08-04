#!/bin/bash
source ./settings.conf

# Variables
date=$(date +%Y-%m-%d)
epoch=$(date -d "$date" +%s)

# Check for an argument for cleanup path
if [ ! -z "$1" ]; then
    cleanup_path=$1
    # Check if cleanup path exists and is a directory then proceed
    if [ -d "$cleanup_path" ]; then
        # Remove old backups
        find $cleanup_path -type f -name "????-??-??.tar.gz" -print0 | while IFS= read -r -d '' file; do
            # Get file date
            file_date=$(echo "$file" | grep -oP '\d{4}-\d{2}-\d{2}')
            # Calculate days difference
            file_date=$(date -d "$file_date" +%s)
            days_diff=$(( ($epoch - $file_date) / 86400 ))
            # Check if file is older or equal to retention
            if [ $days_diff -ge $RETENTION ]; then
                rm $file
            fi
        done
    else
        echo "Cleanup path does not exist or is not a directory"
    fi
else
    echo "No cleanup path provided"
fi