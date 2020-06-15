#!/bin/bash

mv /etc/php7/conf.d/00_ioncube.ini{.disabled,}

if ! php --version |  grep "PHP $PHP_VERSION"; then
	echo "CHECK FAILED (php): PHP version does not match PHP_VERSION"
	echo "= = = OUTPUT = = ="
	php --version
	echo "= = = OUTPUT = = ="
	false
fi


if ! curl --verbose --header 'Host: localhost' 'http://127.0.0.1/' --output test.out; then
	echo "CHECK FAILED (nginx): Failed to get test php output"
	echo "= = = OUTPUT = = ="
	cat test.out
	echo "= = = OUTPUT = = ="
	false
fi

echo "TEST SUCCESS" > test.out.correct
if ! diff test.out test.out.correct; then
	echo "CHECK FAILED (nginx): Contents of output from php does not match what it should be"
	echo "= = = test.out = = ="
	cat test.out
	echo "= = = test.out = = ="
	echo "= = = test.out.correct = = ="
	cat test.out.correct
	echo "= = = test.out.correect = = ="
	false
fi

