#!/bin/bash

# import environment variables from file .env
set -o allexport
source .env
set +o allexport

# create a new repository
sudo restic -r b2:${B2_BUCKET_NAME} init