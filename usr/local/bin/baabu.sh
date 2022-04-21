#!/bin/bash
#
#       baabu 
#         better all-around backup
# 
#       New backup method which grooms moved and deleted files
#       Two modes of operation (M, B)
# 
# TDORSEY 2022-04-02 Created
# TDORSEY 2022-04-04 Safety checks around GLOBAL CACHE clearing
# TDORSEY 2022-04-10 Iterate through array of config items
#                    specified in /etc/baabu.conf
# TDORSEY 2022-04-12 Separate log files for each loop iteration
#                    to improve flexibility     
# TDORSEY 2022-04-13 Fixed log filename, added support for LOG_LEVEL
# TDORSEY 2022-04-15 
  
if [ -f "/etc/baabu.conf" ]; then
  source /etc/baabu.conf
else 
  echo "/etc/baabu.conf not found"
  exit 1
fi

# this script uses sudo
sudo -v

#
# RUNTIME VARIABLES
#
#
prog=$(basename $0)
echo prog=$prog
today=`date +%Y%m%d_%H%M%S`
echo today=$today
log=`echo /tmp/$prog\_\_\_$today.log`
echo log=$log
# 
# LOCK THREAD
#
#
if [ "$prog" = "bash" ]; then
  logger -s -t $prog "Do not run as source"
  exit 1
elif test -f "/tmp/$prog.lock"; then
  logger -s -t $prog "$prog is already running $today" 
  exit 1
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
  decached=`grep removed $log | wc -l`
  logger -s -t $prog "$decached files removed from cache" 
else 
  logger -s -t $prog "Invalid cache $GLOBAL_CACHE missing keyword $keyword"
fi

#
#
# RSYNC 
#
#
sectioncount=0
processcount=0
for i in "${!FROM_USER[@]}";
do 
  logger -s -t $prog "Begin Section $i"
  sectioncount=$((sectioncount+1))
  FROM_USER="${FROM_USER[$i]}"
  TO_USER="${TO_USER[$i]}" 
  TO_PATH="${TO_PATH[$i]}"
  MODE="${MODE[$i]}"
  ilog=`echo /tmp/$prog\_$i\_$today.log`
  echo FROM_USER=$FROM_USER | tee -a $ilog
  echo TO_USER=$TO_USER | tee -a $ilog
  echo TO_PATH=$TO_PATH | tee -a $ilog
  echo MODE=$MODE | tee -a $ilog
  echo ilog=$ilog | tee -a $ilog
  if [ -z "$FROM_USER" ]; then
    logger -s -t $prog "No user specified"
    echo "No user specified" >> $ilog
  elif [ ! -d "/home/$FROM_USER" ]; then
    logger -s -t $prog "No home for $FROM_USER found" 
    echo "No home for $FROM_USER found" >> $ilog
  elif [ "$MODE" = "M" ] || [ "$MODE" = "B" ] ; then
    if [ "$MODE" = "M" ]; then
       MODE_DESC=Migration
       DELETE_CLAUSE="--delete"
    else
       MODE_DESC=Backup
       DELETE_CLAUSE=""
    fi
    processcount=$((processcount+1))
    logger -s -t $prog "$MODE_DESC mode for user $FROM_USER"
    logger -s -t $prog "rsync $DELETE_CLAUSE"
    logger -s -t $prog "Source /home/$FROM_USER"
    logger -s -t $prog "Target $TO_USER"
    logger -s -t $prog "Target Path $TO_PATH/$FROM_USER/"
    logger -s -t $prog "rsync -avv $DELETE_CLAUSE --progress -e ssh /home/$FROM_USER $TO_USER:$TO_PATH/$FROM_USER/ "
    echo sudo rsync -avv $DELETE_CLAUSE --progress -e ssh /home/$FROM_USER $TO_USER:$TO_PATH/$FROM_USER/ | tee -a $ilog
    sudo rsync -avv $DELETE_CLAUSE --progress -e  ssh /home/$FROM_USER $TO_USER:$TO_PATH/$FROM_USER/ | tee -a $ilog
    skipped=`grep uptodate $ilog | wc -l`
    deleted=`grep deleting $ilog | wc -l`
    backedup=`grep 100\% $ilog | wc -l`
    logger -s -t $prog "$skipped unchanged files were skipped" 
    logger -s -t $prog "$deleted files removed, no longer on source" 
    logger -s -t $prog "$backedup files backed up" 
    logger -s -t $prog "Detailed log at $ilog"
  else
    logger -s -t $prog "Unrecognized option $MODE for user $USER"
  fi
  logger -s -t $prog "End Section $i"
done
#
#
#
# UNLOCK THREAD
#
#
rm /tmp/$prog.lock
logger -s -t $prog `echo Processed $processcount of $sectioncount Sections`

