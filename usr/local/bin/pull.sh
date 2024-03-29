#!/bin/bash
# 
# pull.sh
#
# pull updated scripts from other sources into working repository
# 
# TDORSEY 2022-04-18 Created 
# TDORSEY 2022-04-20 Improved pulling, no backups
#                    the source was in git to begin with
#                    so what are you worried about
# TDORSEY 2022-04-25 Ignore files with SECRETS

source_dir=$1
search_str=$2
target_dir=$3
datetime=`date +%Y%m%d_%H%M%S`
filecount=0
pullcount=0
skipcount=0
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
  #check if there are uncommited things in git
  echo "Diff count is $diff_ct"
  if [[ $diff_ct -eq 0  ]]; then
    sudo find $source_dir -type f -exec grep -l $search_str {} \;  > /tmp/pull.list
    echo Files to be reviewed:
    cat /tmp/pull.list
    echo End of list
    while read f ; 
    do
      ((filecount=filecount+1))
      target_file=${target_dir}${f}
      secrets=`grep -l SECRET ${f} | wc -l`
      echo "${filecount} : Pull ${f} to ${target_file}"
      if [ $secrets -ne 0 ]; then
        reason="Skipping secret ${f}"
        pull=N
      elif [ ! -f "${target_file}" ]; then
        reason="File ${target_file} not found"
        pull=Y
      else
        diffcount=`diff -q $f $target_file | wc -l`
        if [ $diffcount -eq 1 ]; then
          reason="Target file ${target_file} is different"
	        pull=Y
        else
          reason="Files are identical"
	        pull=N
        fi
        target_path="$(dirname $target_file)"
        if [ ! -d "${target_path}" ]; then
          mkdir -p $target_path
          echo "Created ${target_path}"
        fi 
      fi
      if [ "$pull" = "Y" ]; then
        rsync -a $f $target_path
        echo "${f} pulled to ${target_path} (${reason})"
        ((pullcount=pullcount+1))
      else
        echo "${f} skipped (${reason})"
        ((skipcount=skipcount+1))
      fi
    done < /tmp/pull.list 
  else
    echo "${target_dir} needs a push"
  fi
fi
echo Filecount $filecount
echo Pullcount $pullcount
echo Skipcount $skipcount

if [ "$filecount" -gt 0 ]; then
  echo Pulled $pullcount of $filecount files
else
  echo "Nothing to do"
fi
