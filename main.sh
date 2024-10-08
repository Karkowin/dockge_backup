#!/bin/bash
cd "$(dirname "${BASH_SOURCE[0]}")"
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

# Check if backup folder exists
if [ ! -d "$BACKUP_PATH" ]; then
  mkdir -p $BACKUP_PATH
  log "Created backup folder $BACKUP_PATH"
fi

function backup_dockge {
  # Check if backup folder exists
  if [ ! -d "$BACKUP_PATH/dockge" ]; then
    mkdir -p $BACKUP_PATH/dockge
    log "Created backup folder $BACKUP_PATH/dockge"
  fi
  # Backup dockge
  ./tools/interval.sh $BACKUP_PATH/dockge
  if [ $? -eq 1 ]; then
    log "Backing up dockge"
    OPERATION=$(ssh $SSH_USER@$SSH_HOST -p $SSH_PORT "tar -czf - $DOCKGE_PATH" 2<&1 > $BACKUP_PATH/dockge/$date.tar.gz)
    if [ $? -eq 0 ]; then
      log "Backup of dockge successful"
      bash ./tools/cleanup.sh $BACKUP_PATH/dockge
    else
      log "Error backing up dockge: $OPERATION"
      mail "Dockge" "$OPERATION"
      rm $BACKUP_PATH/dockge/$date.tar.gz
    fi
  fi
}

function backup_stacks {
  # List stacks
  stacks=$(ssh $SSH_USER@$SSH_HOST -p $SSH_PORT "ls $STACKS_PATH")
  # Loop through stacks
  for stack in $stacks
  do
    # Check if backup folder exists
    if [ ! -d "$BACKUP_PATH/stacks/$stack" ]; then
      mkdir -p $BACKUP_PATH/stacks/$stack
      log "Created backup folder $BACKUP_PATH/stacks/$stack"
    fi
    # Backup stack
    ./tools/interval.sh $BACKUP_PATH/stacks/$stack
    if [ $? -eq 1 ]; then
      log "Backing up $stack"
      OPERATION=$(ssh $SSH_USER@$SSH_HOST -p $SSH_PORT "tar -czf - $STACKS_PATH/$stack" 2<&1 > $BACKUP_PATH/stacks/$stack/$date.tar.gz)
      if [ $? -eq 0 ]; then
        log "Backup of $stack successful"
        bash ./tools/cleanup.sh $BACKUP_PATH/stacks/$stack
      else
        log "Error backing up $stack: $OPERATION"
        mail "$stack" "$OPERATION"
        rm $BACKUP_PATH/stacks/$stack/$date.tar.gz
      fi
    fi
  done
}

# Call backup functions
backup_dockge
backup_stacks
# Execute all scripts in the custom folder
for script in ./custom/*.sh
do
  if [ "$script" != "./custom/example.sh" ]; then
    bash $script
  fi
done