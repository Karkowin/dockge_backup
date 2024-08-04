#!/bin/bash
source ./settings.conf

# Variables
date=$(date +%Y-%m-%d)
epoch=$(date -d "$date" +%s)
diffs=()

# Check for an argument for backup path
if [ ! -z "$1" ]; then
    backup_path=$1
    # Check if backup path exists and is a directory then proceed
    if [ -d "$backup_path" ]; then
        # Find existing backups
        while IFS= read -r -d '' file; do
            # Get file date
            file_date=$(echo "$file" | grep -oP '\d{4}-\d{2}-\d{2}')
            # Calculate days difference
            file_date=$(date -d "$file_date" +%s)
            days_diff=$(( ($epoch - $file_date) / 86400 ))
            # Add to diffs array
            diffs+=($days_diff)
        done < <(find $backup_path -type f -name "????-??-??.tar.gz" -print0)
        # Check if diffs array is not empty
        if [ ${#diffs[@]} -gt 0 ]; then
            # Find the latest backup
            latest_backup=$(printf "%s\n" "${diffs[@]}" | sort -nr | tail -1)
            # Check if latest backup is older than interval
            if [ $latest_backup -ge $INTERVAL ]; then
                exit 1
            else
                exit 0
            fi
        fi
    else
        echo "Backup path does not exist or is not a directory"
    fi
else
    echo "No backup path provided"
fi