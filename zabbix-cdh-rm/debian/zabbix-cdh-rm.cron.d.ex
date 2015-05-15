#
# Regular cron jobs for the zabbix-cdh-rm package
#
0 4	* * *	root	[ -x /usr/bin/zabbix-cdh-rm_maintenance ] && /usr/bin/zabbix-cdh-rm_maintenance
