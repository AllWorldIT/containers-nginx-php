#!/bin/sh

set -e

# Execute any pre-init scripts
find /docker-entrypoint-pre-init.d -type f -name '*.sh' | sort | while read i
do
	if [ -e "${i}" ]; then
		echo "INFO: pre-init.d - Processing [$i]"
		. "${i}"
	fi
done


# Check if we need to enable postfix
if [ -n "$START_POSTFIX" ]; then
	# Sanity checks
	if [ -z "$POSTFIX_ROOT_ADDRESS" ]; then
		echo "ERROR: POSTFIX_ROOT_ADDRESS must be specified when using Postfix"
		exit 1
	fi
	if [ -z "$POSTFIX_MYHOSTNAME" ]; then
		echo "ERROR: POSTFIX_MYHOSTNAME must be specified when using Postfix"
		exit 1
	fi
	if [ -z "$POSTFIX_RELAYHOST" ]; then
		echo "ERROR: POSTFIX_RELAYHOST must be specified when using Postfix"
		exit 1
	fi

	# Setup supervisord for postfix
	mv /etc/supervisor/conf.d/postfix.conf.disabled /etc/supervisor/conf.d/postfix.conf

	echo "### START DOCKER CONFIG ###" >> /etc/postfix/main.cf
	echo "myhostname = $POSTFIX_MYHOSTNAME" >> /etc/postfix/main.cf
	echo "smtpd_banner = \$myhostname ESMTP" >> /etc/postfix/main.cf
	echo "mydestination = \$myhostname, $HOSTNAME, localhost.localdomain, localhost" >> /etc/postfix/main.cf
	echo "relayhost = $POSTFIX_RELAYHOST" >> /etc/postfix/main.cf
	echo "# Output logs to stdout" >> /etc/postfix/main.cf
	echo "maillog_file = /dev/stdout" >> /etc/postfix/main.cf
	echo "disable_vrfy_command = yes" >> /etc/postfix/main.cf
	echo "smtpd_helo_required = yes" >> /etc/postfix/main.cf
	echo "strict_rfc821_envelopes = yes" >> /etc/postfix/main.cf
	echo "message_size_limit = 102400000" >> /etc/postfix/main.cf
	echo "### END DOCKER CONFIG ###" >> /etc/postfix/main.cf

	# Setup aliases
	echo "### START DOCKER CONFIG ###" > /etc/postfix/aliases
	echo "root: $POSTFIX_ROOT_ADDRESS" >> /etc/postfix/aliases
	echo "abuse: root" >> /etc/postfix/aliases
	echo "admin: root" >> /etc/postfix/aliases
	echo "administrator: root" >> /etc/postfix/aliases
	echo "webmaster: root" >> /etc/postfix/aliases
	echo "postmaster: root" >> /etc/postfix/aliases
	echo "hostmaster: root" >> /etc/postfix/aliases
	echo "noreply: root" >> /etc/postfix/aliases
	echo "### END DOCKER CONFIG ###" >> /etc/postfix/aliases

	newaliases
fi


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
