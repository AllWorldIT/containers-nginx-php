FROM registry.gitlab.iitsp.com/allworldit/docker/nginx:latest

ARG VERSION_INFO=
LABEL maintainer="Nigel Kukard <nkukard@LBSD.net>"

ENV PHP_NAME=php81
ENV PHP_VERSION=8.1

RUN set -ex; \
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
		; \
	true "Versioning"; \
	if [ -n "$VERSION_INFO" ]; then echo "$VERSION_INFO" >> /.VERSION_INFO; fi; \
	true "Cleanup"; \
	rm -f /var/cache/apk/*


# NGINX
# Replace Nginx init for our tests
COPY pre-init-tests.d/50-nginx.sh /docker-entrypoint-pre-init-tests.d/50-nginx.sh
RUN set -eux; \
		chown root:root \
			/docker-entrypoint-pre-init-tests.d/50-nginx.sh; \
		chmod 0755 \
			/docker-entrypoint-pre-init-tests.d/50-nginx.sh

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

