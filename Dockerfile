# Pull base image.
FROM amd64/alpine:3.13

# Author info
LABEL Author="Adriano Luís Rocha <driflash@gmail.com>"

# Install support packages
RUN \
  apk --no-cache add curl supervisor && \
  mkdir -p /var/log/supervisor

# Install Nginx.
RUN \
  apk --no-cache add nginx && \
  mkdir -p /var/www/localhost/htdocs/public && \
  mkdir -p /run/nginx/ && \
  sed -i "s/sendfile\s*on;/sendfile off;/" /etc/nginx/nginx.conf && \
  sed -i "s/user\s*nginx;/user root;/" /etc/nginx/nginx.conf

# Install php
RUN \
  apk --no-cache add gcc \
                     musl-dev \
                     make \
                     php7 \
                     php7-ctype \
                     php7-curl \
                     php7-dom \
                     php7-fileinfo \
                     php7-fpm \
                     php7-gd \
                     php7-iconv \
                     php7-intl \
                     php7-json \
                     php7-mbstring \
                     php7-mcrypt \
                     php7-pear \
                     php7-pdo \
                     php7-pdo_mysql \
                     php7-pdo_pgsql \
                     php7-pdo_sqlite \
                     php7-phar \
                     php7-pgsql \
                     php7-redis \
                     php7-simplexml \
                     php7-soap \
                     php7-sqlite3 \
                     php7-xdebug \
                     php7-xml \
                     php7-tokenizer \
                     php7-xmlreader \
                     php7-xmlwriter \
                     php7-zip \
                     php7-zlib && \
  sed -i "s/listen.owner\s*=\s*nobody/listen.owner = root/" /etc/php7/php-fpm.d/www.conf && \
  sed -i "s/listen.group\s*=\s*nobody/listen.group = root/" /etc/php7/php-fpm.d/www.conf && \
  sed -i "s/listen\s*=\s*127\.0\.0\.1\:9000/listen = \/run\/php7\.4\-fpm\.sock/" /etc/php7/php-fpm.d/www.conf && \
  sed -i "s/user\s*=\s*nobody/user = root/" /etc/php7/php-fpm.d/www.conf && \
  sed -i "s/group\s*=\s*nobody/group = root/" /etc/php7/php-fpm.d/www.conf && \
  sed -i "s/pid\s*=\s*\/run\/php\/php7\.1\-fpm\.pid/pid = \/run\/php7\.4\-fpm\.pid/" /etc/php7/php-fpm.conf && \
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

# Install MSSQL driver
RUN cd /tmp && \
  curl -O https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/msodbcsql17_17.7.2.1-1_amd64.apk && \
  curl -O https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/mssql-tools_17.7.1.1-1_amd64.apk && \
  apk add --allow-untrusted msodbcsql17_17.7.2.1-1_amd64.apk && \
  apk add --allow-untrusted mssql-tools_17.7.1.1-1_amd64.apk && \
  curl -L https://github.com/microsoft/msphpsql/releases/download/v5.9.0/Alpine312-7.4.tar | tar xv && \
  cp /tmp/Alpine312-7.4/php_pdo_sqlsrv_74_nts.so /usr/lib/php7/modules/pdo_sqlsrv.so && \
  cp /tmp/Alpine312-7.4/php_sqlsrv_74_nts.so /usr/lib/php7/modules/sqlsrv.so && \
  rm -r /tmp/* && \
  echo extension=pdo_sqlsrv.so > /etc/php7/conf.d/01_pdo_sqlsrv.ini && \
  echo extension=sqlsrv.so > /etc/php7/conf.d/00_sqlsrv.ini

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Define working directory.
WORKDIR /var/www/localhost/htdocs

ADD conf/supervisord.conf /etc/supervisord.conf

# Configure default site
ADD conf/nginx-site.conf /etc/nginx/conf.d/default.conf
RUN echo "<?php phpinfo() ?>" > /var/www/localhost/htdocs/public/index.php

# Configure Xdebug
RUN \
  sed -i "s/;zend_extension=xdebug.so/zend_extension=xdebug.so/" /etc/php7/conf.d/50_xdebug.ini && \
  sed -i "s/;xdebug.mode=off/xdebug.mode=debug/" /etc/php7/conf.d/50_xdebug.ini && \
  echo "xdebug.discover_client_host=true" >> /etc/php7/conf.d/50_xdebug.ini

# Expose ports.
EXPOSE 80

# Define default entry point
ENTRYPOINT /usr/bin/supervisord -n -c /etc/supervisord.conf
