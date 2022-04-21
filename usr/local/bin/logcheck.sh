#
# logcheck.sh
#
# after adding a XYZ.conf file to /etc/logrotate.d
# defining a log rotation for your custom log file under 
# /var/log/ (for example:  /var/log/xyz/xyz.log)
# confirm that logrotate is finding and managing those logs
#
# TDORSEY 2022-04-13 Created
sudo logrotate /etc/logrotate.conf --debug

