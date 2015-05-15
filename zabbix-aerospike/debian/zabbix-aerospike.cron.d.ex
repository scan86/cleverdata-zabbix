#
# Regular cron jobs for the zabbix-aerospike package
#
0 4	* * *	root	[ -x /usr/bin/zabbix-aerospike_maintenance ] && /usr/bin/zabbix-aerospike_maintenance
