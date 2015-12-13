#!/bin/bash

source config.sh

function printFunction {
	cat $1 | head -n $2 | tail -n 1
}

if [[ $# = 3 ]]; then
	if [[ $1 = "aggr" ]]; then
		fitDir=$aggrFitDir
	elif [[ $1 = "concat" ]]; then
		fitDir=$concatFitDir
	else
		echo "invalid functions type (should be concat of aggr)"
		exit
	fi
	size=$2
	parallel=$3
	for dt in ${dataTypes[@]}; do
		for ds in $(ls $fitDir/$dt/$size/$parallel); do
			echo "# # # # # # # # # # # # # # # #"
			echo "# $dt - $ds"
			echo "# # # # # # # # # # # # # # # #"
			for operation in ${operations[@]}; do
				file="$fitDir/$dt/$size/$parallel/$ds/$operation.functions"
				echo "${dt}_${operation}_f1='$(printFunction $file 1)'"
				echo "${dt}_${operation}_f2='$(printFunction $file 2)'"
				echo "${dt}_${operation}_f3='$(printFunction $file 3)'"
				echo ""
			done
			echo "# # # # # # # # # # # # # # # #"
			echo ""
			echo ""
		done
	done
else
	echo "invalid number of arguments: $# given but 3"
fi