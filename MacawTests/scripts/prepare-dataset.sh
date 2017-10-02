#!/bin/bash

for i in $(ls orig); do 
	DST=$(basename $i)
	echo $i
	./trim-svg.py orig/$i >in/$DST
	./svg2png.sh "in/$DST" 
done
