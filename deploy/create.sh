#!/bin/bash

source ../analysis/config.sh

set -e

function measure {
	size=$1
	parallel=$2
	runFrom=$3
	runTo=$4

	# echo "# # # # # # # # # # # # # # # # # # # # #"
	# echo "# # # # # # # # # # # # # # # # # # # # #"
	# echo "# $size $parallel ($runFrom $runTo)"
	# echo "# # # # # # # # # # # # # # # # # # # # #"

	for ds in ${dataStructures[@]}; do
		for dt in ${dataTypes[@]}; do
			for run in $(seq $runFrom $runTo); do
				# ./jobs.sh create "./measurement.sh $dt $size $parallel $ds $run"
				echo "./measurement.sh $dt $size $parallel $ds $run"
			done
		done
		# echo "# # # # # # # # # # # # # # # # # # # # #"
	done

	# echo "# # # # # # # # # # # # # # # # # # # # #"
	# echo ""
}

function aggregate {
	size=$1
	parallel=$2

	for ds in ${dataStructures[@]}; do
		for dt in ${dataTypes[@]}; do
			# ./jobs.sh create "./aggregation.sh $dt $size $parallel $ds"
			echo "./aggregation.sh $dt $size $parallel $ds"
		done
	done
}

function fit {
	size=$1
	parallel=$2

	for ds in ${dataStructures[@]}; do
		for dt in ${dataTypes[@]}; do
			# ./jobs.sh create "./fit.sh aggr 2 $dt $size $parallel $ds"
			# ./jobs.sh create "./fit.sh aggr 5 $dt $size $parallel $ds"
			# ./jobs.sh create "./fit.sh aggr -2 $dt $size $parallel $ds"
			# ./jobs.sh create "./fit.sh aggr -5 $dt $size $parallel $ds"
			# ./jobs.sh create "./fit.py aggr 102 $dt $size $parallel $ds"
			# ./jobs.sh create "./fit.py aggr 105 $dt $size $parallel $ds"
			# ./jobs.sh create "./fit.py aggr -102 $dt $size $parallel $ds"
			# ./jobs.sh create "./fit.py aggr -105 $dt $size $parallel $ds"
			# echo "./fit.sh aggr 2 $dt $size $parallel $ds"
			echo "./fit.sh aggr 5 $dt $size $parallel $ds"
			# echo "./fit.sh aggr -2 $dt $size $parallel $ds"
			# echo "./fit.sh aggr -5 $dt $size $parallel $ds"
			# echo "./fit.py aggr 102 $dt $size $parallel $ds"
			# echo "./fit.py aggr 105 $dt $size $parallel $ds"
			# echo "./fit.py aggr -102 $dt $size $parallel $ds"
			# echo "./fit.py aggr -105 $dt $size $parallel $ds"
		done
	done
}

function plot {
	size=$1
	parallel=$2

	# ./jobs.sh create "./plot.sh $size $parallel 2"
	# ./jobs.sh create "./plot.sh $size $parallel 5"
	# ./jobs.sh create "./plot.sh $size $parallel -2"
	# ./jobs.sh create "./plot.sh $size $parallel -5"
	# ./jobs.sh create "./plot.sh $size $parallel 102"
	# ./jobs.sh create "./plot.sh $size $parallel 105"
	# ./jobs.sh create "./plot.sh $size $parallel -102"
	# ./jobs.sh create "./plot.sh $size $parallel -105"
	# echo "./plot.sh $size $parallel 2"
	echo "./plot.sh $size $parallel 5"
	# echo "./plot.sh $size $parallel -2"
	# echo "./plot.sh $size $parallel -5"
	# echo "./plot.sh $size $parallel 102"
	# echo "./plot.sh $size $parallel 105"
	# echo "./plot.sh $size $parallel -102"
	# echo "./plot.sh $size $parallel -105"
}

# dataStructures=(DLinkedList DHashArrayList)

batchFile="jobs.batch"
if [[ -f $batchFile ]]; then rm $batchFile; fi
touch $batchFile




# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # AFTER RE INSTALL
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

### 100 200000 (100)
# measure 100 200000 51 100 >> $batchFile
# aggregate 100 200000 >> $batchFile
# fit 100 200000 >> $batchFile
# plot 100 200000 >> $batchFile

### 1000 10000 (50)
# measure 1000 10000 11 50 >> $batchFile
# aggregate 1000 10000 >> $batchFile
# fit 1000 10000 >> $batchFile
# plot 1000 10000 >> $batchFile

### 10000 100 (50)
# measure 10000 100 11 50 >> $batchFile
# aggregate 10000 100 >> $batchFile
# fit 10000 100 >> $batchFile
# plot 10000 100 >> $batchFile

### 50000 10 (50)
# measure 50000 10 11 50 >> $batchFile
# aggregate 50000 10 >> $batchFile
# fit 50000 10 >> $batchFile
# plot 50000 10 >> $batchFile


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # ORIGINAL
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

### 100 10000/100000/200000 (50)
# measure 100 10000 1 50; measure 100 100000 1 50; measure 100 200000 1 50
# aggregate 100 10000; aggregate 100 100000; aggregate 100 200000
# fit 100 10000; fit 100 100000; fit 100 200000
plot 100 10000 >> $batchFile; plot 100 100000 >> $batchFile; plot 100 200000 >> $batchFile

### 1000 1000/10000 (50)
# measure 1000 1000 11 50; measure 1000 10000 11 50
# aggregate 1000 1000; aggregate 1000 10000
# fit 1000 1000; fit 1000 10000
# plot 1000 1000 >> $batchFile; plot 1000 10000 >> $batchFile

### 10000 10/100 (50)
# measure 10000 10 11 50; measure 10000 100 11 50
# aggregate 10000 10; aggregate 10000 100
# fit 10000 10; fit 10000 100
# plot 10000 10 >> $batchFile; plot 10000 100 >> $batchFile

### 50000 1/10 (50)
# measure 50000 1 1 10; measure 50000 10 1 10
# aggregate 50000 10; aggregate 50000 1
# fit 50000 10; fit 50000 1
# plot 50000 10 >> $batchFile; plot 50000 1 >> $batchFile

### 100000 1 (50)
# measure 100000 1 1 10
# aggregate 100000 1
# fit 100000 1
# plot 100000 1 >> $batchFile

### 1000000 1 (1)
# measure 1000000 1 1 1
# aggregate 1000000 1
# fit 1000000 1
# plot 1000000 1 >> $batchFile

# fit 0 0
# plot 0 0 >> $batchFile





./jobs.sh bulkCreate $batchFile