#!/bin/bash
#
# rmlist.sh
#
# TDORSEY 2022-02-13 Created
# TDORSEY 2022-04-23 Support empty directory removal
#

if [ $# -eq 0 ]; then
  echo "Argument required:  file name containing list of files"
else
  log=$1.log
  echo Parsing $1 | tee -a $log
  echo Log is $1 | tee -a $log
  while read -r linefromfile || [[ -n "${linefromfile}" ]]; do
    if [ -z "$linefromfile" ]; then
      echo ""
    elif [ -f "$linefromfile" ]; then
      rm -v "$linefromfile" | tee -a $log
    elif [ -d "$linefromfile" ]; then
      rmdir -v "$linefromfile" | tee -a $log
    else
      echo "$linefromfile" not found | tee -a $log
    fi
  done < "$1"
  echo Done with $1 | tee -a $log
fi
