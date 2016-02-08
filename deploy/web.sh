#!/bin/bash

source ../analysis/config.sh

target="/Users/benni/TUD/Projects/DNA/DNA.web/web/use_cases/gds/gdsMeasurements"

valueIndexes=(-2 2 -5 5)
valueNames=(avg avg+sd med med+sd)
sizes=(0 100 1000 10000 50000 100000)

echo '<?php require("../../../layout/header.php"); ?>' > $target/index.php

echo '<h1>Functions</h1>' >> $target/index.php
echo '<ul>' >> $target/index.php
for dt in ${dataTypes[@]}; do
	for size in ${sizes[@]}; do
		name="$dt-$size"
		echo "<li>$name:" >> $target/index.php
		for i in ${!valueIndexes[@]}; do
			filename="$name-${valueIndexes[$i]}"
			./html-functions.sh $aggrFitDir-${valueIndexes[$i]} $dt $size > $target/functions-$filename.php
			echo " &nbsp; &nbsp; <a href='functions-$filename.php'>${valueNames[$i]}</a>" >> $target/index.php
		done
		echo "</li>" >> $target/index.php
	done
done
echo '</ul>' >> $target/index.php

echo '<h1>Plots</h1>' >> $target/index.php
echo '<ul>' >> $target/index.php
for dt in ${dataTypes[@]}; do
	for size in ${sizes[@]}; do
		name="$dt-$size"
		echo "<li>$name:" >> $target/index.php
		for i in ${!valueIndexes[@]}; do
			filename="$name-${valueIndexes[$i]}"
			./html-plots.sh $aggrFitDir-${valueIndexes[$i]} $dt $size > $target/functions-$filename.php
			echo " &nbsp; &nbsp; <a href='plots-$filename.php'>${valueNames[$i]}</a>" >> $target/index.php
		done
		echo "</li>" >> $target/index.php
	done
done
echo '</ul>' >> $target/index.php

echo '<?php require("../../../layout/footer.php"); ?>' >> $target/index.php




rsync -auvzl data $target/

open http://localhost/use_cases/gds/gdsMeasurements/