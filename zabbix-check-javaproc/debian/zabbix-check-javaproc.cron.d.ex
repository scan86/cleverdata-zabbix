#
# Regular cron jobs for the zabbix-check-javaproc package
#
0 4	* * *	root	[ -x /usr/bin/zabbix-check-javaproc_maintenance ] && /usr/bin/zabbix-check-javaproc_maintenance
