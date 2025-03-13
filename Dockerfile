# Pull base image.
FROM alpine:3.21

# Author info
LABEL Author="Adriano Luís Rocha <driflash@gmail.com>"

# Install support packages
RUN apk --no-cache add curl supervisor && \
  mkdir -p /var/log/supervisor

# Install Nginx.
RUN apk --no-cache add nginx && \
  mkdir -p /var/www/localhost/htdocs/public && \
  mkdir -p /run/nginx/ && \
  sed -i "s/sendfile\s*on;/sendfile off;/" /etc/nginx/nginx.conf && \
  sed -i "s/user\s*nginx;/user root;/" /etc/nginx/nginx.conf

# Install php
RUN apk --no-cache add php84 \
  php84-ctype \
  php84-curl \
  php84-dom \
  php84-fileinfo \
  php84-fpm \
  php84-gd \
  php84-iconv \
  php84-intl \
  php84-json \
  php84-json \
  php84-mysqli \
  php84-pear \
  php84-pecl-redis \
  php84-pecl-xdebug \
  php84-pdo \
  php84-pdo_mysql \
  php84-pdo_pgsql \
  php84-pdo_sqlite \
  php84-phar \
  php84-pgsql \
  php84-simplexml \
  php84-soap \
  php84-sqlite3 \
  php84-xml \
  php84-tokenizer \
  php84-xmlreader \
  php84-xmlwriter \
  php84-zip \
  php84-zlib && \
  sed -i "s/listen.owner\s*=\s*nobody/listen.owner = root/" /etc/php84/php-fpm.d/www.conf && \
  sed -i "s/listen.group\s*=\s*nobody/listen.group = root/" /etc/php84/php-fpm.d/www.conf && \
  sed -i "s/listen\s*=\s*127\.0\.0\.1\:9000/listen = \/run\/php\-fpm84\.sock/" /etc/php84/php-fpm.d/www.conf && \
  sed -i "s/user\s*=\s*nobody/user = root/" /etc/php84/php-fpm.d/www.conf && \
  sed -i "s/group\s*=\s*nobody/group = root/" /etc/php84/php-fpm.d/www.conf && \
  sed -i "s/;pid\s*=\s*run\/php\-fpm84\.pid/pid = \/run\/php\-fpm84\.pid/" /etc/php84/php-fpm.conf && \
  sed -i "s/;daemonize\s*=\s*yes/daemonize = no/" /etc/php84/php-fpm.conf && \
  sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo = 0/" /etc/php84/php.ini && \
  sed -i "s/memory_limit\s*=\s*128M/memory_limit = 256M/" /etc/php84/php.ini && \
  sed -i "s/max_execution_time\s*=\s*30/max_execution_time = 300/" /etc/php84/php.ini && \
  sed -i "s/;request_terminate_timeout\s*=\s*0/request_terminate_timeout = 300/" /etc/php84/php.ini && \
  sed -i "s/error_reporting\s*=\s*E_ALL\s*&\s*~E_DEPRECATED\s*&\s*~E_STRICT/error_reporting = E_ALL/" /etc/php84/php.ini && \
  sed -i "s/display_errors\s*=\s*Off/display_errors = On/" /etc/php84/php.ini && \
  sed -i "s/display_startup_errors\s*=\s*Off/display_startup_errors = On/" /etc/php84/php.ini && \
  sed -i "s/track_errors\s*=\s*Off/track_errors = On/" /etc/php84/php.ini && \
  sed -i "s/session.gc_probability\s*=\s*0/session.gc_probability = 1/" /etc/php84/php.ini && \
  # Backport php links
  cd /usr/sbin && ln -s php-fpm84 php-fpm && \
  cd /usr/bin && ln -s php84 php && ln -s pear84 pear && ln -s peardev84 peardev && ln -s pecl84 pecl && ln -s phar.phar84 phar

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Define working directory.
WORKDIR /var/www/localhost/htdocs

ADD conf/supervisord.conf /etc/supervisord.conf

# Configure default site
ADD conf/nginx-site.conf /etc/nginx/http.d/default.conf
RUN echo "<?php phpinfo() ?>" > /var/www/localhost/htdocs/public/index.php

# Configure Xdebug
RUN sed -i "s/;zend_extension=xdebug.so/zend_extension=xdebug.so/" /etc/php84/conf.d/50_xdebug.ini && \
  sed -i "s/;xdebug.mode=off/xdebug.mode=debug/" /etc/php84/conf.d/50_xdebug.ini && \
  echo "xdebug.discover_client_host=true" >> /etc/php84/conf.d/50_xdebug.ini

# Expose ports.
EXPOSE 80 9003

# Define default entry point
ENTRYPOINT /usr/bin/supervisord -n -c /etc/supervisord.conf
