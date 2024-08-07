#!/bin/bash
source ./settings.conf

# Function to send email
send_email() {
  # Get arguments
  local BACKUP_NAME=$1
  local ERROR_MESSAGE=$2

  # Create JSON payload using jq
  local PAYLOAD=$(jq -n \
    --arg email_from "$EMAIL_FROM" \
    --arg email_from_name "$EMAIL_FROM_NAME" \
    --arg email_subject "$EMAIL_SUBJECT" \
    --arg email_to "$EMAIL_TO" \
    --arg email_to_name "$EMAIL_TO_NAME" \
    --arg backup_name "$BACKUP_NAME" \
    --arg error_message "$ERROR_MESSAGE" \
    '{sender: {email: $email_from, name: $email_from_name}, subject: $email_subject, htmlContent: "<p>Backup <strong>\($backup_name)</strong> failed with error:</p></br><p>\($error_message)</p>", messageVersions: [{to: [{email: $email_to, name: $email_to_name}]}]}')

  # Send email
  curl --request POST \
    --url "$BREVO_API_URL" \
    --header 'accept: application/json' \
    --header "api-key: $BREVO_API_KEY" \
    --header 'content-type: application/json' \
    --data "$PAYLOAD"
}

# Check if arguments are provided
if [ $# -ne 2 ]; then
  echo "Usage: $0 <backup_name> <error_message>"
  exit 1
fi

# Call send_email function with arguments
send_email "$1" "$2"

# ./tools/mail.sh "Daily Backup" "Error: unable to connect to database"