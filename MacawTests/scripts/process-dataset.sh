#!/bin/bash

source settings.sh

#for i in $(ls ${ORIGINAL_DATASET}); do 
while read i; do
	DST="${i}.svg"
	./trim-svg.py ${ORIGINAL_DATASET}/$DST >${PROCESSED_DATASET}/$DST
	./svg2png.sh "${PROCESSED_DATASET}/$DST"  "${REFERENCE_PNG}/${i}.png"
done < all
