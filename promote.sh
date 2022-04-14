#!/bin/bash
# Promote a file to /usr/local/bin and set permissions
#
#  TDORSEY 2022-02-03  Created
#
if [ $# -eq 0 ] 
then
  echo "No arguments provided"
else
  echo Promoting $1
  if [ -f "$1" ]
  then
    if [ -f "/usr/local/bin/$1" ]
    then
      echo Target file /usr/local/bin/$1 exists
      diff -sq $1 /usr/local/bin/$1
      echo Did not promote local file $1
    else
      sudo mv $1 /usr/local/bin
      sudo chown root /usr/local/bin/$1
      sudo chgrp root /usr/local/bin/$1
      sudo chmod 755 /usr/local/bin/$1
      echo $1 promoted to /usr/local/bin
      echo $1 removed from local directory
    fi
  else
    echo File "$1" not found
  fi
fi
