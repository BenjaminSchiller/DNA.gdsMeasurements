#!/bin/bash

source config.sh

function quality {
	ndf=$(cat $1 | grep '(FIT_NDF)' | head -n $2 | tail -n 1 | awk '{print $NF;}')
	chisquare=$(cat $1 | grep '(reduced chisquare)' | head -n $2 | tail -n 1 | awk '{print $NF;}')
	wssr=$(awk "BEGIN {printf ${chisquare}*${ndf}*100}" | cut -f1 -d",")
	echo $wssr
}

function value {
	value=$(cat $1 | grep '+/-' | grep "$2" | awk '{print $3;}')
	echo $value
}

function fitAggr {
	valueIndex=$1
	dt=$2
	size=$3
	parallel=$4
	ds=$5

	echo "fitAggr: $1 $2 $3 $4 $5"
	# return 1

	srcDir="$aggrDir/$dt/$size/$parallel/$ds"
	dstDir="$aggrFitDir-$valueIndex/$dt/$size/$parallel/$ds"

	if [[ ! -d $dstDir ]]; then mkdir -p $dstDir; fi

	echo "->  $dstDir"
	for index in $(seq 0 11); do
		operation=${operations[$index]}
		srcFile="$srcDir/$operation.aggr"
		dstFile1="$dstDir/$operation.fit"
		dstFile2="$dstDir/$operation.functions"

		# x:y:stdDev=sqrt(var)
		if [[ "$valueIndex" -gt "0" ]]; then
			echo "	f1(x) = a + b*x
					f2(x) = c + d*x + e*x**2
					f3(x) = f + g*log(x)
					f4(x) = h
					fit f1(x) '$srcFile' using 1:$valueIndex:(sqrt(\$6)) via a,b
					fit f2(x) '$srcFile' using 1:$valueIndex:(sqrt(\$6)) via c,d,e
					fit f3(x) '$srcFile' using 1:$valueIndex:(sqrt(\$6)) via f,g
					fit f4(x) '$srcFile' using 1:$valueIndex:(sqrt(\$6)) via h" | gnuplot &> $dstFile1
		else
			echo "	f1(x) = a + b*x
					f2(x) = c + d*x + e*x**2
					f3(x) = f + g*log(x)
					f4(x) = h
					fit f1(x) '$srcFile' using 1:$((valueIndex*-1)) via a,b
					fit f2(x) '$srcFile' using 1:$((valueIndex*-1)) via c,d,e
					fit f3(x) '$srcFile' using 1:$((valueIndex*-1)) via f,g
					fit f4(x) '$srcFile' using 1:$((valueIndex*-1)) via h" | gnuplot &> $dstFile1
		fi


		a=$(value $dstFile1 'a ')
		b=$(value $dstFile1 'b ')
		f1="$a + $b * x"
		q1=$(quality $dstFile1 1)

		c=$(value $dstFile1 'c ')
		d=$(value $dstFile1 'd ')
		e=$(value $dstFile1 'e ')
		f2="$c + $d * x + $e * x**2"
		q2=$(quality $dstFile1 2)

		f=$(value $dstFile1 'f ')
		g=$(value $dstFile1 'g ')
		f3="$f + $g * log(x)"
		q3=$(quality $dstFile1 3)

		h=$(value $dstFile1 'h ')
		f4="$h"
		q4=$(quality $dstFile1 4)
		
		printf "$q1 $f1\n$q2 $f2\n$q3 $f3\n$q4 $f4" | sort -n > $dstFile2
		echo "    $dstFile1 / $dstFile2"
	done
}

function fitX {
	ds=$1
	srcDir=$2
	dstDir=$3

	if [[ ! -d $dstDir ]]; then mkdir -p $dstDir; fi

	echo "->  $dstDir"
	for index in $(seq 0 11); do
		operation=${operations[$index]}
		srcFile="$srcDir/$ds.concat"
		dstFile1="$dstDir/$operation.fit"
		dstFile2="$dstDir/$operation.functions"

		echo "	f1(x) = a + b*x
				f2(x) = c + d*x + e*x**2
				f3(x) = f + g*log(x)
				f4(x) = h
				fit f1(x) '$srcFile' using 1:$((index+2)) via a,b
				fit f2(x) '$srcFile' using 1:$((index+2)) via c,d,e
				fit f3(x) '$srcFile' using 1:$((index+2)) via f,g
				fit f4(x) '$srcFile' using 1:$((index+2)) via h" | gnuplot &> $dstFile1

		a=$(value $dstFile1 'a ')
		b=$(value $dstFile1 'b ')
		f1="$a + $b * x"
		q1=$(quality $dstFile1 1)

		c=$(value $dstFile1 'c ')
		d=$(value $dstFile1 'd ')
		e=$(value $dstFile1 'e ')
		f2="$c + $d * x + $e * x**2"
		q2=$(quality $dstFile1 2)

		f=$(value $dstFile1 'f ')
		g=$(value $dstFile1 'g ')
		f3="$f + $g * log(x)"
		q3=$(quality $dstFile1 3)

		h=$(value $dstFile1 'h ')
		f4="$h"
		q4=$(quality $dstFile1 4)
		
		printf "$q1 $f1\n$q2 $f2\n$q3 $f3\n$q4 $f4" | sort -n > $dstFile2
		echo "    $dstFile1 / $dstFile2"
	done
}

function fitSingle {
	dt=$1
	size=$2
	parallel=$3
	ds=$4
	fitX $ds "$concatDir/$dt/$size/$parallel" "$concatFitDir/$dt/$size/$parallel/$ds"
}

function fitAll {
	dt=$1
	ds=$2
	fitX $ds "$concatDir/$dt" "$concatFitDir/$dt/$ds"
}

if [[ $1 = "aggr" ]]; then
	if [[ $# = 2 ]]; then
		valueIndex=$2
		for dt in $(ls $aggrDir); do
			for size in $(ls $aggrDir/$dt | grep -v .concat); do
				for parallel in $(ls $aggrDir/$dt/$size); do
					for ds in $(ls $aggrDir/$dt/$size/$parallel); do
						fitAggr $valueIndex $dt $size $parallel $ds
					done
				done
			done
		done
	elif [[ $# = 3 ]]; then
		valueIndex=$2
		dt=$3
		for size in $(ls $aggrDir/$dt); do
			for parallel in $(ls $aggrDir/$dt/$size); do
				for ds in $(ls $aggrDir/$dt/$size/$parallel); do
					fitAggr $valueIndex $dt $size $parallel $ds
				done
			done
		done
	elif [[ $# = 5 ]]; then
		valueIndex=$2
		dt=$3
		size=$4
		parallel=$5
		for ds in $(ls $aggrDir/$dt/$size/$parallel); do
			fitAggr $valueIndex $dt $size $parallel $ds
		done
	elif [[ $# = 6 ]]; then
		valueIndex=$2
		dt=$3
		size=$4
		parallel=$5
		ds=$6
		fitAggr $valueIndex $dt $size $parallel $ds
	else
		echo "fit aggr - invalid number of arguments ($#) (possible are: 2, 3, 5, 6)" >&2
	fi
elif [[ $1 = "concat" ]]; then
	if [[ $2 = "single" ]]; then
		if [[ $# = 2 ]]; then
			for dt in $(ls $concatDir); do
				for size in $(ls $concatDir/$dt | grep -v .concat); do
					for parallel in $(ls $concatDir/$dt/$size); do
						for ds in $(ls $concatDir/$dt/$size/$parallel); do
							fitSingle $dt $size $parallel "${ds/.concat/}"
						done
					done
				done
			done
		elif [[ $# = 3 ]]; then
			dt=$3
			for size in $(ls $concatDir/$dt | grep -v .concat); do
				for parallel in $(ls $concatDir/$dt/$size); do
					for ds in $(ls $concatDir/$dt/$size/$parallel); do
						fitSingle $dt $size $parallel "${ds/.concat/}"
					done
				done
			done
		elif [[ $# = 5 ]]; then
			dt=$3
			size=$4
			parallel=$5
			for ds in $(ls $concatDir/$dt/$size/$parallel); do
				fitSingle $dt $size $parallel "${ds/.concat/}"
			done
		elif [[ $# = 6 ]]; then
			dt=$3
			size=$4
			parallel=$5
			ds=$6
			fitSingle $dt $size $parallel "${ds/.concat/}"
		else
			echo "fit concat single - invalid number of arguments ($#) (possible are: 2, 3, 5, 6)" >&2
			exit
		fi
	elif [[ $2 = "all" ]]; then
		if [[ $# = 2 ]]; then
			for dt in $(ls $concatDir); do
				for ds in $(ls $concatDir/$dt | grep .concat); do
					fitAll $dt "${ds/.concat/}"
				done
			done
		elif [[ $# = 3 ]]; then
			dt=$3
			for ds in $(ls $concatDir/$dt | grep .concat); do
				fitAll $dt "${ds/.concat/}"
			done
		elif [[ $# = 4 ]]; then
			dt=$3
			ds=$4
			fitAll $dt "${ds/.concat/}"
		else
			echo "fit concat all - invalid number of arguments ($#) (possible are: 2, 3, 4)" >&2
			exit
		fi
	else
		echo "fit concat - invalid concat type (single or all)" >&2
		exit
	fi
else
	echo "invalid fit type '$1' (possible are: aggr, concat)" >&2
	exit
fi
