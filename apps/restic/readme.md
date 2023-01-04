# restic

There's no great Docker-based solution for restic, so these shell scripts are a good option. 

## Setup
### Install restic
```bash
sudo apt-get update
sudo apt-get install restic
```

## Automating
Install `crontab` to automate the running of `backup.sh` and `remove-old.sh`.
```
sudo apt-get update
sudo apt-get install cron
```
    
Then, edit the crontab file:
```
crontab -e
```

Use [crontab.guru](https://crontab.guru/) to generate the cron schedule. For example, to run the backup at 4:45 AM every day, use:
```
45 4 * * * ~/selfhosted/apps/restic/backup.sh
```

On a single host only (likely the VPS), run the `remove-old.sh` script at a time when no other backups are running. For example, to run the script at 4:00 PM every day, use:
```bash
0 16 * * * ~/selfhosted/apps/restic/remove-old.sh
```

## Shell scripts
### install.sh
Simply installs restic to /usr/local/bin/restic.

### create-repo.sh
Creates a restic repository to backblaze based on the values in `.env`.

### backup.sh
Backs up the specified directory from `.env` to the restic repository.

### remove-old.sh
Removes old backups from the restic repository. This should only be run on one host, and at a time when no other backups are running. E.g. for backups in the early AM, this can be run in the afternoon.

### recover.sh
No good shell script here - just refer to the documentation to do what's needed.