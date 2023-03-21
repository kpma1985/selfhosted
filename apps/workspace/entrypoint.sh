#!/bin/bash

# activate the conda environment
. /opt/mambaforge/etc/profile.d/conda.sh
conda activate base

# start code-server
code-server &

# start jupyter lab, accepting connections from any IP address
jupyter lab --allow-root --no-browser --ip "*"
