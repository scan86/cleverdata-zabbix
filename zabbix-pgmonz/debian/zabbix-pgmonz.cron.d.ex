#
# Regular cron jobs for the zabbix-pgmonz package
#
0 4	* * *	root	[ -x /usr/bin/zabbix-pgmonz_maintenance ] && /usr/bin/zabbix-pgmonz_maintenance
