#!/bin/bash

source config.sh
main="$aggrFitDir-5"
digits="2"

function operationName {
	if [[ $1 == "ADD_FAILURE" ]]; then
		echo "\$add_f\$"
	elif [[ $1 == "ADD_SUCCESS" ]]; then
		echo "\$add_s\$"
	elif [[ $1 == "CONTAINS_FAILURE" ]]; then
		echo "\$cont_f\$"
	elif [[ $1 == "CONTAINS_SUCCESS" ]]; then
		echo "\$conf_s\$"
	elif [[ $1 == "GET_FAILURE" ]]; then
		echo "\$get_f\$"
	elif [[ $1 == "GET_SUCCESS" ]]; then
		echo "\$get_s\$"
	elif [[ $1 == "INIT" ]]; then
		echo "\$init\$"
	elif [[ $1 == "ITERATE" ]]; then
		echo "\$iter\$"
	elif [[ $1 == "RANDOM_ELEMENT" ]]; then
		echo "\$rand\$"
	elif [[ $1 == "REMOVE_FAILURE" ]]; then
		echo "\$rem_f\$"
	elif [[ $1 == "REMOVE_SUCCESS" ]]; then
		echo "\$rem_s\$"
	elif [[ $1 == "SIZE" ]]; then
		echo "\$size\$"
	fi
}

function dsName {
	if [[ $1 == "DArray" ]]; then
		echo "A"
	elif [[ $1 == "DArrayList" ]]; then
		echo "AL"
	elif [[ $1 == "DHashArrayList" ]]; then
		echo "HAL"
	elif [[ $1 == "DHashMap" ]]; then
		echo "HM"
	elif [[ $1 == "DHashSet" ]]; then
		echo "HS"
	elif [[ $1 == "DHashTable" ]]; then
		echo "HT"
	elif [[ $1 == "DLinkedList" ]]; then
		echo "LL"
	else
		echo "unknown"
	fi
}

function listAll {
	for lt in $(ls $main); do
		echo $lt
		for size in $(ls $main/$lt); do
			echo $size
			for parallel in $(ls $main/$lt/$size); do
				echo $parallel
				for ds in $(ls $main/$lt/$size/$parallel); do
					echo $ds
					listDS $lt $size $parallel $ds
				done
			done
		done
	done
}

function listAllDS {
	for ds in $(ls $main/$1/$2/$3); do
		listDS $1 $2 $3 $ds
	done
}

function listDS {
	for operation in $(ls $main/$1/$2/$3/$4); do
		function=$(head -n 1 $main/$1/$2/$3/$4/$operation)
		function=${function#* }
		function=${function/x\*\*2/x^2}
		function=${function/\*/\\cdot}
		function=${function/\*/\\cdot}
		function=${function/\*/\\cdot}
		function=${function/\*/\\cdot}
		function=$(./round.py "$function" $digits)
		operation=${operation/.functions/}
		echo "$1/$2/$3/$4/$operation . $(operationName $operation) & $(dsName $4) & \$$function\$"
	done
}

listAllDS Node 100 200000 | grep GET_S
listAllDS Edge 100 200000 | grep GET_S
listAllDS Node 100 200000 | grep GET_F
listAllDS Edge 100 200000 | grep GET_F