FROM php:5.6-apache

ENV MYSQL_ROOT_USER=""
ENV MYSQL_ROOT_PASSWORD=""
ENV MYSQL_HOST=""
ENV MYSQL_PORT=""
ENV YKKSM_READER_DB_PASSWORD=""
ENV YKKSM_IMPORTER_DB_PASSWORD=""

ENV TZ=Europe/Prague
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gpg \
    software-properties-common \
    mysql-client \
    libdbi-perl \
    libdbd-mysql-perl \
    libmcrypt-dev \
    mcrypt \
    ntp

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# pecl/mcrypt requires PHP (version >= 7.2.0, version <= 8.0.0, excluded versions: 8.0.0)
# RUN apt-get install -y libmcrypt-dev
# RUN pecl install mcrypt-1.0.3 && docker-php-ext-enable mcrypt

# Install extensions
RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-install mysqli && docker-php-ext-enable mysqli
RUN docker-php-ext-install mcrypt && docker-php-ext-enable mcrypt

# Enable RewriteEngine on
# RUN ln -s /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled/rewrite.load
RUN a2enmod rewrite
RUN ln -s /usr/local/bin/php /usr/bin/php

RUN mkdir /yubico
COPY ./yubico/yubikey-ksm /yubico/yubikey-ksm

# ykksm install
RUN cd /yubico/yubikey-ksm && /usr/bin/make install && /usr/bin/make symlink
# ykksm config files
# COPY conf/ykksm-config-db.php /etc/yubico/ksm/config-db.php
COPY conf/ykksm-config.php /etc/yubico/ksm/ykksm-config.php
# config used by perl scripts like ykksm-import
COPY conf/ykksm-import-config-db.cfg /etc/yubico/ksm/config-db.cfg

# apache config for web
COPY apache/.htaccess /var/www/wsapi/.htaccess

# apache host configs
COPY ./apache/ykksm.conf /etc/apache2/conf-enabled/ykksm.conf
COPY ./apache/security.conf /etc/apache2/conf-enabled/security.conf

# php configs
COPY ./php/php.ini /usr/local/etc/php/php.ini
COPY ./php/harden.ini /usr/local/etc/php/conf.d/harden.ini
RUN echo "date.timezone=$TZ" > /usr/local/etc/php/conf.d/timezone.ini

RUN chown -R www-data:www-data /var/www
RUN chmod -R 755 /var/www
RUN chmod -R 755 /usr/share/yubikey-ksm

COPY scripts/init_db.sh /root/init_db.sh

COPY ./gpg.conf /root/gpg.conf
COPY ./generate_gpg.sh /root/generate_gpg.sh
COPY ./generate_keys.sh /root/generate_keys.sh

