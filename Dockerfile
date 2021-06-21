FROM registry.gitlab.iitsp.com/allworldit/docker/alpine:latest

ARG VERSION_INFO=
LABEL maintainer="Nigel Kukard <nkukard@LBSD.net>"

ENV PHP_VERSION=7.4
# Log support ticket at https://support.ioncube.com to get latest Alpine loader
ENV IONCUBE_VERSION=10.4.5

RUN set -ex; \
	true "Nginx"; \
	apk add --no-cache nginx; \
	ln -sf /dev/stdout /var/log/nginx/access.log; \
	ln -sf /dev/stderr /var/log/nginx/error.log; \
	true "PHP-FPM"; \
	apk add --no-cache php7 \
		php7-bcmath \
		php7-ctype \
		php7-curl \
		php7-dom \
		php7-exif \
		php7-fileinfo \
		php7-fpm \
		php7-gd \
		php7-gettext \
		php7-iconv \
		php7-imap \
		php7-intl \
		php7-json \
		php7-ldap \
		php7-mbstring \
		php7-mcrypt \
		php7-opcache \
		php7-openssl \
		php7-pecl-imagick \
		php7-phar \
		php7-posix \
		php7-session \
		php7-simplexml \
		php7-soap \
		php7-sockets \
		php7-sodium \
		php7-xml \
		php7-zip \
		graphviz ttf-droid ttf-liberation ttf-dejavu ttf-opensans \
		curl \
		; \
	true "php-fpm: IonCube config"; \
	echo "zend_extension=/usr/lib/php7/modules/ioncube_loader_alpine_${PHP_VERSION}_${IONCUBE_VERSION}.so" > /etc/php7/conf.d/00_ioncube.ini.disabled; \
	true "Users"; \
	adduser -u 82 -D -S -H -h /var/www/html -G www-data www-data; \
	true "Nginx conf.d"; \
	mkdir -p /etc/nginx/conf.d; \
	true "Web root"; \
	mkdir -p /var/www/html; \
	chown www-data:www-data /var/www/html; chmod 0755 /var/www/html; \
	true "Versioning"; \
	if [ -n "$VERSION_INFO" ]; then echo "$VERSION_INFO" >> /.VERSION_INFO; fi; \
	true "Cleanup"; \
	rm -f /var/cache/apk/*


# Nginx
COPY etc/nginx/nginx.conf /etc/nginx/nginx.conf
COPY etc/supervisor/conf.d/nginx.conf /etc/supervisor/conf.d/nginx.conf
COPY init.d/50-nginx.sh /docker-entrypoint-init.d/50-nginx.sh
COPY pre-init-tests.d/50-nginx.sh /docker-entrypoint-pre-init-tests.d/50-nginx.sh
RUN set -eux; \
		chown root:root \
			/etc/nginx/nginx.conf \
			/etc/nginx/conf.d \
			/etc/supervisor/conf.d/nginx.conf \
			/docker-entrypoint-init.d/50-nginx.sh \
			/docker-entrypoint-pre-init-tests.d/50-nginx.sh; \
		chmod 0644 \
			/etc/nginx/nginx.conf \
			/etc/supervisor/conf.d/nginx.conf; \
		chmod 0755 \
			/etc/nginx/conf.d \
			/docker-entrypoint-init.d/50-nginx.sh \
			/docker-entrypoint-pre-init-tests.d/50-nginx.sh
EXPOSE 80

# PHP-FPM
COPY ioncube/ioncube_loader_alpine_${PHP_VERSION}_${IONCUBE_VERSION}.so /usr/lib/php7/modules/
COPY etc/php7/conf.d/50-docker.ini /etc/php7/conf.d/50-docker.ini
COPY etc/php7/php-fpm.d/www.conf /etc/php7/php-fpm.d/www.conf
COPY etc/supervisor/conf.d/php-fpm.conf /etc/supervisor/conf.d/php-fpm.conf
COPY init.d/50-php.sh /docker-entrypoint-init.d/50-php.sh
COPY pre-init-tests.d/50-php-fpm.sh /docker-entrypoint-pre-init-tests.d/50-php-fpm.sh
COPY tests.d/50-php-fpm.sh /docker-entrypoint-tests.d/50-php-fpm.sh
COPY tests.d/52-php-fpm-with-ioncube.sh /docker-entrypoint-tests.d/52-php-fpm-with-ioncube.sh
RUN set -eux; \
		chown root:root \
			"/usr/lib/php7/modules/ioncube_loader_alpine_${PHP_VERSION}_${IONCUBE_VERSION}.so" \
			/etc/php7/conf.d/50-docker.ini \
			/etc/php7/php-fpm.d/www.conf \
			/etc/supervisor/conf.d/php-fpm.conf \
			/docker-entrypoint-init.d/50-php.sh \
			/docker-entrypoint-pre-init-tests.d/50-php-fpm.sh \
			/docker-entrypoint-tests.d/50-php-fpm.sh; \
		chmod 0644 \
			/etc/php7/conf.d/50-docker.ini \
			/etc/php7/php-fpm.d/www.conf \
			/etc/supervisor/conf.d/php-fpm.conf; \
		chmod 0755 \
			"/usr/lib/php7/modules/ioncube_loader_alpine_${PHP_VERSION}_${IONCUBE_VERSION}.so" \
			/docker-entrypoint-init.d/50-php.sh \
			/docker-entrypoint-pre-init-tests.d/50-php-fpm.sh \
			/docker-entrypoint-tests.d/50-php-fpm.sh

# Health check
HEALTHCHECK CMD curl --fail http://localhost:80 || exit 1

