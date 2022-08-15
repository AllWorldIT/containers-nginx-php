FROM registry.gitlab.iitsp.com/allworldit/docker/postfix:latest

ARG VERSION_INFO=
LABEL maintainer="Nigel Kukard <nkukard@LBSD.net>"

ENV PHP_NAME=php81
ENV PHP_VERSION=8.1

RUN set -ex; \
	true "Nginx"; \
	apk add --no-cache nginx; \
	ln -sf /dev/stdout /var/log/nginx/access.log; \
	ln -sf /dev/stderr /var/log/nginx/error.log; \
	true "PHP-FPM"; \
	apk add --no-cache $PHP_NAME \
		$PHP_NAME-bcmath \
		$PHP_NAME-ctype \
		$PHP_NAME-curl \
		$PHP_NAME-dom \
		$PHP_NAME-exif \
		$PHP_NAME-fileinfo \
		$PHP_NAME-fpm \
		$PHP_NAME-gd \
		$PHP_NAME-gettext \
		$PHP_NAME-iconv \
		$PHP_NAME-imap \
		$PHP_NAME-intl \
		$PHP_NAME-json \
		$PHP_NAME-ldap \
		$PHP_NAME-mbstring \
		$PHP_NAME-pecl-mcrypt \
		$PHP_NAME-opcache \
		$PHP_NAME-openssl \
		$PHP_NAME-pecl-imagick \
		$PHP_NAME-phar \
		$PHP_NAME-posix \
		$PHP_NAME-session \
		$PHP_NAME-simplexml \
		$PHP_NAME-soap \
		$PHP_NAME-sockets \
		$PHP_NAME-sodium \
		$PHP_NAME-xml \
		$PHP_NAME-xmlreader \
		$PHP_NAME-xmlwriter \
		$PHP_NAME-zip \
		graphviz ttf-droid ttf-liberation ttf-dejavu ttf-opensans \
		curl \
		; \
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
COPY etc/$PHP_NAME/conf.d/50-docker.ini /etc/$PHP_NAME/conf.d/50-docker.ini
COPY etc/$PHP_NAME/php-fpm.d/www.conf /etc/$PHP_NAME/php-fpm.d/www.conf
COPY etc/supervisor/conf.d/php-fpm.conf /etc/supervisor/conf.d/php-fpm.conf
COPY init.d/50-php.sh /docker-entrypoint-init.d/50-php.sh
COPY pre-init-tests.d/50-php-fpm.sh /docker-entrypoint-pre-init-tests.d/50-php-fpm.sh
COPY tests.d/50-php-fpm.sh /docker-entrypoint-tests.d/50-php-fpm.sh
RUN set -eux; \
		chown root:root \
			/etc/$PHP_NAME/conf.d/50-docker.ini \
			/etc/$PHP_NAME/php-fpm.d/www.conf \
			/etc/supervisor/conf.d/php-fpm.conf \
			/docker-entrypoint-init.d/50-php.sh \
			/docker-entrypoint-pre-init-tests.d/50-php-fpm.sh \
			/docker-entrypoint-tests.d/50-php-fpm.sh; \
		chmod 0644 \
			/etc/$PHP_NAME/conf.d/50-docker.ini \
			/etc/$PHP_NAME/php-fpm.d/www.conf \
			/etc/supervisor/conf.d/php-fpm.conf; \
		chmod 0755 \
			/docker-entrypoint-init.d/50-php.sh \
			/docker-entrypoint-pre-init-tests.d/50-php-fpm.sh \
			/docker-entrypoint-tests.d/50-php-fpm.sh

# Health check
HEALTHCHECK CMD curl --fail http://localhost:80 || exit 1

