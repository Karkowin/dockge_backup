#!/bin/bash
source ./settings.conf

# Define the log file path and size limit here
size_limit=1048576 # 1MB in bytes

# Check if an argument was provided
if [ $# -eq 0 ]; then
   echo "Please provide a message to log."
fi

# Get the message to log
message="$1"

# Get the current timestamp
timestamp=$(date +"%Y-%m-%d %H:%M:%S")

# Check if the log file exists and is too large
if [ -f "${LOG_FILE}" ] && [ $(stat -c%s "${LOG_FILE}") -ge ${size_limit} ]; then
   # Rotate the log file
   rotated_log_file="${LOG_FILE}.${timestamp}"
   mv "${LOG_FILE}" "${rotated_log_file}"
   echo "Rotated log file to ${rotated_log_file}"
fi

# Append the message to the log file with the timestamp
echo "${timestamp} - ${message}" >> "${LOG_FILE}"