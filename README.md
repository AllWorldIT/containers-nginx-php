# Introduction

This is a LEP (Linux Nginx PHP) container for hosting various types of PHP sites.

Check the [Alpine Base Image](https://gitlab.iitsp.com/allworldit/docker/alpine/README.md) for more settings.

This image has a health check which checks `http://localhost` for a response.


# Environment

## ENABLE_IONCUBE

If set to "yes", this will enable ionCube support.


# Configuration

## Nginx

The default document root is `/var/www/html`.

By default nginx is configured to answer with 404 in `/etc/nginx/conf.d/default.conf`. PHP is not enabled by default.

If you want to set a domain and have the default 404 for domains not configured then bind mount to
`/etc/nginx/conf.d/NAME.conf`.

Alternatively you can bind mount over `/etc/nginx/conf.d/default.conf`.

An example of a basic PHP configuration can be found below...
```
server {
	listen 80;
	server_name localhost;

	root /var/www/html;
	index index.php;

	location ~ [^/]\.php(/|$) {
		# Mitigation against vulnerabilities in PHP-FPM, just incase
		fastcgi_split_path_info ^(.+?\.php)(/.*)$;

		# Make sure document exists
		if (!-f $document_root$fastcgi_script_name) {
			return 404;
		}

		# Mitigate https://httpoxy.org/ vulnerabilities
		fastcgi_param HTTP_PROXY "";

		# Pass request to PHP-FPM
		fastcgi_pass unix:/run/php-fpm.sock;
		fastcgi_index index.php;

		# Include fastcgi_params settings
		include fastcgi_params;

		# PHP-FPM requires the SCRIPT_FILENAME to be set
		fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;

		# Dokuwiki config
		fastcgi_param REDIRECT_STATUS 200;
	}
}
```

## PHP

The docker containr PHP settings are added as `/etc/php7/conf.d/50-docker.ini`.

To specify custom settings you can bind mount with a higher priority number than 50 in the same directory.

