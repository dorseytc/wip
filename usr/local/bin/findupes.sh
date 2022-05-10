#!/bin/bash
progname=$(basename $0)
today=`date +%Y%m%d_%H%M%S`
echo Today is $today
out=`echo $progname`__$today.dupe
echo Out is $out
target=~
echo Target is $target
sudo fdupes -r $target | tee $out
