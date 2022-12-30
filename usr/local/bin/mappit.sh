#!/bin/bash
#
# TDORSEY 2021-01-01 Created, probably
# TDORSEY 2022-02-02 Updated to support 'www' user as owner of content
# TDORSEY 2022-03-23 Check minecraft server status, last render status
#                    improve readability
# TDORSEY 2202-03-24 Standardize $logfile and $lock usage throughout
#                    Parameterize world location, executable name
#                    and output folder
# TDORSEY 2202-09-27 Fix lock bug; add FORCE mode
# TDORSEY 2202-09-28 Add config file
# TDORSEY 2202-10-04 Use pre-release minecraft overviewer
# TDORSEY 2202-12-29 Daemon-like as in always running
#                    
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin
logfile="see below"
lock=/tmp/mappit.lock
echo Lock = $lock
#
# installation specific variables 
#
mapper_exe=/home/ted/Minecraft/Overviewer/Minecraft-Overviewer/overviewer.py 
echo Mapper executable = $mapper_exe
#mapper_opt="--no-tile-checks"
#mapper_opt="--check-tiles"
#mapper_opt="--forcerender"
#mapper_opt="--verbose"
echo Mapper options = $mapper_opt
config_file=/home/ted/Minecraft/Overviewer/config.py
echo Config File = $config_file
#
# runtime-computed variables
server_proc_ct=$(ps -ef | grep "Minecraft\/server.jar" | wc -l)
echo Server process count $server_proc_ct

for (( ; ; ))
do
  hour=`date +%H`
  echo hour = $hour
  newlogfile=/tmp/mappit.$hour.log
  if [ "$newlogfile" = "$logfile" ]; then
    date | tee -a $logfile
    echo keep appending to $logfile | tee -a $logfile
  else
    logfile=$newlogfile
    date | tee $logfile
    echo New logfile = $logfile | tee $logfile
  fi
  if [ "$1" = "FORCE" ]; then
    echo "mappit is in FORCE mode" |tee -a $logfile
    update_map="Y"
    mapper_opt="--forcerender"
  elif test -f "$lock"; then
    date | tee $lock
    echo "mappit is already running" | tee -a $lock
    update_map="N" 
    break
  else
    echo Server Is Running $server_proc_ct | tee -a $logfile
    echo Previous log file $last_log_file | tee -a $logfile
    echo Number of empty runs $empty_run_ct | tee -a $logfile
    if [ $server_proc_ct -gt 0 ]; then
  
      #
      # if minecraft server process count > 0 then update the map
      # 
  
      update_map="Y"
  
    #elif [ $empty_run_ct = 0 ]; then
  
      #
      # if the last run wasn't empty, update the map
      # 
  
    #  update_map="Y"
  
    else 
  
      #
      # if server is not running and    
      # last run of the map rendered zero tiles
      # then we can skip updating the map
      # 
  
      echo "Server is not running" | tee -a $logfile
      #echo "Last update Rendered 0 of 0" | tee -a $logfile
      date | tee -a $logfile
      update_map="N"
    fi
  fi
   
  if [ "$update_map" = "N" ]; then
  
    echo "Skipping Mappit" | tee -a $logfile
  
  else
  
    echo "Starting Mappit" | tee -a $logfile
    # create the lock file
    date | tee $lock
    echo World location $world_location | tee -a $logfile
    echo Output folder $output_folder | tee -a $logfile
  
    # 
    # running the mapper executable 
    # 
  
    echo mapper command string | tee -a $logfile
    echo $mapper_exe --config=$config_file $mapper_opt | tee -a $logfile
    $mapper_exe --config=$config_file $mapper_opt | tee -a $logfile
  
    # 
    #
    #
  
    date | tee -a $logfile
    echo "Mappit is done" | tee -a $logfile
    # rm $lock
  
  fi
  echo sleeping for 5 minutes | tee -a $logfile
  sleep 5m
done
date | tee -a $logfile
echo "Exit already running"  
