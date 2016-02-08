#!/bin/bash

source ../analysis/config.sh

function all {
	dt=$1
	size=$2
	parallel=$3
	dir="$plotDir/$dt/$size/$parallel/$plotsAllDir"
	# echo "<h3>all</h3>"
	for operation in ${operations[@]}; do
		plot="$dt-$size-$parallel-$operation"
		file="$dir/$plot.png"
		echo "<a href='$file'><img src='$file' width='$imgWidth'/></a>"
	done
}

function ds {
	dt=$1
	size=$2
	parallel=$3
	ds=$4
	dir="$plotDir/$dt/$size/$parallel/$ds"
	echo "<h3>$ds</h3>"
	for operation in ${operations[@]}; do
		plot="$dt-$size-$parallel-$operation-$ds"
		file="$dir/$plot.png"
		echo "<a href='$file'><img src='$file' width='$imgWidth'/></a>"
	done
}

echo '<?php require("../../../layout/header.php"); ?>'

if [[ $# = 3 ]]; then
	plotDir=$1
	dt=$2
	size=$3
	echo "<h1>$dt @ $size ($(ls $plotDir/$dt/$size))"
	count=$(ls $plotDir/$dt/$size | wc -l | xargs)
	if [[ $count == "1" ]]; then
		imgWidth="800"
	elif [[ $count == "2" ]]; then
		imgWidth="400"
	elif [[ $count == "3" ]]; then
		imgWidth="266"
	else
		imgWidth="100"
	fi
	for operation in ${operations[@]}; do
		echo "<h2>$operation</h2>"
		for parallel in $(ls $plotDir/$dt/$size); do
			dir="$plotDir/$dt/$size/$parallel/$plotsAllDir"
			plot="$dt-$size-$parallel-$operation"
			file="$dir/$plot.png"
			echo "<a href='$file'><img src='$file' width='$imgWidth'/></a>"
		done
		echo "<br/>"
	done
else
	imgWidth="250"
	for dt in $(ls $plotDir); do
		echo "<h1>$dt</h1>"
		for size in $(ls $plotDir/$dt); do
			for operation in ${operations[@]}; do
				echo "<h2>$dt - $operation @$size ($(ls $plotDir/$dt/$size))</h2>"
				for parallel in $(ls $plotDir/$dt/$size); do
					# echo "<h2>$size - $parallel</h2>"
					dir="$plotDir/$dt/$size/$parallel/$plotsAllDir"
					plot="$dt-$size-$parallel-$operation"
					file="$dir/$plot.png"
					echo "<a href='$file'><img src='$file' width='$imgWidth'/></a>"

					# all $dt $size $parallel
					# for ds in $(ls $plotDir/$dt/$size/$parallel | grep -v $plotsAllDir); do
					# 	ds $dt $size $parallel $ds
					# done
				done
				echo "<br/>"
			done
		done
	done
fi

echo '<?php require("../../../layout/footer.php"); ?>'