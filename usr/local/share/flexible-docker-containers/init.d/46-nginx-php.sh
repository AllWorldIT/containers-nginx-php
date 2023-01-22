#!/bin/bash
# Copyright (c) 2022-2023, AllWorldIT.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.


fdc_notice "Initializing Nginx PHP settings"

# Default to UTC timezone
if [ -z "$PHP_TIMEZONE" ]; then
	PHP_TIMEZONE=UTC
fi
fdc_notice "Setting PHP timezone to '$PHP_TIMEZONE'"
# Check if we have a timezone and set it
cat <<EOF > "/etc/$PHP_NAME/conf.d/20-fdc-timezone.ini"
[Date]
date.timezone=$PHP_TIMEZONE
EOF


#
# Check if we need to adjust php-fpm settings
#

if [ -n "$PHP_FPM_MAX_CHILDREN" ]; then
	fdc_notice "Setting php-fpm max children to '$PHP_FPM_MAX_CHILDREN'"
	sed -i -e "s/pm.max_children = 5/pm.max_children = $PHP_FPM_MAX_CHILDREN/" "/etc/$PHP_NAME/php-fpm.d/www.conf"
fi

if [ -n "$PHP_FPM_START_SERVERS" ]; then
	fdc_notice "Setting php-fpm start servers to '$PHP_FPM_START_SERVERS'"
	sed -i -e "s/pm.start_servers = 2/pm.start_servers = $PHP_FPM_START_SERVERS/" "/etc/$PHP_NAME/php-fpm.d/www.conf"
fi
