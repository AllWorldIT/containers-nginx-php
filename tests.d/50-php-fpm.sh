#!/bin/bash

if ! php --version |  grep "PHP $PHP_VERSION"; then
	echo "CHECK FAILED (php): PHP version does not match PHP_VERSION"
	echo "= = = OUTPUT = = ="
	php --version
	echo "= = = OUTPUT = = ="
	false
fi

