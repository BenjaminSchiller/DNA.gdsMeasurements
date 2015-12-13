#!/bin/bash

runs="10"
size="100"
parallel="10000"

source config.sh

for dt in ${dataTypes[@]}; do
	for ds in ${dataStructures[@]}; do
		for run in $(seq 1 $runs); do
			./measurement.sh $dt $size $parallel $ds $run
		done
	done
done

# ./aggregation.sh Edge 100 10000
# ./aggregation.sh Node 100 10000
# ./fit.sh aggr 5 Edge 100 10000
# ./fit.sh aggr 5 Node 100 10000
# ./plot.sh