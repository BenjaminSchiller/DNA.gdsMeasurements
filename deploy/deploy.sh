#!/bin/bash

source jobs.cfg

dst="${server_name}:${server_dir}/"

echo "deploying to $dst"

./jobs.sh deploy
rsync -auvzl ../analysis/*.sh ../analysis/*.py ../analysis/*.cfg ../build/*.jar status.sh concat.sh $dst