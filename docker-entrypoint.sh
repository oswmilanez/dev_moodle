#!/bin/bash

#Mongo
mongod &
mongo < /root/xhprof_indexes.js

#php
/usr/sbin/php-fpm

#nginx
/usr/sbin/nginx -g 'daemon off;'
