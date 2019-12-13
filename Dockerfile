#OS
FROM amazonlinux:2

# Owner
LABEL key="Oswaldo Milanez Neto <oswaldo@milanez.net>"

# TIMEZONE
RUN echo "ZONE=\"Europe/London\"" | tee --append "/etc/sysconfig/clock"
RUN ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime

# Volume
VOLUME /var/www

# Expose Ports
EXPOSE 80 443

# /root/.bashrc
RUN echo "alias ll='ls -alh --color'" | tee --append "/root/.bashrc";

# Update and Upgrade
RUN yum -y update && yum -y upgrade

# Install Basic
RUN yum install -y curl vim htop wget gcc pcre-devel gcc make iptraf-ng git zip unzip

#mongodb
RUN printf '[mongodb-org-4.2] \n\
name=MongoDB Repository \n\
baseurl=https://repo.mongodb.org/yum/amazon/2/mongodb-org/4.2/x86_64/ \n\
gpgcheck=1 \n\
enabled=1 \n\
gpgkey=https://www.mongodb.org/static/pgp/server-4.2.asc' >> /etc/yum.repos.d/mongodb-org-4.2.repo
RUN yum install -y mongodb-org
RUN mkdir -p /data/db

# Install Nginx Server
RUN amazon-linux-extras enable nginx1
RUN yum install -y nginx
RUN echo "NETWORKING=yes" > /etc/sysconfig/network

# Install PHP 7.1
RUN amazon-linux-extras enable php7.1
RUN yum install -y \
     php \
     php-common \
     php-jsonc \
     php-cli \
     php-fpm \
     php-gd \
     php-intl \
     php-mbstring \
     php-mysqlnd \
     php-opcache \
     php-pdo \
     php-pecl-igbinary \
     php-pecl-imagick \
     php-process \
     php-soap \
     php-xml \
     php-xmlrpc \
     php-mcrypt \ 
     php-zip \ 
     php-ldap \
     php-devel \
     php-pear
RUN pecl install mongodb
RUN echo 'extension=mongodb.so' >  /etc/php.d/41-mongodb.ini

#composer
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer
RUN ln -s /usr/local/bin/composer /usr/bin/composer

# Clean Install
RUN yum clean all

#Configure Nginx
RUN mkdir -p /etc/pki/nginx/private
COPY ./cert/nginx-selfsigned.crt /etc/pki/nginx/nginx-selfsigned.crt
COPY ./cert/nginx-selfsigned.key /etc/pki/nginx/private/nginx-selfsigned.key
COPY ./nginx.conf /etc/nginx/nginx.conf

#xhprof
COPY ./php-xhprof-extension /root/php-xhprof-extension
RUN cd /root/php-xhprof-extension && phpize && ./configure && make && make install
RUN echo 'extension=tideways_xhprof.so' >  /etc/php.d/41-tideways_xhprof.ini
COPY ./xhgui /var/xhgui
COPY ./xhprof_indexes.js /root/xhprof_indexes.js
RUN chmod -R 777 /var/xhgui
RUN cd /var/xhgui/ && composer install && php install.php

#Configure PHP
RUN sed -i 's/display_errors\ =\ Off/display_errors\ =\ On/g' /etc/php.ini
RUN sed -i 's/;error_log\ =\ syslog/error_log\ =\ \/dev\/stdout/g' /etc/php.ini
RUN sed -i 's/memory_limit\ =\ 128M/memory_limit\ =\ 1024M/g' /etc/php.ini
RUN sed -i 's/max_execution_time\ =\ 30/max_execution_time\ =\ 300/g' /etc/php.ini
RUN sed -i 's/max_input_time\ =\ 60/max_execution_time\ =\ 600/g' /etc/php.ini
RUN sed -i 's/auto_prepend_file\ =\/auto_prepend_file\ =\ \/var\/xhgui\/external\/header.php/g' /etc/php.ini

# Start Container
COPY docker-entrypoint.sh /root/docker-entrypoint.sh
RUN chmod +x /root/docker-entrypoint.sh 
ENTRYPOINT ["./root/docker-entrypoint.sh"]
