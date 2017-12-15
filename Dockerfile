# Pull base image.
FROM alpine:3.7

# Author info
LABEL Author="Adriano Luís Rocha <driflash@gmail.com>"

# Install support packages
RUN \
  apk --no-cache add curl supervisor && \
  mkdir -p /var/log/supervisor

# Install Nginx.
RUN \
  apk --no-cache add nginx && \
  mkdir -p /var/www/html/public && \
  mkdir -p /run/nginx/ && \
  sed -i "s/sendfile\s*on;/sendfile off;/" /etc/nginx/nginx.conf && \
  sed -i "s/user\s*nginx;/user root;/" /etc/nginx/nginx.conf

# Install php
RUN \
  apk --no-cache add php7 \
                     php7-ctype \
                     php7-curl \
                     php7-dom \
                     php7-fileinfo \
                     php7-fpm \
                     php7-gd \
                     php7-intl \
                     php7-json \
                     php7-mbstring \
                     php7-mcrypt \
                     php7-pdo \
                     php7-pdo_mysql \
                     php7-pdo_pgsql \
                     php7-pdo_sqlite \
                     php7-phar \
                     php7-pgsql \
                     php7-redis \
                     php7-soap \
                     php7-sqlite3 \
                     php7-xdebug \
                     php7-xml \
                     php7-tokenizer \
                     php7-xmlwriter \
                     php7-zlib && \
  sed -i "s/listen.owner\s*=\s*nobody/listen.owner = root/" /etc/php7/php-fpm.d/www.conf && \
  sed -i "s/listen.group\s*=\s*nobody/listen.group = root/" /etc/php7/php-fpm.d/www.conf && \
  sed -i "s/listen\s*=\s*127\.0\.0\.1\:9000/listen = \/var\/run\/php7\.1\-fpm\.sock/" /etc/php7/php-fpm.d/www.conf && \
  sed -i "s/user\s*=\s*nobody/user = root/" /etc/php7/php-fpm.d/www.conf && \
  sed -i "s/group\s*=\s*nobody/group = root/" /etc/php7/php-fpm.d/www.conf && \
  sed -i "s/pid\s*=\s*\/run\/php\/php7\.1\-fpm\.pid/pid = \/var\/run\/php7\.1\-fpm\.pid/" /etc/php7/php-fpm.conf && \
  sed -i "s/;daemonize\s*=\s*yes/daemonize = no/" /etc/php7/php-fpm.conf && \
  sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo = 0/" /etc/php7/php.ini && \
  sed -i "s/memory_limit\s*=\s*128M/memory_limit = 256M/" /etc/php7/php.ini && \
  sed -i "s/max_execution_time\s*=\s*30/max_execution_time = 300/" /etc/php7/php.ini && \
  sed -i "s/;request_terminate_timeout\s*=\s*0/request_terminate_timeout = 300/" /etc/php7/php.ini && \
  sed -i "s/error_reporting\s*=\s*E_ALL\s*&\s*~E_DEPRECATED\s*&\s*~E_STRICT/error_reporting = E_ALL/" /etc/php7/php.ini && \
  sed -i "s/display_errors\s*=\s*Off/display_errors = On/" /etc/php7/php.ini && \
  sed -i "s/display_startup_errors\s*=\s*Off/display_startup_errors = On/" /etc/php7/php.ini && \
  sed -i "s/track_errors\s*=\s*Off/track_errors = On/" /etc/php7/php.ini && \
  sed -i "s/session.gc_probability\s*=\s*0/session.gc_probability = 1/" /etc/php7/php.ini

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Define working directory.
WORKDIR /var/www/html

ADD conf/supervisord.conf /etc/supervisord.conf

# Configure default site
ADD conf/nginx-site.conf /etc/nginx/conf.d/default.conf
RUN echo "<?php phpinfo() ?>" > /var/www/html/public/index.php

# Configure Xdebug
RUN sed -i "s/;zend_extension=xdebug.so/zend_extension=xdebug.so/" /etc/php7/conf.d/xdebug.ini
RUN echo "xdebug.remote_enable=on" >> /etc/php7/conf.d/xdebug.ini
RUN echo "xdebug.remote_connect_back=on" >> /etc/php7/conf.d/xdebug.ini

# Expose ports.
EXPOSE 80

# Define default entry point
ENTRYPOINT /usr/bin/supervisord -n -c /etc/supervisord.conf
