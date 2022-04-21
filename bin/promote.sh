#!/bin/bash
# Promote a file to /usr/local/bin and set permissions
#
#  TDORSEY 2022-02-03  Created
#
filecount=0
promotecount=0
for var in "$@"
do 
  echo Promoting $var
  filecount=$((filecount+1))
  if [ -f "$var" ]; then
    if [ -f "/usr/local/bin/$var" ]; then
      echo Target file /usr/local/bin/$var exists
      count=`diff -q $var /usr/local/bin/$var | wc -l`
      if [ $count = 1 ]; then
        promote=Y
        echo Files are different
        if [ ! -d ".backup" ]; then 
          mkdir .backup
          echo created directory .backup
        fi  
        sudo mv /usr/local/bin/$var .backup/$var
        echo backed up $var to .backup/$var
        diff $var .backup/$var > .backup/$var.diff
      else
        promote=N
        echo Files are identical
        echo Did not promote local file $var
      fi
    else
        promote=Y
    fi
    if [ "$promote" = "Y" ]; then
      sudo cp $var /usr/local/bin
      sudo chown root /usr/local/bin/$var
      sudo chgrp root /usr/local/bin/$var
      sudo chmod 755 /usr/local/bin/$var
      echo $var promoted to /usr/local/bin
      promotecount=$((promotecount+1))
    fi
  else
    echo File "$var" not found
  fi
done
echo Promoted $promotecount of $filecount files
