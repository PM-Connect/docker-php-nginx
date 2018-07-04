FROM php:7.2-fpm-alpine

COPY ./nginx.conf /etc/nginx/
COPY ./site.conf.template /etc/nginx/conf.d/
COPY ./php.ini.template /usr/local/etc/php/
COPY ./www.conf.template /usr/local/etc/php-fpm.d/
COPY ./entrypoint.sh /
COPY ./startup.php /var/app/public/index.php

RUN apk update && \
    apk --no-cache add gettext shadow nginx bash libmcrypt-dev && \
    rm -rf /usr/local/etc/php-fpm.d/docker.conf /usr/local/etc/php-fpm.d/www.conf /usr/local/etc/php-fpm.d/www.conf.default /usr/local/etc/php-fpm.d/zz-docker.conf && \
    rm -rf /etc/nginx/conf.d/default.conf && \
    docker-php-ext-install opcache && \
    mkdir -p /var/run/php && \
    mkdir -p /var/tmp/nginx && \
    chown -R www-data:www-data /var/tmp/nginx && \
    mkdir -p /etc/php/7.2/fpm/env.d && \
    touch /etc/php/7.2/fpm/env.d/docker && \
    chown root /entrypoint.sh && \
    chmod +x /entrypoint.sh && \
    chown -R www-data:www-data /var/app

WORKDIR /var/app

ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 80
EXPOSE 443