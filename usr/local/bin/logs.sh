# logs.sh
# TDORSEY 2022-01-16 Created to better monitor messages
# TDORSEY 2022-03-18 Updated to monitor /var/log/* 
#                    Excluding subsystems which are in subdirectories

tail -f $(ls /var/log/*log | grep -v ufw)
