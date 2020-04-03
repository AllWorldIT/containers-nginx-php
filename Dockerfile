FROM alpine:3.11

ENV PHP_VERSION=7.3

RUN set -ex; \
	true "Supervisord"; \
	apk add --no-cache supervisor; \
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
		php7-fpm \
		php7-gd \
		php7-gettext \
		php7-iconv \
		php7-intl \
		php7-imap \
		php7-json \
		php7-mbstring \
		php7-mcrypt \
		php7-opcache \
		php7-openssl \
		php7-phar \
		php7-posix \
		php7-session \
		php7-sockets \
		php7-sodium \
		php7-xml \
		php7-zip \
		curl \
		; \
	true "php-fpm: ioncube"; \
	mkdir -p ioncube; cd ioncube; \
	curl --show-error --silent --location https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz --output ioncube.tar.gz; \
	tar -xf ioncube.tar.gz; \
	install -m 0755 -o root -g root "ioncube/ioncube_loader_lin_${PHP_VERSION}.so" /usr/lib/php7/modules/; \
	echo "zend_extension=/usr/lib/php7/modules/ioncube_loader_lin_${PHP_VERSION}.so" >  /etc/php7/conf.d/00_ioncube.ini; \
	cd ..; rm -rf ioncube; \
	true "Users"; \
	adduser -u 82 -D -S -H -h /var/www/html -G www-data www-data; \
	true "Web root"; \
	mkdir -p /var/www/html; \
	chown www-data:www-data /var/www/html; chmod 0755 /var/www/html; \
	true "Cleanup"; \
	rm -f /var/cache/apk/*; \
	true "Scriptlets"; \
	mkdir /docker-entrypoint-pre-exec.d; \
	mkdir /docker-entrypoint-pre-init.d; \
	chmod 750 /docker-entrypoint-pre-exec.d; \
	chmod 750 /docker-entrypoint-pre-init.d


# Supervisord
COPY config/supervisord.conf /etc/supervisor/supervisord.conf

# Crond
COPY config/supervisord.d/crond.conf /etc/supervisor/conf.d/crond.conf

# Nginx
COPY config/nginx.conf /etc/nginx/nginx.conf
COPY config/supervisord.d/nginx.conf /etc/supervisor/conf.d/nginx.conf

EXPOSE 80

# PHP-FPM
COPY config/php.ini /etc/php7/conf.d/50-setting.ini
COPY config/php-fpm.conf /etc/php7/php-fpm.d/www.conf
COPY config/supervisord.d/php-fpm.conf /etc/supervisor/conf.d/php-fpm.conf

# Entrypoint
COPY docker-entrypoint.sh /usr/local/sbin/
ENTRYPOINT ["docker-entrypoint.sh"]

