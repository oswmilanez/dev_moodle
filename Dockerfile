#OS
FROM amazonlinux:2023

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
RUN dnf -y update && dnf -y upgrade

# Install Basic
RUN dnf install -y vim htop wget gcc pcre-devel gcc make git zip unzip

# Install Nginx Server
RUN dnf install -y nginx
RUN echo "NETWORKING=yes" > /etc/sysconfig/network

# Install PHP 
RUN dnf install -y \
     php \
     php-common \
     #php-jsonc \
     php-cli \
     php-fpm \
     php-gd \
     php-intl \
     php-mbstring \
     php-mysqlnd \
     php-pgsql \
     php-opcache \
     php-pdo \
     #php-pecl-igbinary \
     #php-pecl-imagick \
     php-process \
     php-soap \
     php-xml \
     #php-xmlrpc \
     #php-mcrypt \ 
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
RUN dnf clean all

#Configure Nginx
RUN mkdir -p /etc/pki/nginx/private
COPY ./cert/nginx-selfsigned.crt /etc/pki/nginx/nginx-selfsigned.crt
COPY ./cert/nginx-selfsigned.key /etc/pki/nginx/private/nginx-selfsigned.key
COPY ./nginx.conf /etc/nginx/nginx.conf


#Configure PHP
RUN sed -i 's/display_errors\ =\ Off/display_errors\ =\ On/g' /etc/php.ini
RUN sed -i 's/;error_log\ =\ syslog/error_log\ =\ \/dev\/stdout/g' /etc/php.ini
RUN sed -i 's/memory_limit\ =\ 128M/memory_limit\ =\ 1024M/g' /etc/php.ini
RUN sed -i 's/max_execution_time\ =\ 30/max_execution_time\ =\ 300/g' /etc/php.ini
RUN sed -i 's/max_input_time\ =\ 60/max_execution_time\ =\ 600/g' /etc/php.ini
RUN sed -i 's/upload_max_filesize\ =\ 2/upload_max_filesize\ =\ 1000/g' /etc/php.ini
RUN sed -i 's/post_max_size\ =\ 8/post_max_size\ =\ 1000/g' /etc/php.ini
RUN sed -i 's/;max_input_vars\ =\ 1000/max_input_vars\ =\ 5000/g' /etc/php.ini

# Start Container
COPY docker-entrypoint.sh /root/docker-entrypoint.sh
RUN chmod +x /root/docker-entrypoint.sh 

ENTRYPOINT ["./root/docker-entrypoint.sh"]
