[![pipeline status](https://gitlab.conarx.tech/containers/nginx-php/badges/main/pipeline.svg)](https://gitlab.conarx.tech/containers/nginx-php/-/commits/main)

# Container Information

[Container Source](https://gitlab.conarx.tech/containers/nginx-php) - [GitHub Mirror](https://github.com/AllWorldIT/containers-nginx-php)

This is the Conarx Containers Nginx PHP image, it provides the Nginx webserver bundled with PHP and most of the common PHP
modules, it is commonly used to host various PHP apps.

The following PHP modules are included:

* bcmath
* brotli
* ctype
* curl
* dom
* exif
* fileinfo
* fpm
* gd
* gettext
* gmp
* iconv
* imap
* intl
* json
* ldap
* mbstring
* opcache
* openssl
* pcntl
* pdo_mysql
* pdo_pgsql
* pecl-imagick
* pecl-mailparse
* pecl-maxminddb
* pecl-memcache
* pecl-memcached
* pecl-mongodb
* pecl-redis
* pecl-uploadprogress
* pecl-uuid
* pecl-zstd
* phar
* posix
* session
* simplexml
* soap
* sockets
* sodium
* sqlite3
* xml
* xmlreader
* xmlwriter
* xsl
* zip



# Mirrors

|  Provider  |  Repository                               |
|------------|-------------------------------------------|
| DockerHub  | allworldit/nginx-php                      |
| Conarx     | registry.conarx.tech/containers/nginx-php |



# Conarx Containers

All our Docker images are part of our Conarx Containers product line. Images are generally based on Alpine Linux and track the
Alpine Linux major and minor version in the format of `vXX.YY`.

Images built from source track both the Alpine Linux major and minor versions in addition to the main software component being
built in the format of `vXX.YY-AA.BB`, where `AA.BB` is the main software component version.

Our images are built using our Flexible Docker Containers framework which includes the below features...

- Flexible container initialization and startup
- Integrated unit testing
- Advanced multi-service health checks
- Native IPv6 support for all containers
- Debugging options



# Community Support

Please use the project [Issue Tracker](https://gitlab.conarx.tech/containers/nginx-php/-/issues).



# Commercial Support

Commercial support for all our Docker images is available from [Conarx](https://conarx.tech).

We also provide consulting services to create and maintain Docker images to meet your exact needs.



# Environment Variables

Additional environment variables are available from...
* [Conarx Containers Nginx image](https://gitlab.conarx.tech/containers/nginx)
* [Conarx Containers Postfix image](https://gitlab.conarx.tech/containers/postfix)
* [Conarx Containers Alpine image](https://gitlab.conarx.tech/containers/alpine)


## PHP_MEMORY_LIMIT

Maximum amount of memory usable by PHP, must be greater than `PHP_MAX_UPLOAD_SIZE`. Defaults to `128M`.


## PHP_MAX_UPLOAD_SIZE

Maximum client upload size. Defaults to `64M`.


## PHP_TIMEZONE

PHP timezone. Defaults to `UTC`.


## PHP_FPM_MAX_CHILDREN

Maximum number of php-fpm children. Defaults to `5`.


## PHP_FPM_START_SERVERS

Number of php-fpm servers to start. Defaults to `2`.



# Volumes


## /var/www/html

Document root.



# Exposed Ports

Postfix port 25 is exposed by the [Conarx Containers Postfix image](https://gitlab.conarx.tech/containers/postfix) layer.

Nginx port 80 is exposed by the [Conarx Containers Nginx image](https://gitlab.conarx.tech/containers/nginx) layer.



# Configuration

In addition to the configuration files included in the
[Conarx Containers Nginx image](https://gitlab.iitsp.com/allworldit/docker/nginx/README.md), the following additional files are
of interest...


| Path                                | Description                                |
|-------------------------------------|--------------------------------------------|
| /etc/php/conf.d/20_fdc_defaults.ini | Default PHP INI configuration              |
| /etc/php/conf.d/20_fdc_timezone.ini | Generated from the value in `PHP_TIMEZONE` |
| /etc/php/php-fpm.d/www.conf         | Configuration for php-fpm                  |



# Virtual Hosts for PHP

An example of the default vhost configuration for PHP can be found below...

```nginx
server {
	listen [::]:80 ipv6only=off;
	server_name localhost;

	root /var/www/html;
	index index.php;

	location = /favicon.ico {
		log_not_found off;
		access_log off;
	}

	location = /robots.txt {
		allow all;
		log_not_found off;
		access_log off;
	}

	location ~* \.(js|css|gif|ico|jpg|jpeg|png)$ {
		expires max;
	}

	location / {
		try_files $uri $uri/ /index.php?$args;
	}

	location ~ [^/]\.php(/|$) {
		# Mitigation against vulnerabilities in php-fpm, just incase
		fastcgi_split_path_info ^(.+?\.php)(/.*)$;

		# Make sure document exists
		if (!-f $document_root$fastcgi_script_name) {
			return 404;
		}

		# Mitigate https://httpoxy.org/ vulnerabilities
		fastcgi_param HTTP_PROXY "";

		# Pass request to php-fpm
		fastcgi_pass unix:/run/php-fpm.sock;
		fastcgi_index index.php;

		# Include fastcgi_params settings
		include fastcgi_params;

		# php-fpm requires the SCRIPT_FILENAME to be set
		fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;

		fastcgi_param REDIRECT_STATUS 200;
	}
}
```



# Health Checks

Health checks are done by the underlying
[Conarx Containers Nginx image](https://gitlab.iitsp.com/allworldit/docker/nginx/README.md).
