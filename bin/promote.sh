#!/bin/bash
# Promote a file to /usr/local/bin and set permissions
#
#  TDORSEY 2022-02-03  Created
#
if [ $# -eq 0 ]; then
  echo "No arguments provided"
else
  echo Promoting $1
  # assert sudo privs
  sudo -v
  if [ -f "$1" ]; then
    if [ -f "/usr/local/bin/$1" ]; then
      echo Target file /usr/local/bin/$1 exists
      count=`diff -q $1 /usr/local/bin/$1 | wc -l`
      if [ $count = 1 ]; then
        promote=Y
        echo Files are different
        if [ ! -d ".backup" ]; then 
          mkdir .backup
          echo created directory .backup
        fi  
        sudo mv /usr/local/bin/$1 .backup/$1
        echo backed up $1 to .backup/$1
        diff $1 .backup/$1
      else
        promote=N
        echo Files are identical
        echo Did not promote local file $1
      fi
    else
        promote=Y
    fi
    if [ "$promote" = "Y" ]; then
      sudo cp $1 /usr/local/bin
      sudo chown root /usr/local/bin/$1
      sudo chgrp root /usr/local/bin/$1
      sudo chmod 755 /usr/local/bin/$1
      echo $1 promoted to /usr/local/bin
    fi
  else
    echo File "$1" not found
  fi
fi
