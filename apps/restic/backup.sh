#!/bin/bash

# load environment variables from .env
set -o allexport
source .env
set +o allexport

# backup from local directory to repository as specified in .env
sudo restic -r b2:${B2_BUCKET_NAME} --verbose backup ${LOCAL_DIR}
local restic_status = $?

# describe how the backup went
# TODO: replace with healthcheck/ntfy
if [ $restic_status -eq 0 ]; then
    echo "success"
elif [ $restic_status -eq 1 ]; then
    echo "failure"
elif [ $restic_status -eq 3 ]; then
    echo "incomplete"
else
    echo "unknown"
fi