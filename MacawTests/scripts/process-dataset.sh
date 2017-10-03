#!/bin/bash

source settings.sh

if [ ! -d "${PROCESSED_DATASET}" ]; then
	mkdir -p ${PROCESSED_DATASET}
fi

for i in $(ls ${ORIGINAL_DATASET}); do 
	DST="${i}.svg"
	./trim-svg.py ${ORIGINAL_DATASET}/$DST >${PROCESSED_DATASET}/$DST
	./svg2png.sh "${PROCESSED_DATASET}/$DST"  "${REFERENCE_PNG}/${i}.png"
done 
