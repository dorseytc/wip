#!/bin/bash
# 
# compare.sh
#
# compare updated scripts from other sources into working repository
# 
# TDORSEY 2022-04-20 Created

source_dir=$1
search_str=$2
target_dir=$3
datetime=`date +%Y%m%d_%H%M%S`
filecount=0
fileconflicts=0
echo Running at ${datetime}
if [ -z "${source_dir}" ] || [ -z "${search_str}" ] || [ -z "${target_dir}" ]; then
  echo "usage: $0 source_dir search_str target_dir"
elif [ ! -d "${source_dir}" ]; then
  echo "Source directory $source_dir not found"
elif [ ! -d "${target_dir}" ]; then
  echo "Target directory $target_dir not found"
else
  cd $target_dir
  sudo find $source_dir -type f -exec grep -l $search_str {} \; > /tmp/pull.list
  while read f ; 
  do
      ((filecount=filecount+1))
      target_file=${target_dir}${f}
      if [ -f "${target_file}" ]; then
        echo Comparing $f to $target_file
        diffcount=`diff -q $f $target_file | wc -l`
        echo diffcount is $diffcount
        if [ $diffcount -eq 1 ]; then
          echo Files are different 
          diff $f $target_file
          ((fileconflicts=fileconflicts+1))
        else
          echo Files are identical 
        fi
      else
        echo "${target_file}" not found on target
      fi 
      echo "---"
    done < /tmp/pull.list 
fi
echo Filecount $filecount

if [ "$filecount" -gt 0 ]; then
  echo $filecount files and $fileconflicts conflicts
else
  echo "Nothing to do"
fi
