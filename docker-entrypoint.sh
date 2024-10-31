#!/bin/bash

#php
mkdir /run/php-fpm/
touch /run/php-fpm/www.sock
/usr/sbin/php-fpm

#nginx
/usr/sbin/nginx -g 'daemon off;'
