#!/bin/bash
source ./settings.conf
date=$(date +%Y-%m-%d)
epoch=$(date -d "$date" +%s)
TMP_DIRECTORY="/tmp/dockge_backup/$STACK_NAME"
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
    mkdir -p $TMP_DIRECTORY
}

function endbackup {
  OPERATION=$(tar -czf $BACKUP_PATH/custom/$STACK_NAME/$date.tar.gz $TMP_DIRECTORY 2<&1)
  if [ $? -eq 0 ]; then
    log "Archive of $STACK_NAME successful"
    rm -rf $TMP_DIRECTORY
    bash ./tools/cleanup.sh $BACKUP_PATH/custom/$STACK_NAME
  else
    log "Error archiving $STACK_NAME: $OPERATION"
    mail "Archive $STACK_NAME" "$OPERATION"
    rm -rf /tmp/dockge_backup
  fi
}

# Backup PostgreSQL
function backup_postgres {
    PSQL_CONTAINER=$1
    PSQL_DB_NAME=$2
    PSQL_DB_USER=$3
  ./tools/interval.sh "$BACKUP_PATH/custom/$STACK_NAME"
  if [ $? -eq 1 ]; then
    log "Backing up $STACK_NAME Postgres DB"
    OPERATION=$(ssh $SSH_USER@$SSH_HOST -p $SSH_PORT "docker exec $PSQL_CONTAINER pg_dump -U $PSQL_DB_USER $PSQL_DB_NAME" > $TMP_DIRECTORY/$PSQL_CONTAINER-$date.sql 2<&1)
    if [ $? -eq 0 ]; then
      log "Backup of $STACK_NAME Postgres DB successful"
    else
      log "Error backing up $STACK_NAME $PSQL_CONTAINER Postgres DB: $OPERATION"
      mail "$STACK_NAME $PSQL_CONTAINER Postgres DB" "$OPERATION"
      rm -rf $TMP_DIRECTORY
      exit
    fi
  fi
}

# Backup Docker volume
function backup_docker {
  DOCKER_CONTAINER=$1
  DOCKER_VOLUME=$2
  VOLUME_PATH=$3
  ./tools/interval.sh "$BACKUP_PATH/custom/$STACK_NAME"
  if [ $? -eq 1 ]; then
    log "Backing up $STACK_NAME Docker volume"
    OPERATION=$(ssh $SSH_USER@$SSH_HOST -p $SSH_PORT "docker run --rm --volumes-from $DOCKER_CONTAINER -v $TMP_DIRECTORY:/dockge_backup alpine sh -c 'tar -czf /dockge_backup/$DOCKER_CONTAINER-$date.tar.gz $VOLUME_PATH && chmod 777 /dockge_backup/$DOCKER_CONTAINER-$date.tar.gz'" 2<&1)
    if [ $? -eq 0 ]; then
      OPERATION=$(scp -P $SSH_PORT $SSH_USER@$SSH_HOST:$TMP_DIRECTORY/$DOCKER_CONTAINER-$date.tar.gz $TMP_DIRECTORY/$DOCKER_CONTAINER-$date.tar.gz 2<&1)
      if [ $? -eq 0 ]; then
        log "Backup of $STACK_NAME Docker volume successful"
        return
      fi
    fi
    log "Error backing up $STACK_NAME $DOCKER_CONTAINER Docker volume: $OPERATION"
    mail "$STACK_NAME $DOCKER_CONTAINER Docker volume" "$OPERATION"
    rm -rf $TMP_DIRECTORY
    exit
  fi
}



############################################
######## Custom backup operations ##########
############################################
STACK_NAME="stack_name"

startbackup
backup_postgres "container_name" "db_name" "db_user"
backup_docker "container_name" "volume_name" "volume_path"
endbackup