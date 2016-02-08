#!/bin/bash

source ../analysis/config.sh

echo '<?php require("../../../layout/header.php"); ?>'

if [[ $# = 3 ]]; then
	fitDir=$1
	dt=$2
	size=$3
	echo "<h1>$dt @ $size ($(ls $fitDir/$dt/$size))</h1>"
	count=$(ls $fitDir/$dt/$size | wc -l | xargs)
	for operation in ${operations[@]}; do
		echo "<table border='1'><tr><td colspan='$((count+1))' align='center'>$operation</td></tr><tr><td></td>"
		for parallel in $(ls $fitDir/$dt/$size); do
			echo "<td align='center'>$parallel</td>"
		done
		echo "</tr>"
		for ds in ${dataStructures[@]}; do
			echo "<tr><td>$ds</td>"
			for parallel in $(ls $fitDir/$dt/$size); do
				file="$fitDir/$dt/$size/$parallel/$ds/$operation.functions"
				functions=$(cat $file | head -n 1)
				functions=${functions#* }
				echo "<td style='font-weight:normal; font-size:8pt;'>$functions</td>"
			done
			echo "</tr>"
		done
		echo "</table>"
		echo "<br/>"
	done
else
	echo "expecting 3 arguments, got $#"
fi

echo '<?php require("../../../layout/footer.php"); ?>'