#!/bin/bash

source config.sh

function measure {
	dir="$dataDir/$1/$2/$3/$4"
	if [[ ! -d $dir ]]; then mkdir -p $dir; fi
	file="$dir/$5.dat"
	if [[ -f $file ]]; then
		echo "$file exists"
	else
		echo "-> $file"
		java -Xms512m -Xmx8g -jar measurement.jar "dna.graph.datastructures.$4" $1 $2 $3 500 5 > $file
	fi
}


if [[ $# = 5 ]]; then
	dt=$1
	size=$2
	parallel=$3
	ds=$4
	run=$5
	measure $dt $size $parallel $ds $run
else
	echo "expecting 5 arguments" >&2
	exit
fi
