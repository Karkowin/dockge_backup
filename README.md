Here is the rewritten README:

# Requirements

## Packages

The following packages are required to run the script:

- jq
- curl
- ssh

## Brevo API Key

You need a valid Brevo API key to use the email alerting feature. You can obtain a key by creating an account on the Brevo website.

## Remote server user

You need a user account on the remote server to connect via SSH. Make sure the user has the necessary permissions to access the Dockge and stacks directories.

### Give user permission with ACL

To give the user permission to access the Dockge and stacks directories, you can use the `setfacl` command:

```bash
sudo setfacl -d -R -m u:username:r-x /path/to/dockge
sudo setfacl -R -m u:username:r-x /path/to/dockge
sudo setfacl -d -R -m u:username:r-x /path/to/stacks
sudo setfacl -R -m u:username:r-x /path/to/stacks
```

Replace `username` with the actual username and `/path/to/dockge` and `/path/to/stacks` with the actual paths.

## SSH Key without passphrase

You need to generate an SSH key without a passphrase to connect to the remote server without being prompted for a password. You can generate a key using the following command:

```bash
ssh-keygen
```

This will generate a key pair.
Now, you need to copy the public key to the remote server:

```bash
ssh-copy-id -p <port> <user>@<host>
```

# Installation

To install the script, simply clone the repository:

```bash
git clone https://github.com/your-username/dockge-backup.git
```

# Configuration

## Settings conf file

The script uses a `settings.conf` file to store its configuration. You need to copy the `example.conf` file to `settings.conf` and edit it to match your environment:

```bash
cp example.conf settings.conf
```

The `settings.conf` file contains the following variables:

- `DOCKGE_PATH`: remote path to Dockge
- `STACKS_PATH`: remote path to stacks
- `BACKUP_PATH`: local path for backups
- `LOG_FILE`: log file path
- `INTERVAL`: backup interval (days)
- `RETENTION`: backup retention period (days)
- `SSH_USER`, `SSH_HOST`, `SSH_PORT`: SSH connection details
- `BREEVO_API_KEY`: Brevo API key (required for email alerting)
- `BREEVO_API_URL`: Brevo API URL (required for email alerting)
- `EMAIL_TO`, `EMAIL_TO_NAME`, `EMAIL_FROM`, `EMAIL_FROM_NAME`, `EMAIL_SUBJECT`: email settings for failure alerts

## Schedule crontab

To schedule the script to run daily, you need to add a crontab entry:

```bash
crontab -e
```

Add the following line to schedule the script to run every day at 2am:

```bash
0 2 * * * bash /path/to/dockge-backup/main.sh
```

Replace `/path/to/dockge-backup` with the actual path to the cloned repository.

# Custom scripts

You can add custom scripts to the `custom` folder to backup Docker volumes and databases. These scripts will be automatically loaded by the main script. An example script is already present in the `custom` folder for your reference.
