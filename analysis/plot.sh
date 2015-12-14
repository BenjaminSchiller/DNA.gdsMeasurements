#!/bin/bash

source config.sh

function printFunction {
	functionTemp=$(head -n $2 $1 | tail -n 1)
	echo "${functionTemp#* }"
}

function plotDS {
	pDir=$1
	fitDir=$2
	dt=$3
	size=$4
	parallel=$5
	ds=$6
	operation=$7

	if [[ $# = 5 ]]; then
		for ds in ${dataStructures[@]}; do
			for operation in ${operations[@]}; do
				plotDS $1 $2 $3 $4 $5 $ds $operation
			done
		done
	elif [[ $# = 6 ]]; then
		for operation in ${operations[@]}; do
			plotDS $1 $2 $3 $4 $5 $6 $operation
		done
	elif [[ $# = 7 ]]; then
		if [[ ! -d $pDir ]]; then mkdir -p $pDir; fi
		functionFile="$fitDir/$dt/$size/$parallel/$ds/$operation.functions"
		function1=$(printFunction $functionFile 1)
		function2=$(printFunction $functionFile 2)
		function3=$(printFunction $functionFile 3)
		echo "	set terminal png
				set key top left
				set title '$ds - $operation'
				set output '$pDir/$dt-$size-$parallel-$operation-$ds.png'
				data = '$aggrDir/$dt/$size/$parallel/$ds/$operation.aggr'
				set yrange [0:*]
				f1(x) = $function1
				f2(x) = $function2
				f3(x) = $function3
				plot 	data using 1:5 with dots lw 5 title 'median', \
						f1(x) with lines lw 5 title '$function1', \
						f2(x) with lines lw 2 title '$function2', \
						f3(x) with lines lw 2 title '$function3'" | gnuplot
	fi
}

function plotDSS {
	pDir=$1
	fitDir=$2
	dt=$3
	size=$4
	parallel=$5
	operation=$6

	if [[ $# = 5 ]]; then
		for operation in ${operations[@]}; do
			plotDSS $1 $2 $3 $4 $5 $6 $operation
		done
	elif [[ $# = 6 ]]; then
		if [[ ! -d $pDir ]]; then mkdir -p $pDir; fi
		cmd="	set terminal png
				set key top left
				set title '$operation'
				set output '$pDir/$dt-$size-$parallel-$operation.png'
				set yrange [0:*]
				g(x) = -1"
		for ds in ${dataStructures[@]}; do
			functionFile="$fitDir/$dt/$size/$parallel/$ds/$operation.functions"
			cmd="$cmd
				f$ds(x) = $(printFunction $functionFile 1)"
		done
		cmd="$cmd
				plot	"
		index="0"
		for ds in ${dataStructures[@]}; do
			index=$((index+1))
			functionFile="$fitDir/$dt/$size/$parallel/$ds/$operation.functions"
			cmd="${cmd} '$aggrDir/$dt/$size/$parallel/$ds/$operation.aggr' using 1:5 with dots lw 1 lt $index notitle, \
				f$ds(x) with lines lw 3 lt $index title '$ds', \
				"
		done
		cmd="$cmd g(x) with lines notitle"

		echo -e "$cmd" | gnuplot
	fi
}



function all {
	for ds in ${dataStructures[@]}; do
		plotDS $plotDir/$1/$ds $aggrFitDir Edge $1 $2 $ds
	done
	plotDSS $plotDir/$1/all $aggrFitDir Edge $1 $2	
}


if [[ $# = 2 ]]; then
	all $1 $2
else
	echo "expecting 2 argument, got $#"
fi