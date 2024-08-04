#!/bin/bash
source ./settings.conf
date=$(date +%Y-%m-%d)
epoch=$(date -d "$date" +%s)


# Check if backup folder exists
if [ ! -d "$BACKUP_PATH" ]; then
    mkdir -p $BACKUP_PATH
fi


function backup_dockge {
    # Check if backup folder exists
    if [ ! -d "$BACKUP_PATH/dockge" ]; then
        mkdir -p $BACKUP_PATH/dockge
    fi
    # Backup dockge
    ./tools/interval.sh $BACKUP_PATH/dockge
    if [ $? -eq 1 ]; then
        echo "Backing up dockge"
        if ssh $SSH_USER@$SSH_HOST -p $SSH_PORT "tar -czf - $DOCKGE_PATH" > $BACKUP_PATH/dockge/$date.tar.gz; then
            bash ./tools/cleanup.sh $BACKUP_PATH/dockge
        else
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
        fi
        # Backup stack
        ./tools/interval.sh $BACKUP_PATH/stacks/$stack
        if [ $? -eq 1 ]; then
            echo "Backing up $stack"
            if ssh $SSH_USER@$SSH_HOST -p $SSH_PORT "tar -czf - $STACKS_PATH/$stack" > $BACKUP_PATH/stacks/$stack/$date.tar.gz; then
                bash ./tools/cleanup.sh $BACKUP_PATH/stacks/$stack
            else
                rm $BACKUP_PATH/stacks/$stack/$date.tar.gz
            fi
        fi
    done
}

backup_dockge
backup_stacks