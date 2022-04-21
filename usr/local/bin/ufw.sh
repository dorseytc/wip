# ufw.sh
#
#   tail logs looking ufw messages                   
# 
# TDORSEY 2022-03-18 Created

tail -f $(ls /var/log/*log | grep ufw)
