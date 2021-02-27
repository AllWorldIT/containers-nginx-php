#!/bin/sh

# Check if we need to enable ionCube
if [ "$ENABLE_IONCUBE" == "yes" ]; then
	echo "PHP: Enabling IONCUBE"
	mv /etc/php7/conf.d/00_ioncube.ini.disabled /etc/php7/conf.d/00_ioncube.ini
fi
