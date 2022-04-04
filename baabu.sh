#!/bin/bash
#
#       baabu=better all-around backup
# 
#       New backup method which grooms moved and deleted files
#       Two modes of operation (M, B)
# 
#       M = Migrate 
#           Make an updated copy of source on target
#           Remove files from target which are no longer on source
#
#       B = Backup
#           Make an updated backup of files from source to target
#           Do not remove deleted files
#       
#       
# TDORSEY 2022-04-02 Created
# TDORSEY 2022-04-04 Safety checks around GLOBAL CACHE clearing

source /etc/baabu.conf

# this script uses sudo
sudo -v

#
# RUNTIME VARIABLES
#
#
prog=$(basename $0)
today=`date +%Y%m%d_%H%M%S`
log=/tmp/$prog__$today.log 


# 
# LOCK THREAD
#
#
if [ "$prog" = "bash" ]; then
  logger -s -t $prog "Do not run as source"
  return 1
elif test -f "/tmp/$prog.lock"; then
  logger -s -t $prog "$prog is already running $today" 
  return 1
else
  logger -s -t $prog "Starting $prog" 
  logger -s -t $prog "Today is $today"
  logger -s -t $prog "Log is $log" 
  echo "Starting $prog at $today" | tee $log > /tmp/$prog.lock 
fi

#
#
# MAIN
#
#
banner $prog 
DID_STUFF="N"

#
#
# GLOBAL CACHE
# 
#     
keyword="/.cache/"
echo keyword is $keyword
logger -s -t $prog "kill cache"
if [ -z "$GLOBAL_CACHE" ]; then
  logger -s -t $prog "Global Cache not specified"
elif [ ! -d "$GLOBAL_CACHE" ]; then
  logger -s -t $prog "Invalid path $GLOBAL_CACHE"
elif [[ "$GLOBAL_CACHE" == *"$keyword"* ]]; then
  logger -s -t $prog "Clear Cache $GLOBAL_CACHE"
  find $GLOBAL_CACHE -type f -exec rm -v {} \; | tee -a $log
  DID_STUFF="Y"
else 
  logger -s -t $prog "Invalid cache $GLOBAL_CACHE missing keyword $keyword"
fi

#
#
# RSYNC 
#
#
USER=$1
MODE=$2
if [ $# -eq 0 ]; then
  logger -s -t $prog "No backup arguments specified" 
elif [ -z "$USER" ]; then
  logger -s -t $prog "No user specified"
elif [ ! -d "/home/$USER" ]; then
  logger -s -t $prog "No home for $USER found" 
elif [ "$MODE" = "M" ]; then
  logger -s -t $prog "Migrate mode for user $USER"
  logger -s -t $prog "rsync with delete option" 
  logger -s -t $prog "Source /home/$USER"
  logger -s -t $prog "Target $MIGRATION_TARGET/$USER/"
  echo rsync -avv --delete --progress -e ssh /home/$USER $MIGRATION_USER:$MIGRATION_TARGET/$USER/ | tee -a $log
  #sudo rsync -avv --delete --progress -e ssh /home/$USER $MIGRATION_USER:$MIGRATION_TARGET/$USER/ | tee -a $log
  DID_STUFF="Y"
elif [ "$MODE" = "B" ]; then
  logger -s -t $prog "Backup mode for user $USER"
  logger -s -t $prog "rsync with no delete option"
else
  logger -s -t $prog "Unrecognized option $MODE for user $USER"
fi

#
#
# FOOTER
#
banner done
if [ "$DID_STUFF" = "Y" ]; then
  decached=`grep removed $log | wc -l`
  skipped=`grep uptodate $log | wc -l`
  deleted=`grep deleting $log | wc -l`
  backedup=`grep 100\% $log | wc -l`
  logger -s -t $prog "Detailed log in $log" 
  logger -s -t $prog "$skipped unchanged files were skipped" 
  logger -s -t $prog "$deleted files removed, no longer on source" 
  logger -s -t $prog "$decached files removed from cache" 
  logger -s -t $prog "$backedup files backed up" 
else
  logger -s -t $prog "Did nothing"
fi


#
#
# UNLOCK THREAD
#
#
rm /tmp/$prog.lock
logger -s -t $prog "Stopping $prog" 
