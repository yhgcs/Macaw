#!/bin/bash

source settings.sh

for i in $(ls ${ORIGINAL_DATASET}); do 
	DST=$(basename $i)
	echo $i
	./trim-svg.py ${ORIGINAL_DATASET}/$i >${PROCESSED_DATASET}/$DST
	./svg2png.sh "${PROCESSED_DATASET}/$DST"  "${REFERENCE_PNG}/$DST"
done
