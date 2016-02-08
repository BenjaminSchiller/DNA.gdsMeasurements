#!/bin/bash

source jobs.cfg

if [[ ! -d data ]]; then mkdir data; fi

rsync -auvzl "${server_name}:${server_dir}/data/plots*" ./data/
rsync -auvzl --prune-empty-dirs --include '*/' --include '*.functions' --exclude '*' "${server_name}:${server_dir}/data/*Fits*" ./data/
