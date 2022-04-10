#
# Regular cron jobs for the bashy package
#
0 4	* * *	root	[ -x /usr/bin/bashy_maintenance ] && /usr/bin/bashy_maintenance
