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
	dstDir="$aggrFitDir/$dt/$size/$parallel/$ds"

	if [[ ! -d $dstDir ]]; then mkdir -p $dstDir; fi

	echo "->  $dstDir"
	for index in $(seq 0 11); do
		operation=${operations[$index]}
		srcFile="$srcDir/$operation.aggr"
		dstFile1="$dstDir/$operation.fit"
		dstFile2="$dstDir/$operation.functions"

		echo "	p1(x) = a + b*x
				p2(x) = c + d*x + e*x**2
				p3(x) = f + g*log(x)
				fit p1(x) '$srcFile' using 1:$valueIndex via a,b
				fit p2(x) '$srcFile' using 1:$valueIndex via c,d,e
				fit p3(x) '$srcFile' using 1:$valueIndex via f,g" | gnuplot &> $dstFile1

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
		
		printf "$q1 $f1\n$q2 $f2\n$q3 $f3" | sort -n > $dstFile2
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

		echo "	p1(x) = a + b*x
				p2(x) = c + d*x + e*x**2
				p3(x) = f + g*log(x)
				fit p1(x) '$srcFile' using 1:$((index+2)) via a,b
				fit p2(x) '$srcFile' using 1:$((index+2)) via c,d,e
				fit p3(x) '$srcFile' using 1:$((index+2)) via f,g" | gnuplot &> $dstFile1

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
		
		printf "$q1 $f1\n$q2 $f2\n$q3 $f3" | sort -n > $dstFile2
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
		echo "fit aggr - invalid number of arguments ($#) (possible are: 2, 3, 5, 6)"
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
			echo "fit concat single - invalid number of arguments ($#) (possible are: 2, 3, 5, 6)"
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
			echo "...."
			exit
		fi
	else
		echo "fit concat all - invalid number of arguments ($#) (possible are: 2, 3, 4)"
		exit
	fi
else
	echo "invalid fit type '$1' (possible are: aggr, concat)"
	exit
fi

# if [[ ! -d $fitDir ]]; then mkdir -p $fitDir; fi

# if [[ $2 = "single" ]]; then
# 	if [[ $# = 2 ]]; then
# 		for dt in $(ls $concatDir); do
# 			for size in $(ls $concatDir/$dt | grep -v .concat); do
# 				for parallel in $(ls $concatDir/$dt/$size); do
# 					for ds in $(ls $concatDir/$dt/$size/$parallel); do
# 						fitSingle $dt $size $parallel "${ds/.concat/}"
# 					done
# 				done
# 			done
# 		done
# 	elif [[ $# = 3 ]]; then
# 		dt=$3
# 		for size in $(ls $concatDir/$dt | grep -v .concat); do
# 			for parallel in $(ls $concatDir/$dt/$size); do
# 				for ds in $(ls $concatDir/$dt/$size/$parallel); do
# 					fitSingle $dt $size $parallel "${ds/.concat/}"
# 				done
# 			done
# 		done
# 	elif [[ $# = 5 ]]; then
# 		dt=$3
# 		size=$4
# 		parallel=$5
# 		for ds in $(ls $concatDir/$dt/$size/$parallel); do
# 			fitSingle $dt $size $parallel "${ds/.concat/}"
# 		done
# 	elif [[ $# = 6 ]]; then
# 		dt=$3
# 		size=$4
# 		parallel=$5
# 		ds=$6
# 		fitSingle $dt $size $parallel "${ds/.concat/}"
# 	else
# 		echo "fit single - invalid number of arguments ($#) (possible are: 2, 3, 5, 6)"
# 	fi
# elif [[ $2 = "all" ]]; then
# 	if [[ $# = 2 ]]; then
# 		for dt in $(ls $concatDir); do
# 			for ds in $(ls $concatDir/$dt | grep .concat); do
# 				fitAll $dt "${ds/.concat/}"
# 			done
# 		done
# 	elif [[ $# = 3 ]]; then
# 		dt=$3
# 		for ds in $(ls $concatDir/$dt | grep .concat); do
# 			fitAll $dt "${ds/.concat/}"
# 		done
# 	elif [[ $# = 4 ]]; then
# 		dt=$3
# 		ds=$4
# 		fitAll $dt "${ds/.concat/}"
# 	else
# 		echo "fit all - invalid number of arguments ($#) (possible are: 2, 3, 4)"
# 	fi
# else
# 	echo "invalid command type '$1' (possible are: single, all)"
# fi