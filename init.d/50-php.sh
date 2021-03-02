#!/bin/sh

# Check if we need to enable ionCube
if [ "$ENABLE_IONCUBE" == "yes" ]; then
	echo "PHP: Enabling IONCUBE"
	mv /etc/php7/conf.d/00_ioncube.ini.disabled /etc/php7/conf.d/00_ioncube.ini
fi

# Check if we have a timezone and set it
if [ -n "$PHP_TIMEZONE" ]; then
	cat <<EOF >> /etc/php7/conf.d/50-docker.ini

[Date]
date.timezone=${PHP_TIMEZONE}

EOF
fi

