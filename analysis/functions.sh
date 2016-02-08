#!/bin/bash

source config.sh

function printFunction {
	function=$(cat $1 | head -n $2 | tail -n 1)
	function=${function#* }
	echo "$function"
}

if [[ $# = 1 ]]; then
	if [[ $1 = "2" ]]; then
		ft="AvgSD"
	elif [[ $1 = "-2" ]]; then
		ft="Avg"
	elif [[ $1 = "5" ]]; then
		ft="MedSD"
	elif [[ $1 = "-5" ]]; then
		ft="Med"
	elif [[ $1 = "102" ]]; then
		ft="AvgSD_py"
	elif [[ $1 = "-102" ]]; then
		ft="Avg_py"
	elif [[ $1 = "105" ]]; then
		ft="MedSD_py"
	elif [[ $1 = "-105" ]]; then
		ft="Med_py"
	else
		echo "invalid type (possible are: (10)2, -(10)2, (10)5, -(10)5" >&2
		exit
	fi

	fitDir="$aggrFitDir-$1"

	for dt in $(ls $fitDir); do
		allSizes=""
		for size in $(ls $fitDir/$dt); do
			max=0
			for n in $(ls $fitDir/$dt/$size) ; do
			    ((n > max)) && max=$n
			done
			# for parallel in $(ls $fitDir/$dt/$size); do
				for ds in $(ls $fitDir/$dt/$size/$max); do
					echo "# # # # # # # # # # # # # # # #"
					echo "# $dt - $size - $ds @ $max"
					echo "# # # # # # # # # # # # # # # #"
					for operation in ${operations[@]}; do
						file="$fitDir/$dt/$size/$max/$ds/$operation.functions"
						function=$(printFunction $file 1)
						if [[ ! $function == "" ]]; then
							echo "${ft}_${dt}_${ds}_${operation}_${size}=$function"
						fi
						# echo "${dt}_${size}_${ds}_${operation}_f1=$(printFunction $file 1)"
						# echo "${dt}_${size}_${ds}_${operation}_f2=$(printFunction $file 2)"
						# echo "${dt}_${size}_${ds}_${operation}_f3=$(printFunction $file 3)"
						# echo ""
					done
					echo "# # # # # # # # # # # # # # # #"
					echo ""
				done
			# done
			allSizes="${allSizes} $size"
		done
		allSizes=$(echo ${allSizes} | xargs)
		allSizes=${allSizes// /,}
		echo "${dt}_allSizes=${allSizes}"
		echo ""
		echo ""
		echo ""
		echo ""
		echo ""
		echo ""
	done
else
	if [[ ! -d functions ]]; then mkdir functions; fi
	
	./functions.sh 2 > functions/functions-AvgSD.properties
	./functions.sh -2 > functions/functions-Avg.properties
	./functions.sh 5 > functions/functions-MedSD.properties
	./functions.sh -5 > functions/functions-Med.properties

	./functions.sh 102 > functions/functions-AvgSD_py.properties
	./functions.sh -102 > functions/functions-Avg_py.properties
	./functions.sh 105 > functions/functions-MedSD_py.properties
	./functions.sh -105 > functions/functions-Med_py.properties
fi