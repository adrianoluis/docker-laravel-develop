# Pull base image.
FROM library/ubuntu:16.04

# Author info
MAINTAINER Adriano Luís Rocha <driflash@gmail.com>

# Install software-properties-common to access add-apt-repository and curl
RUN \
  apt-get update && \
  apt-get install -y software-properties-common \
<<<<<<< HEAD
                                 curl
=======
                     curl \
                     supervisor \
                     unzip
>>>>>>> 4ef99ae... Fix laravel dependencies for 5.3

# Install Nginx.
RUN \
  apt-get install -y nginx && \
  mkdir -p /var/www/html/public && \
  mkdir -p /var/log/supervisor && \
  sed -i "s/sendfile\s*on;/sendfile off;/" /etc/nginx/nginx.conf && \
  sed -i "s/user\s*www-data;/user root;/" /etc/nginx/nginx.conf

# Install php
RUN \
  apt-get install -y php-gd \
                     php-cli \
                     php-dom \
                     php-fpm \
                     php-curl \
                     php-intl \
                     php-geoip \
                     php-mysql \
                     php-pgsql \
                     php-mcrypt \
                     php-mbstring \
                     php-redis \
                     php-soap \
                     php-sqlite3 \
                     php-xdebug && \
  sed -i "s/listen.owner\s*=\s*www-data/listen.owner = root/" /etc/php/7.0/fpm/pool.d/www.conf && \
  sed -i "s/listen.group\s*=\s*www-data/listen.group = root/" /etc/php/7.0/fpm/pool.d/www.conf && \
  sed -i "s/listen\s*=\s*\/run\/php\/php7\.0\-fpm\.sock/listen = \/var\/run\/php7\.0\-fpm\.sock/" /etc/php/7.0/fpm/pool.d/www.conf && \
  sed -i "s/user\s*=\s*www-data/user = root/" /etc/php/7.0/fpm/pool.d/www.conf && \
  sed -i "s/group\s*=\s*www-data/group = root/" /etc/php/7.0/fpm/pool.d/www.conf && \
  sed -i "s/pid\s*=\s*\/run\/php\/php7\.0\-fpm\.pid/pid = \/var\/run\/php7\.0\-fpm\.pid/" /etc/php/7.0/fpm/php-fpm.conf && \
  sed -i "s/;daemonize\s*=\s*yes/daemonize = no/" /etc/php/7.0/fpm/php-fpm.conf && \
  sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo = 0/" /etc/php/7.0/fpm/php.ini && \
  sed -i "s/memory_limit\s*=\s*128M/memory_limit = 256M/" /etc/php/7.0/fpm/php.ini && \
  sed -i "s/max_execution_time\s*=\s*30/max_execution_time = 300/" /etc/php/7.0/fpm/php.ini && \
  sed -i "s/;request_terminate_timeout\s*=\s*0/request_terminate_timeout = 300/" /etc/php/7.0/fpm/php.ini && \
  sed -i "s/error_reporting\s*=\s*E_ALL\s*&\s*~E_DEPRECATED\s*&\s*~E_STRICT/error_reporting = E_ALL/" /etc/php/7.0/fpm/php.ini && \
  sed -i "s/display_errors\s*=\s*Off/display_errors = On/" /etc/php/7.0/fpm/php.ini && \
  sed -i "s/display_startup_errors\s*=\s*Off/display_startup_errors = On/" /etc/php/7.0/fpm/php.ini && \
  sed -i "s/track_errors\s*=\s*Off/track_errors = On/" /etc/php/7.0/fpm/php.ini && \
  sed -i "s/session.gc_probability\s*=\s*0/session.gc_probability = 1/" /etc/php/7.0/fpm/php.ini

# Install GeoIP Cities light
RUN mkdir -pv /usr/share/GeoIP && \
  curl http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz | gunzip -c > /usr/share/GeoIP/GeoIPCity.dat

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Define working directory.
WORKDIR /var/www/html

ADD conf/supervisord.conf /etc/supervisord.conf

# Configure default site
ADD conf/nginx-site.conf /etc/nginx/sites-available/default
RUN echo "<?php phpinfo() ?>" > /var/www/html/public/index.php

# Configure Xdebug
RUN echo "xdebug.remote_enable=on" >> /etc/php/7.0/mods-available/xdebug.ini
RUN echo "xdebug.remote_connect_back=on" >> /etc/php/7.0/mods-available/xdebug.ini

# Expose ports.
EXPOSE 80 9000

# Clean temp and cache
RUN \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Define default entry point
ENTRYPOINT /usr/bin/supervisord -n -c /etc/supervisord.conf
