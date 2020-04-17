#!/bin/bash


find /etc/nginx/conf.d

cat /etc/nginx/conf.d/default.conf

cat <<EOF > /etc/nginx/conf.d/default.conf
server {
	listen 80;
	server_name localhost;

	root /var/www/html;
	index index.php;

	location ~ [^/]\.php(/|$) {
		# Mitigation against vulnerabilities in PHP-FPM, just incase
		fastcgi_split_path_info ^(.+?\.php)(/.*)$;

		# Make sure document exists
		if (!-f \$document_root\$fastcgi_script_name) {
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
		fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;

		# Dokuwiki config
		fastcgi_param REDIRECT_STATUS 200;
	}
}
EOF

