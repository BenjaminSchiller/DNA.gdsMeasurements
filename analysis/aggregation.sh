#!/bin/bash

source config.sh

function aggregate {
	src="$dataDir/$dt/$size/$parallel/$ds"
	dst="$aggrDir/$dt/$size/$parallel/$ds"
	if [[ ! -d $dst ]]; then mkdir -p $dst; fi
	for index in $(seq 0 11); do
		file="${dst}/${operations[$index]}.aggr"
		# if [[ ! -f $file ]]; then
			java -jar aggregation.jar $src/ ".dat" $size $((index+1)) > $file
			echo "-> $file"
		# fi
	done
}

if [[ $# = 0 ]]; then
	for dt in $(ls $dataDir); do
		for size in $(ls $dataDir/$dt); do
			for parallel in $(ls $dataDir/$dt/$size); do
				for ds in $(ls $dataDir/$dt/$size/$parallel); do
					aggregate $dt $size $parallel $ds
				done
			done
		done
	done
elif [[ $# = 1 ]]; then
	dt=$1
	for size in $(ls $dataDir/$dt); do
		for parallel in $(ls $dataDir/$dt/$size); do
			for ds in $(ls $dataDir/$dt/$size/$parallel); do
				aggregate $dt $size $parallel $ds
			done
		done
	done
elif [[ $# = 3 ]]; then
	dt=$1
	size=$2
	parallel=$3
	for ds in $(ls $dataDir/$dt/$size/$parallel); do
		aggregate $dt $size $parallel $ds
	done
elif [[ $# = 4 ]]; then
	dt=$1
	size=$2
	parallel=$3
	ds=$4
	aggregate $dt $size $parallel $ds
else
	echo "invalid number of arguments given ($#) (expecting 0, 1, 3, 4)" >&2
fi