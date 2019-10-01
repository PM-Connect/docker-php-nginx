FROM php:7.2-fpm-alpine

ENV PHPREDIS_VERSION 5.0.2
RUN apk update && \
    apk --no-cache add shadow nginx bash libmcrypt-dev icu-dev && \
    rm -rf /usr/local/etc/php-fpm.d/* && \
    rm -rf /etc/nginx/conf.d && \
    curl -L -o /tmp/redis.tar.gz https://github.com/phpredis/phpredis/archive/$PHPREDIS_VERSION.tar.gz && \
    tar xfz /tmp/redis.tar.gz && \
    rm -r /tmp/redis.tar.gz && \
    mv phpredis-$PHPREDIS_VERSION /usr/src/php/ext/redis && \
    docker-php-ext-install opcache intl redis

COPY ./nginx.conf /etc/nginx/
COPY ./site.conf  /etc/nginx/sites-available/
COPY ./php.ini    /usr/local/etc/php/php.ini
COPY ./www.conf   /usr/local/etc/php-fpm.d/www.conf

RUN mkdir -p /var/run/php && \
    mkdir -p /etc/nginx/sites-enabled && \
    mkdir -p /etc/nginx/sites-available && \
    mkdir -p /var/app && \
    mkdir -p /var/tmp/nginx && \
    chown -R www-data:www-data /var/app && \
    chown -R www-data:www-data /var/tmp/nginx && \
    ln -s /etc/nginx/sites-available/site.conf /etc/nginx/sites-enabled/site && \
    mkdir -p /etc/php/7.2/fpm/env.d && \
    touch /etc/php/7.2/fpm/env.d/docker

COPY ./startup.php /var/app/public/index.php

COPY ./entrypoint.sh /entrypoint.sh

RUN chown root /entrypoint.sh && chown -R www-data:www-data /var/app/public/index.php && chmod +x /entrypoint.sh

WORKDIR /var/app

ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 80
EXPOSE 443
