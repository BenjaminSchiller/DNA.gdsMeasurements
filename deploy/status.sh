#!/bin/bash

if [[ -f config.sh ]]; then
	source config.sh
else
	source ../analysis/config.sh
fi
source jobs.cfg

if [[ $1 = 'server' ]]; then
	for dt in $(ls $dataDir); do
		for size in $(ls $dataDir/$dt); do
			for parallel in $(ls $dataDir/$dt/$size); do
				for ds in $(ls $dataDir/$dt/$size/$parallel); do
					echo "$(ls $dataDir/$dt/$size/$parallel/$ds/ | wc -l) - $dt $size $parallel $ds"
				done
			done
		done
	done
fi

if [[ $# == 0 ]]; then
	ssh $server_name "cd $server_dir; ./status.sh server"
fi