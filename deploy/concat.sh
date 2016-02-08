#!/bin/bash

source config.sh
source jobs.cfg

function concat {
	dir="$aggrDir/$dt/0/0/$ds"
	if [[ ! -d "$dir/" ]]; then mkdir -p "$dir/"; fi
	dst="$dir/$op.aggr"
	if [[ -f "$dst" ]]; then rm $dst; fi

	echo ">>> $dst"

	print 0 100 200000
	print 100 1000 10000
	print 1000 10000 100
	print 10000 50000 10
	print 50000 100000 1
}

function print {
	start=$1
	size=$2
	parallel=$3
	src="$aggrDir/$dt/$size/$parallel/$ds/$op.aggr"
	if [[ -f "$src" ]]; then
		tail -n $((size-start)) $src >> $dst
	fi
}

if [[ $1 == "server" ]]; then
	for dt in $(ls $aggrDir); do
		for ds in ${dataStructures[@]}; do
			for op in ${operations[@]}; do
				echo ">>> $dt $ds $op"
				concat
			done
		done
	done
else
	ssh ${server_name} "cd $server_dir; ./concat.sh server"
fi

# aggr/Node/100/200000/DArray/ITERATE.aggr