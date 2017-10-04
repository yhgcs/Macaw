#!/bin/sh

source settings.sh

if [ -f "${DATA_FILE}" ]; then
	echo "Data file already exists. Please back it up if necessary and remove."
	exit 1
else 
	touch ${DATA_FILE}
fi

for i in $(ls ${MACAW_PNGS}); do
	NAME="${i%.*}"
	MACAW_PNG="${MACAW_PNGS}/$i"
	REFFILE="${REFERENCE_PNG}/$i"
	DIFF="${DIFF_FOLDER}/$i"
	diff=`./compare.sh ${MACAW_PNG} ${REFFILE} $DIFF | sed 's/^[ \t]*//'`
	x1=${diff/" "/","}
	x2=${x1/"("/""}
	x3=${x2/")"/""}
	echo "${NAME},${x3}" >> ${DATA_FILE}
done
