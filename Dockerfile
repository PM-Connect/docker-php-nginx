FROM php:7.2-fpm-alpine

RUN apk update && apk --no-cache add nginx bash libmcrypt-dev && rm -rf /usr/local/etc/php-fpm.d/* && docker-php-ext-install opcache

COPY ./nginx.conf /etc/nginx/
COPY ./site.conf  /etc/nginx/sites-available/
COPY ./php.ini    /usr/local/etc/php/php.ini
COPY ./www.conf   /usr/local/etc/php-fpm.d/www.conf

RUN mkdir -p /var/run/php && \
    mkdir -p /etc/nginx/sites-enabled && \
    mkdir -p /etc/nginx/sites-available && \
    mkdir -p /var/app && \
    chown -R www-data:www-data /var/app && \
    ln -s /etc/nginx/sites-available/site.conf /etc/nginx/sites-enabled/site && \
    mkdir /etc/php && \
    mkdir /etc/php/7.2 && \
    mkdir /etc/php/7.2/fpm && \
    mkdir /etc/php/7.2/fpm/env.d && \
    touch /etc/php/7.2/fpm/env.d/docker

COPY ./startup.php /var/app/public/index.php

COPY ./entrypoint.sh /entrypoint.sh

RUN chown root ./entrypoint.sh && chown -R www-data:www-data /var/app/public/index.php && chmod +x /entrypoint.sh

WORKDIR /var/app

ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 80
EXPOSE 443