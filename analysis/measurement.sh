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
		java -jar ../build/measurement.jar "dna.graph.datastructures.$4" $1 $2 $3 500 5 > $file
	fi
}

runs="50"

size="100"
parallel="10000"

for dt in ${dataTypes[@]}; do
	for ds in ${dataStructures[@]}; do
		for run in $(seq 1 $runs); do
			measure $dt $size $parallel $ds $run
		done
	done
done

./aggregation.sh Edge 100 10000
./aggregation.sh Node 100 10000
./fit.sh aggr 5 Edge 100 10000
./fit.sh aggr 5 Node 100 10000

./plot.sh