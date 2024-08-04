#!/bin/bash
source ./settings.conf

# Log function
log() {
  ./tools/log.sh "$1"
}

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
        log "Removing old backup: $file, days difference: $days_diff"
        rm $file
      fi
    done
  else
    log "Error: Cleanup path '$cleanup_path' does not exist or is not a directory"
  fi
else
  log "Error: No cleanup path provided"
fi