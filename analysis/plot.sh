#!/bin/bash

source config.sh

if [[ ! -d $plotDir ]]; then mkdir -p $plotDir; fi

for dt in $(ls $dataDir); do
	for size in $(ls $dataDir/$dt); do
		for parallel in $(ls $dataDir/$dt/$size); do
			for ds in ${dataStructures[@]}; do
				for index in $(seq 0 11); do
					operation=${operations[$index]}
					# gnuplot -e "dataDir='$dataDir';plotDir='$plotDir';dt='$dt';size='$size';parallel='$parallel';operation='$operation'" plot-data.gp
					# gnuplot -e "dataDir='$dataDir';plotDir='$plotDir';dt='$dt';size='$size';parallel='$parallel';operation='$operation';index='$((index+2))'" plot-fitted.gp 2&> $plotDir/__$dt-$size-$parallel-$operation.txt
					functionFile="$aggrFitDir/$dt/$size/$parallel/$ds/$operation.functions"
					function1=$(head -n 1 $functionFile | tail -n 1)
					function1=${function1#* }
					function2=$(head -n 2 $functionFile | tail -n 1)
					function2=${function2#* }
					function3=$(head -n 3 $functionFile | tail -n 1)
					function3=${function3#* }

					# gnuplot -e "plotDir='$plotDir';aggrDir='$aggrDir';dt='$dt';size='$size';parallel='$parallel';ds='$ds';operation='$operation';index='$((index+2))';function1='$function1';function2='$function2';function3='$function3'" plot.gp

					echo "	set terminal png
							set output '$plotDir/$dt-$operation-$ds-$size-$parallel.png'
							data = '$aggrDir/$dt/$size/$parallel/$ds/$operation.aggr'
							set yrange [0:*]
							f1(x) = $function1
							f2(x) = $function2
							f3(x) = $function3
							plot 	data using 1:5 with dots lw 5 title 'median', \
									f1(x) with lines lw 5 title '$function1', \
									f2(x) with lines lw 2 title '$function2', \
									f3(x) with lines lw 2 title '$function3'" | gnuplot


				done
			done
		done
	done
done