
#!/bin/bash

source config.sh

# ./plot.sh $size $parallel 5
# ./plot.sh 100 200000 5

function printFunction {
	if [[ ! -f $1 ]]; then
		echo "0"
	else
		functionTemp=$(head -n $2 $1 | tail -n 1)
		echo "${functionTemp#* }"
	fi
}

function plotDS {
	pDir=$1
	fitDir=$2
	dt=$3
	size=$4
	parallel=$5
	ds=$6
	valueIndex=$7
	operation=$8

	if [[ $# = 7 ]]; then
		for operation in ${operations[@]}; do
			plotDS $1 $2 $3 $4 $5 $6 $7 $operation
		done
	elif [[ $# = 8 ]]; then
		if [[ ! -d $pDir ]]; then mkdir -p $pDir; fi
		if [[ "$valueIndex" -lt "0" ]]; then valueIndex=$((valueIndex*-1)); fi
		functionFile="$fitDir/$dt/$size/$parallel/$ds/$operation.functions"
		function1=$(printFunction $functionFile 1)
		function2=$(printFunction $functionFile 2)
		function3=$(printFunction $functionFile 3)
		function4=$(printFunction $functionFile 4)
		echo "	set terminal png
				set key top left
				set title '$ds - $operation'
				set output '$pDir/$dt-$size-$parallel-$operation-$ds.png'
				data = '$aggrDir/$dt/$size/$parallel/$ds/$operation.aggr'
				set yrange [0:*]
				f1(x) = $function1
				f2(x) = $function2
				f3(x) = $function3
				f4(x) = $function4
				plot 	data using 1:$valueIndex with dots lw 5 title 'median', \
						f1(x) with lines lw 5 title '$function1', \
						f2(x) with lines lw 2 title '$function2', \
						f3(x) with lines lw 2 title '$function3', \
						f4(x) with lines lw 2 title '$function4'" | gnuplot
	fi
}

function plotDSS {
	pDir=$1
	fitDir=$2
	dt=$3
	size=$4
	parallel=$5
	valueIndex=$6
	operation=$7

	if [[ $# = 6 ]]; then
		for operation in ${operations[@]}; do
			plotDSS $1 $2 $3 $4 $5 $6 $operation
		done
	elif [[ $# = 7 ]]; then
		if [[ ! -d $pDir ]]; then mkdir -p $pDir; fi
		if [[ "$valueIndex" -lt "0" ]]; then valueIndex=$((valueIndex*-1)); fi
		cmd="	set terminal pdf font ',16'
				set key top left
				# set title '$operation'
				set output '$pDir/$dt-$size-$parallel-$operation.pdf'
				set yrange [0:*]
				set xlabel 'list size'
				set ylabel 'runtime (ns)'
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
			if [[ ! $(printFunction $functionFile 1) == "0" ]]; then
				cmd="${cmd} '$aggrDir/$dt/$size/$parallel/$ds/$operation.aggr' using 1:$valueIndex with points lw 1 lt $index notitle, \
					f$ds(x) with lines lw 3 lt $index title '$ds', \
					"
			fi
		done
		cmd="$cmd g(x) with lines notitle"

		echo -e "$cmd" | gnuplot
	fi
}



function all {
	# for ds in ${dataStructures[@]}; do
	# 	plotDS $plotDir-$3/Edge/$1/$2/$ds $aggrFitDir-$3 Edge $1 $2 $ds $3
	# 	plotDS $plotDir-$3/Node/$1/$2/$ds $aggrFitDir-$3 Node $1 $2 $ds $3
	# done
	plotDSS $plotDir-$3/Edge/$1/$2/$plotsAllDir $aggrFitDir-$3 Edge $1 $2 $3
	plotDSS $plotDir-$3/Node/$1/$2/$plotsAllDir $aggrFitDir-$3 Node $1 $2 $3
}


if [[ $# = 3 ]]; then
	all $1 $2 $3
else
	echo "expecting 3 argument, got $#" >&2
fi