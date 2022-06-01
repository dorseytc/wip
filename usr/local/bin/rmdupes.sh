#!/bin/bash
# *** name ***
progname=$(basename $0)
backup_top=/tmp
today=`date +%Y%m%d_%H%M%S`
echo ""
echo Today is $today
echo ""
#2 GB
#MAX=2000000000
#500 MB
MAX=500000000
MIN=1000
echo Min size is $MIN 
echo Max size is $MAX
if [ $# -lt 2 ] ; then
  echo "Wrong arguments provided"
  echo "Usage is:"
  echo ""
  echo "$progname <target-directory> <delete-yn>"
  echo "" 
  option=X
elif [ ! -d "$1" ] ; then
  echo "Target directory $1 does not exist"
  option=X
elif [ $2 = "Y" ] || [ $2 = "y" ] ; then
  echo "You chose the DELETE option!  CTRL-C if incorrect"
  progname=rm
  option="-rdN --maxsize=$MAX --minsize=$MIN"
elif [ $2 = "N" ] || [ $2 = "n" ] ; then
  echo "You chose the LIST option!  CTRL-C if incorrect"
  progname=ls
  option="-r --maxsize=$MAX --minsize=$MIN"
else
  echo "Unrecognized value for <delete-yn>"
  echo ""
  echo "Specify Y or N"
  option=X
fi
if [ "$option" = "X" ] ; then 
  echo "Aborted"
else
  target=$1
  echo Target is $target
  out=$backup_top/$progname`echo $target | sed -e 's/\//-/g'`__$today.dupe
  echo Out is $out
  echo Option is $option
  sudo fdupes $option $target | tee -a $out
fi
