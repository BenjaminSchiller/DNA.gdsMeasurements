#!/bin/bash

source config.sh

function concatSingle {
	dt=$1
	size=$2
	parallel=$3
	ds=$4
	srcDir="$dataDir/$dt/$size/$parallel/$ds"
    dstDir="$concatDir/$dt/$size/$parallel"
    if [[ ! -d $dstDir ]]; then mkdir -p $dstDir; fi
    dstFile="$concatDir/$dt/$size/$parallel/$ds.concat"
    cat $srcDir/*.dat | grep -v '#' | grep -v 'SIZE' > $dstFile
    echo "-> $dstFile"
}

function concatAll {
	dt=$1
	ds=$2
	dst="$concatDir/$dt/$ds.concat"
    cat $concatDir/$dt/*/*/$ds.concat > $dst
    echo "--> $dst"
}

if [[ $1 = "single" ]]; then
	if [[ $# = 1 ]]; then
		for dt in $(ls $dataDir); do
			for size in $(ls $dataDir/$dt); do
				for parallel in $(ls $dataDir/$dt/$size); do
					for ds in $(ls $dataDir/$dt/$size/$parallel); do
						concatSingle $dt $size $parallel $ds
					done
				done
			done
		done
	elif [[ $# = 2 ]]; then
		dt=$2
		for size in $(ls $dataDir/$dt); do
			for parallel in $(ls $dataDir/$dt/$size); do
				for ds in $(ls $dataDir/$dt/$size/$parallel); do
					concatSingle $dt $size $parallel $ds
				done
			done
		done
	elif [[ $# = 4 ]]; then
		dt=$2
		size=$3
		parallel=$4
		for ds in $(ls $dataDir/$dt/$size/$parallel); do
			concatSingle $dt $size $parallel $ds
		done
	elif [[ $# = 5 ]]; then
		dt=$2
		size=$3
		parallel=$4
		ds=$5
		concatSingle $dt $size $parallel $ds
	else
		echo "concat single - invalid number of arguments ($#) (possible are: 1, 2, 4, 5)"
	fi
elif [[ $1 = "all" ]]; then
	if [[ $# = 1 ]]; then
		for dt in $(ls $dataDir); do
			for ds in ${dataStructures[@]}; do
				concatAll $dt $ds
			done
		done
	elif [[ $# = 2 ]]; then
		dt=$2
		for ds in ${dataStructures[@]}; do
			concatAll $dt $ds
		done
	elif [[ $# = 3 ]]; then
		dt=$2
		ds=$3
		concatAll $dt $ds
	else
		echo "concat all - invalid number of arguments ($#) (possible are: 1, 2, 3)"
	fi
else
	echo "invalid command type '$1' (possible are: single, all)"
fi