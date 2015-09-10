# Pull base image.
FROM library/ubuntu

# Author info
MAINTAINER Adriano Luís Rocha <adriano.rocha@solutudo.com.br>

# Install software-properties-common to access add-apt-repository and curl
RUN \
  apt-get install -y --force-yes software-properties-common \
                                 wget

# Install Nginx.
RUN \
  add-apt-repository -y ppa:nginx/stable && \
  apt-get update && \
  apt-get install -y nginx && \
  echo "\ndaemon off;" >> /etc/nginx/nginx.conf && \
  mkdir -p /var/www/html/app/webroot && \
  chown -R www-data:www-data /var/www

# Install php
RUN \
  add-apt-repository -y ppa:ondrej/php5-5.6 && \
  apt-get update && \
  apt-get install -y --force-yes php5-gd \
                                 php5-cli \
                                 php5-fpm \
                                 php5-curl \
                                 php5-intl \
                                 php5-geoip \
                                 php5-mysql \
                                 php5-pgsql \
                                 php5-mcrypt \
                                 php5-sqlite \
                                 php5-xdebug && \
  sed -i "s/;daemonize\s*=\s*yes/daemonize = no/" /etc/php5/fpm/php-fpm.conf && \
  sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo = 0/" /etc/php5/fpm/php.ini && \
  sed -i "s/memory_limit\s*=\s*128M/memory_limit = 256M/" /etc/php5/fpm/php.ini && \
  sed -i "s/max_execution_time\s*=\s*30/max_execution_time = 300/" /etc/php5/fpm/php.ini && \
  sed -i "s/;request_terminate_timeout\s*=\s*0/request_terminate_timeout = 300/" /etc/php5/fpm/php.ini && \
  sed -i "s/error_reporting\s*=\s*E_ALL\s*&\s*~E_DEPRECATED\s*&\s*~E_STRICT/error_reporting = E_ALL/" /etc/php5/fpm/php.ini && \
  sed -i "s/display_errors\s*=\s*Off/display_errors = On/" /etc/php5/fpm/php.ini && \
  sed -i "s/display_startup_errors\s*=\s*Off/display_startup_errors = On/" /etc/php5/fpm/php.ini && \
  sed -i "s/track_errors\s*=\s*Off/track_errors = On/" /etc/php5/fpm/php.ini && \
  sed -i "s/session.gc_probability\s*=\s*0/session.gc_probability = 1/" /etc/php5/fpm/php.ini

# Install GeoIP Cities light
RUN mkdir -pv /usr/share/GeoIP && \
  wget -O - http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz | gunzip -c > /usr/share/GeoIP/GeoIPCity.dat

# Define working directory.
WORKDIR /var/www/html

# Configure default site
ADD conf/nginx/default /etc/nginx/sites-available/default
RUN mkdir -p /var/www/html/public && \
    echo "<?php phpinfo() ?>" > /var/www/html/public/index.php

# Configure Xdebug
RUN echo "xdebug.remote_enable=on" >> /etc/php5/mods-available/xdebug.ini
RUN echo "xdebug.remote_connect_back=on" >> /etc/php5/mods-available/xdebug.ini

# Expose ports.
EXPOSE 80 9000

# Clean temp and cache
RUN \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Define default command.
CMD service php5-fpm start && nginx
