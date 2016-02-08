
#!/bin/bash

source config.sh

function printFunction {
	functionTemp=$(head -n $2 $1 | tail -n 1)
	echo "${functionTemp#* }"
	# echo "$1 => ${functionTemp#* }"
	# echo "'''head -n $2 $1''' => '''$(head -n $2 $1)'''"
}

function addFunctionPart {
	fitDir=$1
	dt=$2
	op=$3
	ds=$4
	from=$5
	size=$6
	parallel=$7

	file="$fitDir/$dt/$size/$parallel/$ds/$op.functions"
	if [[ -f "$file" ]]; then
		function=$(printFunction $file 1)
	else
		function="0"
	fi
	if [[ $function == "" ]]; then function="0"; fi
	
	echo "${ds}_$size(x) = ($from <= x && x <= $size) ? $function : 1/0"
}

function plotFunctions {
	pDir=$1
	fitDir=$2
	dt=$3
	op=$4

	if [[ ! -d "$pDir" ]]; then mkdir $pDir; fi

	echo -e "	set terminal png font ',16' size 1024,640
				set key top left
				set title '$op'
				set output '$pDir/$op.png'
				set yrange [1:*]
				set xrange [1:110000]
				set logscale xy
				f(x) = 0"
	for ds in ${dataStructures[@]}; do
		addFunctionPart $fitDir $dt $op $ds 1 100 200000
		addFunctionPart $fitDir $dt $op $ds 101 1000 10000
		addFunctionPart $fitDir $dt $op $ds 1001 10000 100
		addFunctionPart $fitDir $dt $op $ds 10001 50000 10
		addFunctionPart $fitDir $dt $op $ds 50001 100000 1
	done
	echo "set arrow from 100,1 to 100,999999 nohead"
	echo "set arrow from 1000,1 to 1000,999999 nohead"
	echo "set arrow from 10000,1 to 10000,999999 nohead"
	echo "set arrow from 50000,1 to 50000,999999 nohead"
	echo "set arrow from 100000,1 to 100000,999999 nohead"
	echo "plot f(x) notitle, \\"
	index="1"
	for ds in ${dataStructures[@]}; do
		echo "${ds}_100(x) with linespoint lt $index title '$ds', \\"
		echo "${ds}_1000(x) with linespoint lt $index notitle, \\"
		echo "${ds}_10000(x) with linespoint lt $index notitle, \\"
		echo "${ds}_50000(x) with linespoint lt $index notitle, \\"
		echo "${ds}_100000(x) with linespoint lt $index notitle, \\"
		index=$((index+1))
	done
	echo "f(x) notitle"
}

function all {
	for op in ${operations[@]}; do
		plotFunctions "$plotDir-$2/$1/_functions" "$aggrFitDir-$2" $1 $op | gnuplot
	done
}

# all Node 2
# all Node -2
all Node 5
# all Node -5

# all Edge 2
# all Edge -2
all Edge 5
# all Edge -5