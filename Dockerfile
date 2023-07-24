# Pull base image.
FROM alpine:3.18

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
RUN apk --no-cache add php82 \
  php82-ctype \
  php82-curl \
  php82-dom \
  php82-fileinfo \
  php82-fpm \
  php82-gd \
  php82-iconv \
  php82-intl \
  php82-json \
  php82-mbstring \
  php82-pear \
  php82-pecl-redis \
  php82-pecl-xdebug \
  php82-pdo \
  php82-pdo_mysql \
  php82-pdo_pgsql \
  php82-pdo_sqlite \
  php82-phar \
  php82-pgsql \
  php82-simplexml \
  php82-soap \
  php82-sqlite3 \
  php82-xml \
  php82-tokenizer \
  php82-xmlreader \
  php82-xmlwriter \
  php82-zip \
  php82-zlib && \
  sed -i "s/listen.owner\s*=\s*nobody/listen.owner = root/" /etc/php82/php-fpm.d/www.conf && \
  sed -i "s/listen.group\s*=\s*nobody/listen.group = root/" /etc/php82/php-fpm.d/www.conf && \
  sed -i "s/listen\s*=\s*127\.0\.0\.1\:9000/listen = \/run\/php\-fpm82\.sock/" /etc/php82/php-fpm.d/www.conf && \
  sed -i "s/user\s*=\s*nobody/user = root/" /etc/php82/php-fpm.d/www.conf && \
  sed -i "s/group\s*=\s*nobody/group = root/" /etc/php82/php-fpm.d/www.conf && \
  sed -i "s/;pid\s*=\s*run\/php\-fpm82\.pid/pid = \/run\/php\-fpm82\.pid/" /etc/php82/php-fpm.conf && \
  sed -i "s/;daemonize\s*=\s*yes/daemonize = no/" /etc/php82/php-fpm.conf && \
  sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo = 0/" /etc/php82/php.ini && \
  sed -i "s/memory_limit\s*=\s*128M/memory_limit = 256M/" /etc/php82/php.ini && \
  sed -i "s/max_execution_time\s*=\s*30/max_execution_time = 300/" /etc/php82/php.ini && \
  sed -i "s/;request_terminate_timeout\s*=\s*0/request_terminate_timeout = 300/" /etc/php82/php.ini && \
  sed -i "s/error_reporting\s*=\s*E_ALL\s*&\s*~E_DEPRECATED\s*&\s*~E_STRICT/error_reporting = E_ALL/" /etc/php82/php.ini && \
  sed -i "s/display_errors\s*=\s*Off/display_errors = On/" /etc/php82/php.ini && \
  sed -i "s/display_startup_errors\s*=\s*Off/display_startup_errors = On/" /etc/php82/php.ini && \
  sed -i "s/track_errors\s*=\s*Off/track_errors = On/" /etc/php82/php.ini && \
  sed -i "s/session.gc_probability\s*=\s*0/session.gc_probability = 1/" /etc/php82/php.ini && \
  # Backport php links
  cd /usr/sbin && ln -s php-fpm82 php-fpm && \
  cd /usr/bin && ln -s php82 php && ln -s pear82 pear && ln -s peardev82 peardev && ln -s pecl82 pecl && ln -s phar.phar82 phar

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Define working directory.
WORKDIR /var/www/localhost/htdocs

ADD conf/supervisord.conf /etc/supervisord.conf

# Configure default site
ADD conf/nginx-site.conf /etc/nginx/http.d/default.conf
RUN echo "<?php phpinfo() ?>" > /var/www/localhost/htdocs/public/index.php

# Configure Xdebug
RUN sed -i "s/;zend_extension=xdebug.so/zend_extension=xdebug.so/" /etc/php82/conf.d/50_xdebug.ini && \
  sed -i "s/;xdebug.mode=off/xdebug.mode=debug/" /etc/php82/conf.d/50_xdebug.ini && \
  echo "xdebug.discover_client_host=true" >> /etc/php82/conf.d/50_xdebug.ini

# Expose ports.
EXPOSE 80 9003

# Define default entry point
ENTRYPOINT /usr/bin/supervisord -n -c /etc/supervisord.conf
