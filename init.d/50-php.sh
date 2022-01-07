#!/bin/sh

# Check if we have a timezone and set it
if [ -n "$PHP_TIMEZONE" ]; then
	cat <<EOF >> /etc/$PHP_NAME/conf.d/50-docker.ini

[Date]
date.timezone=${PHP_TIMEZONE}

EOF
fi

