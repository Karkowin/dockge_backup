#!/bin/bash
source ./settings.conf
date=$(date +%Y-%m-%d)
epoch=$(date -d "$date" +%s)
# Log function
log() {
  ./tools/log.sh "$1"
}
# Mail function
mail() {
  ./tools/mail.sh "$1" "$2"
}

function startbackup {
    # Check if backup folder exists
    if [ ! -d "$BACKUP_PATH/custom/$STACK_NAME" ]; then
        mkdir -p $BACKUP_PATH/custom/$STACK_NAME
        log "Created backup folder $BACKUP_PATH/custom/$STACK_NAME"
    fi
    mkdir /tmp/$STACK_NAME
}

# Backup PostgreSQL
function backup_postgres {
    PSQL_CONTAINER=$1
    PSQL_DB_NAME=$2
    PSQL_DB_USER=$3
  ./tools/interval.sh "$BACKUP_PATH/custom/$STACK_NAME"
  if [ $? -eq 1 ]; then
    log "Backing up $STACK_NAME Postgres DB"
    if ssh $SSH_USER@$SSH_HOST -p $SSH_PORT "docker exec $PSQL_CONTAINER pg_dump -U $PSQL_DB_USER $PSQL_DB_NAME" > /tmp/$STACK_NAME/backup.sql; then
      log "Backup of $STACK_NAME Postgres DB successful"
    else
      log "Error backing up $STACK_NAME Postgres DB: $?"
      mail "$STACK_NAME Postgres DB" "$?"
      rm -rf /tmp/$STACK_NAME
      exit
    fi
  fi
}

# Finalize backup
function endbackup {
  tar -czf $BACKUP_PATH/custom/$STACK_NAME/$date.tar.gz /tmp/$STACK_NAME
  if [ $? -eq 0 ]; then
    log "Archive of $STACK_NAME successful"
    rm -rf /tmp/$STACK_NAME
    bash ./tools/cleanup.sh $BACKUP_PATH/custom/$STACK_NAME
  else
    log "Error archiving $STACK_NAME: $?"
    mail "Archive $STACK_NAME" "$?"
    rm -rf /tmp/$STACK_NAME
  fi
}


# Variables
STACK_NAME="linkwarden"

startbackup
backup_postgres "container_name" "db_name" "db_user"
endbackup