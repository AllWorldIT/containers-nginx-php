#!/bin/sh

# Execute any pre-init scripts
find /docker-entrypoint-pre-init.d -type f -name '*.sh' | sort | while read i
do
	if [ -e "${i}" ]; then
		echo "INFO: pre-init.d - Processing [$i]"
		. "${i}"
	fi
done


# Execute any init scripts
find /docker-entrypoint-init.d -type f -name '*.sh' | sort | while read i
do
	if [ -e "${i}" ]; then
		echo "INFO: init.d - Processing [$i]"
		. "${i}"
	fi
done


# Execute any pre-exec scripts
find /docker-entrypoint-pre-exec.d -type f -name '*.sh' | sort | while read i
do
	if [ -e "${i}" ]; then
		echo "INFO: pre-exec.d - Processing [$i]"
		. "${i}"
	fi
done


#
# START Nginx
#

if [ ! -d /run/nginx ]; then
	mkdir /run/nginx
fi



echo 'INFO: Ready for start up'
exec /usr/bin/supervisord --config /etc/supervisor/supervisord.conf
