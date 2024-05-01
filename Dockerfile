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


FROM registry.conarx.tech/containers/nginx/edge

ARG VERSION_INFO=
LABEL org.opencontainers.image.authors   "Nigel Kukard <nkukard@conarx.tech>"
LABEL org.opencontainers.image.version   "edge"
LABEL org.opencontainers.image.base.name "registry.conarx.tech/containers/nginx/edge"


ENV PHP_NAME=php82
ENV PHP_FPM_NAME=php-fpm82
ENV PHP_VERSION=8.2

RUN set -eux; \
	true "php-fpm"; \
	apk add --no-cache $PHP_NAME \
		$PHP_NAME-bcmath \
		$PHP_NAME-brotli \
		$PHP_NAME-ctype \
		$PHP_NAME-curl \
		$PHP_NAME-dom \
		$PHP_NAME-exif \
		$PHP_NAME-fileinfo \
		$PHP_NAME-fpm \
		$PHP_NAME-gd \
		$PHP_NAME-gettext \
		$PHP_NAME-gmp \
		$PHP_NAME-iconv \
		$PHP_NAME-imap \
		$PHP_NAME-intl \
		$PHP_NAME-json \
		$PHP_NAME-ldap \
		$PHP_NAME-mysqli \
		$PHP_NAME-mysqlnd \
		$PHP_NAME-mbstring \
		$PHP_NAME-opcache \
		$PHP_NAME-openssl \
		$PHP_NAME-pcntl \
		$PHP_NAME-pdo_mysql \
		$PHP_NAME-pdo_pgsql \
		$PHP_NAME-pecl-apcu \
		$PHP_NAME-pecl-imagick \
		$PHP_NAME-pecl-mailparse \
		$PHP_NAME-pecl-maxminddb \
		$PHP_NAME-pecl-memcache \
		$PHP_NAME-pecl-memcached \
		$PHP_NAME-pecl-mongodb \
		$PHP_NAME-pecl-redis \
		$PHP_NAME-pecl-uploadprogress \
		$PHP_NAME-pecl-uuid \
		$PHP_NAME-pecl-zstd \
		$PHP_NAME-pgsql \
		$PHP_NAME-phar \
		$PHP_NAME-posix \
		$PHP_NAME-session \
		$PHP_NAME-simplexml \
		$PHP_NAME-soap \
		$PHP_NAME-sockets \
		$PHP_NAME-sodium \
		$PHP_NAME-sqlite3 \
		$PHP_NAME-sysvsem \
		$PHP_NAME-xml \
		$PHP_NAME-xmlreader \
		$PHP_NAME-xmlwriter \
		$PHP_NAME-xsl \
		$PHP_NAME-zip \
		graphviz ttf-droid ttf-liberation ttf-dejavu ttf-opensans \
		; \
	# Symlink php for backwards compatibility
	ln -s /usr/bin/$PHP_NAME /usr/bin/php; \
	ln -s /usr/sbin/$PHP_FPM_NAME /usr/sbin/php-fpm; \
	true "Cleanup"; \
	rm -f /var/cache/apk/*


# Nginx - override the default vhost to include PHP support
COPY etc/nginx/http.d/50_vhost_default.conf.template /etc/nginx/http.d
COPY etc/nginx/http.d/55_vhost_default-ssl-certbot.conf.template /etc/nginx/http.d


# php-fpm
COPY etc/php/conf.d/20_fdc_defaults.ini /etc/$PHP_NAME/conf.d
COPY etc/php/php-fpm.d/www.conf /etc/$PHP_NAME/php-fpm.d
COPY etc/supervisor/conf.d/php-fpm.conf /etc/supervisor/conf.d
COPY usr/local/share/flexible-docker-containers/init.d/46-nginx-php.sh /usr/local/share/flexible-docker-containers/init.d
COPY usr/local/share/flexible-docker-containers/pre-init-tests.d/46-nginx-php.sh /usr/local/share/flexible-docker-containers/pre-init-tests.d
RUN set -eux; \
	true "Flexible Docker Containers"; \
	if [ -n "$VERSION_INFO" ]; then echo "$VERSION_INFO" >> /.VERSION_INFO; fi; \
	chown root:root \
		/etc/nginx/http.d/50_vhost_default.conf.template \
		/etc/nginx/http.d/55_vhost_default-ssl-certbot.conf.template \
		/etc/$PHP_NAME/conf.d/20_fdc_defaults.ini \
		/etc/$PHP_NAME/php-fpm.d/www.conf; \
	chmod 0644 \
		/etc/nginx/http.d/50_vhost_default.conf.template \
		/etc/nginx/http.d/55_vhost_default-ssl-certbot.conf.template \
		/etc/$PHP_NAME/conf.d/20_fdc_defaults.ini \
		/etc/$PHP_NAME/php-fpm.d/www.conf; \
	true "Permissions"; \
	fdc set-perms
