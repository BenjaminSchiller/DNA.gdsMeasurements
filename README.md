# DNA.gdsMeasurements

In this repo, we provide java code and scripts for performing a performance analysis of data structures for the use in DNA.
From these measurements, functions are fitted to be used during recommendation of data structures in DNA.


## repo structure

	analysis/ - analysis scripts
	build/ - ant build file and .jar files
	deploy/ - deployment scripts for execution on remote server
	java/ - java files (requires DNA)


## workflow

	measurement -> concat / aggregation -> fit -> functions [-> plot]

During measurement (`measurement.sh`), the runtimes for executing all operations on a data structure of growing size are generated.
These measurements for multiple repetitions are then either concatenated (`concat.sh`) or aggregated (`aggregation.sh`).
Using them as input, functions are fit and written by their quality to a file (`fit.sh`).
These function can then be extracted to be used with DNA (as a config file) (`functions.sh`).
Finally / in addition, these results can be plotted (`plot.sh`).


## configuration

The configuration is stored in `analysis/config.sh`.
The entries list names for the directories the results are stored in as well as the data types, data structures, and operations to be measured.

	dataDir="data/measurements"
	plotDir="data/plots"

	concatDir="data/concat"
	concatFitDir="data/concatFits"

	aggrDir="data/aggr"
	aggrFitDir="data/aggrFits"

	operations=(INIT ADD_SUCCESS ADD_FAILURE RANDOM_ELEMENT SIZE ITERATE CONTAINS_SUCCESS CONTAINS_FAILURE GET_SUCCESS GET_FAILURE REMOVE_SUCCESS REMOVE_FAILURE)

	dataStructures=(DArray DArrayList DHashSet DHashMap DHashTable)

	dataTypes=(Node Edge)


## `.jar` files

### `aggregation.jar`

used to aggregate multiple runs of a single configuration:

	expecting 4 arguments (got 0)
	   0: dir - path to directory where the dat files are located (String)
	   1: suffix - suffix of the files in dir to aggregate (String)
	   2: lines - number of lines in the file to aggregate (Integer)
	   3: index - index of the row that should be aggregated (starting with 0) (Integer)

### `measurement.jar`

used to perform the measurements:

	expecting 6 arguments (got 0)
	   0: datastructureType - full class name of the data structrue to measure (Class)
	   1: elementType - type of data stored in the list (String)
	      values:  Node Edge
	   2: maxListSize - size to grow the list to (and measure operation runtimes) (Integer)
	   3: parallelLists - parallel executions (runtime averaged) (Integer)
	   4: maxListSizeInit - (INIT) size to grow the list to (and measure operation runtimes) (Integer)
	   5: parallelListsInit - (INIT) parallel executions (runtime averaged) (Integer)




## scripts

For each part of the workflow, there is a separate script.
All scripts are located in `analysis/`.

For each script, we simple list the possible arguments in the hope that they are self-explanatory.

### `measurement.sh`

	./measurement.sh $dataType $size $parallel $dataStructure $run

### `concat.sh`

	./concat.sh all
	./concat.sh all $dataType
	./concat.sh all $dataType $dataStructure
	
	./concat.sh single
	./concat.sh single $dataType
	./concat.sh single $dataType $size $parallel
	./concat.sh single $dataType $size $parallel $dataStructure


### `aggregation,sh`

	./aggregation.sh
	./aggregation.sh $dataType
	./aggregation.sh $dataType $size $parallel
	./aggregation.sh $dataType $size $parallel $dataStructure


### `fit.sh`

	./fit.sh aggr $valueIndex
	./fit.sh aggr $valueIndex $dataType
	./fit.sh aggr $valueIndex $dataType $size $parallel
	./fit.sh aggr $valueIndex $dataType $size $parallel $dataStructure
	
	./fit.sh concat all
	./fit.sh concat all	$dataType
	./fit.sh concat all	$dataType $size $parallel
	./fit.sh concat all	$dataType $size $parallel $dataStructure
	
	./fit.sh concat single
	./fit.sh concat single	$dataType
	./fit.sh concat single	$dataType $size $parallel
	./fit.sh concat single	$dataType $size $parallel $dataStructure


### `functions.sh`

	./functions.sh aggr
	./functions.sh aggr $dataType $size $parallel $dataStructure
	
	./functions.sh concat
	./functions.sh concat $dataType $size $parallel $dataStructure


### `plot.sh`

	./plots.sh $size $parallel



## result directory structure

The general format for output is the following:

	data/$resultType/$dataType/$size/$parallel/$dataStructure/$operation.$ext

	$resultType - (aggr aggrFits concatFits measurements)
	$dataType - (Edge Node)
	$size - (maximum list size)
	$parallel - (lists executed in parallel)
	$dataStructure - (DArray DArrayList DHashMap DHashSet DHashTable)
	$operation - (INIT ADD_SUCCESS ADD_FAILURE RANDOM_ELEMENT SIZE ITERATE CONTAINS_SUCCESS CONTAINS_FAILURE GET_SUCCESS GET_FAILURE REMOVE_SUCCESS REMOVE_FAILURE)
	$ext - (dat aggr fit functions)

The combinations of resultType and ext are:

	aggr/ .aggr
	aggrFits/ .fit .functions
	concatFits/ .fit .functions
	measurements/ .dat

Similarly, the file structure for concated files is the following:

	data/$resultType/$dataType/$size/$parallel/$dataStructure.concat
	data/$resultType/$dataType/$dataStructure.concat



## file formats

### measurement - `.dat`

These files are the reult of performing a measurement.
The first 7 lines contain information about the measurement.
Each additional line consists of the runtime measured for each operation for a given list size (first field).
As an example, consider the head of the following file which would be stored in `data/measurements/Edge/100/10000/DArray/1.dat`:

	# DArray (datastructureType)
	# GlobalEdgeList (listType)
	# 100 (maxListSize)
	# 10000(parallelLists)
	# 500 (maxListSizeInit)
	# 5 (parallelListsInit)
	SIZE	INIT	ADD_SUCCESS	ADD_FAILURE	RANDOM_ELEMENT	SIZE	ITERATE	CONTAINS_SUCCESS	CONTAINS_FAILURE	GET_SUCCESS	GET_FAILURE	REMOVE_SUCCESS	REMOVE_FAILURE
	1	1824.8	1326.1	1068.6	1457.0	4.4	1351.1	514.5	107.4	764.9	1308.5	474.6	3018.6
	2	5235.4	813.6	1007.0	3752.4	239.3	580.9	91.6	128.4	239.8	305.2	115.7	552.6
	3	3833.0	104.0	85.1	195.3	43.7	530.4	25.9	18.5	8.9	343.0	129.1	838.0
	4	2774.9	68.2	60.2	102.9	39.5	619.3	108.7	103.1	323.4	373.2	106.0	887.3

Each data point (is the runtime of executing the respective operation on `$parallelLists` many list of given size (first field) divides by `$parallelLists`.

Each line of measurements contains the runtimes for all operations in the following order:

	#  1: SIZE
	#  2: INIT
	#  3: ADD_SUCCESS
	#  4: ADD_FAILURE
	#  5: RANDOM_ELEMENT
	#  6: SIZE
	#  7: ITERATE
	#  8: CONTAINS_SUCCESS
	#  9: CONTAINS_FAILURE
	# 10: GET_SUCCESS
	# 11: GET_FAILURE
	# 12: REMOVE_SUCCESS
	# 13: REMOVE_FAILURE


### concat - `.concat`

These files are a concatenation of multiple `.dat` files.
Either multiple runs of a single configuration or all runs of all configurations.


### aggregation - `.aggr`

These files are an aggregation of multiple runs of the same configuration, i.e., multiple `.dat` files in the same dir.

The following is an example:

	# ADD_FAILURE
	# aggregation of 50 runs
	size	avg	min	max	med	var	varLow	varUp
	1	369.2980000000001	20.8	1068.6	364.7	51126.670995999986	51126.670995999986	34814.36296696299
	2	160.032	45.0	1007.0	52.7	43184.088176000005	43184.088176000005	10965.177478054055
	3	66.96	48.4	157.7	52.1	729.4671999999998	729.4671999999998	244.29742857142836

The first three lines are comments.
The following lines are the aggregation of the mesurements of each runtime for the respective list size.
Each line contains the aggregated values in the following order:

	# 1: size
	# 2: avg
	# 3: min
	# 4: max
	# 5: med
	# 6: var
	# 7: varLow
	# 8: varUp


### fit - `.fit`

These files contain the output (stderr) of the gnuplot fit function.
The following is an example of the beginning

	 Iteration 0
	 WSSR        : 538233            delta(WSSR)/WSSR   : 0
	 delta(WSSR) : 0                 limit for stopping : 1e-05
	 lambda	  : 41.137
	
	initial set of free parameter values
	
	a               = 1
	b               = 1
	/

and the end of such a file:

	After 3 iterations the fit converged.
	final sum of squares of residuals : 205960
	rel. change during last iteration : -8.90562e-09
	
	degrees of freedom    (FIT_NDF)                        : 98
	rms of residuals      (FIT_STDFIT) = sqrt(WSSR/ndf)    : 45.8435
	variance of residuals (reduced chisquare) = WSSR/ndf   : 2101.63
	
	Final set of parameters            Asymptotic Standard Error
	=======================            ==========================
	
	f               = 10.7052          +/- 18.63        (174%)
	g               = 28.8563          +/- 4.965        (17.2%)
	
	
	correlation matrix of the fit parameters:
	
	               f      g      
	f               1.000 
	g              -0.969  1.000 



### fit - `.functions`

This file contains the fit functions, extracted from a `.fit` file and sorted by the quality specified by the WSSR.

	2 10.7052 + 28.8563 * log(x)
	10388894 66.775 + 0.111471 * x + 0.0127864 * x**2
	11296754 44.8208 + 1.4029 * x
