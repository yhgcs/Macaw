#!/bin/sh

SRC=$1 # svg file
DST=$2 # out file

# DST=$(basename "$SRC")
# DST="/Users/ykashnikov/exyte/svg-test-suite/$OUTDIR/${DST%.*}.png"

RELSRC=`python -c "import os.path; print os.path.relpath('$SRC', '$PWD')"`

echo "DST=$DST"
echo "SRC=$SRC"
echo "SRC=$RELSRC"


python -m SimpleHTTPServer 8008 &
sleep 2
serverpid=$!
cp drawsvg.template drawsvg.html 
export PATH=$PATH:/usr/local/bin/chromedriver
$PWD/download.py $RELSRC
mv ~/Downloads/fallback.png $DST
kill -9 $serverpid
