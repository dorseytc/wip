#!/bin/bash
# 
# pull.sh
#
# pull updated scripts from other sources into working repository
# 
# TDORSEY 2022-04-18 Created 
#

source_dir=$1
search_str=$2
target_dir=$3
datetime=`date +%Y%m%d_%H%M%S`
filecount=0
pullcount=0
echo Running at ${datetime}
if [ -z "${source_dir}" ] || [ -z "${search_str}" ] || [ -z "${target_dir}" ]; then
  echo "usage: $0 source_dir search_str target_dir"
elif [ ! -d "${source_dir}" ]; then
  echo "Source directory $source_dir not found"
elif [ ! -d "${target_dir}" ]; then
  echo "Target directory $target_dir not found"
else
  cd $target_dir
  diff_ct=`git diff --stat origin/main | wc -l`
  echo "Diff count is $diff_ct"
  if [[ $diff_ct -eq 0  ]]; then
    sudo find $source_dir -type f -exec grep -l $search_str {} \; > /tmp/pull.list
    echo Files to be reviewed:
    cat /tmp/pull.list
    echo End of list
    cat /tmp/pull.list | while read f; do
      filecount=$((filecount+1))
      echo File is $f
      target_file="${target_dir}${f}"
      echo Target file is $target_file
      if [ -f "${target_file}" ]; then
        diffcount=`diff -q $f $target_file | wc -l`
        if [ $diffcount -eq 1 ]; then
          echo Files are different
	        if [ ! -d "${target_dir}/.backup" ]; then
            mkdir ${target_dir}/.backup 
            echo created directory ${target_dir}/.backup
	        fi
           
          mv $target_file ${target_dir}/.backup${f}.${datetime}
	        echo backed up ${f} to ${target_dir}/.backup${f}.${datetime}
	        pull=Y
        else
          echo Files are identical
	        pull=N
        fi
      else
        echo File "${target_file}" not found
        pull=Y
      fi 
      if [ "$pull" = "Y" ]; then
        cp $f ${target_file}
        echo $f pulled to ${target_file}
        pullcount=$((pullcount+1))
      fi
    done; 
  else
    echo "${target_dir} needs a push"
  fi
fi
if [ "$filecount" -gt 0 ]; then
  echo Pulled $pullcount of $filecount files
else
  echo "Nothing to do"
fi
