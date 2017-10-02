#!/bin/bash

SRCA=$1
SRCB=$2
DST=$3

rm -f result
magick compare -metric RMSE $SRCA $SRCB -highlight-color  PaleGreen  -lowlight-color White $DST >result 2>&1 3>&1
ae=`cat result`
rm -f result

echo "$SRC $ae"
