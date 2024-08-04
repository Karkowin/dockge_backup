#!/bin/bash
source ./settings.conf

# Function to send email
send_email() {
  # Get arguments
  local BACKUP_NAME=$1
  local ERROR_MESSAGE=$2

  # Create JSON payload
  local PAYLOAD=$(cat <<EOF
{
  "sender": {
    "email": "$EMAIL_FROM",
    "name": "$EMAIL_FROM_NAME"
  },
  "subject": "$EMAIL_SUBJECT",
  "htmlContent": "<p>Backup <strong>$BACKUP_NAME</strong> failed with error:</p></br><p>$ERROR_MESSAGE</p>",
  "messageVersions": [
    {
      "to": [
        {
          "email": "$EMAIL_TO",
          "name": "$EMAIL_TO_NAME"
        }
      ]
    }
  ]
}
EOF
)

  # Send email
  curl --request POST \
    --url $BREVO_API_URL \
    --header 'accept: application/json' \
    --header 'api-key: '$BREVO_API_KEY \
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

# ./script.sh "Daily Backup" "Error: unable to connect to database"