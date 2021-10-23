#!/bin/bash
BATCH_SIZE=4
OUT_DIR=out

mkdir -p $OUT_DIR
DIR=$(pwd)
cd $(mktemp -d)
ls -dt1 $DIR/*.mp4 | split -l $BATCH_SIZE -d

for l in ./*; do
	MIN_DATE=$(stat "$(head -n 1 $l)" | date "+%F_%b_%H_%M_%S")
	cat $l | sed "s/^/file '/g" | sed "s/$/'/g" > $l.f
	l=$l.f
	ffmpeg -y -hide_banner -loglevel error -safe 0 -f concat -i $l -c copy $DIR/$OUT_DIR/$MIN_DATE.mp4
done

TMP=$(pwd)
cd $DIR
rm -rf $TMP
