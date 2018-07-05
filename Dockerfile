FROM php:7.2-fpm-alpine

ARG PROJECT_DIR='/var/app'
ENV PROJECT_DIR=$PROJECT_DIR

COPY ./nginx.conf ./site.conf.template ./php.ini.template ./www.conf.template ./entrypoint.sh ./startup.php /ops/files/

RUN apk update && \
    apk --no-cache add gettext shadow nginx libmcrypt-dev && \
    cp /ops/files/nginx.conf /etc/nginx/nginx.conf && \
    cp /ops/files/site.conf.template /etc/nginx/conf.d/site.conf.template && \
    cp /ops/files/php.ini.template /usr/local/etc/php/php.ini.template && \
    cp /ops/files/www.conf.template /usr/local/etc/php-fpm.d/www.conf.template && \
    cp /ops/files/entrypoint.sh /entrypoint.sh && \
    mkdir -p ${PROJECT_DIR}/public && \
    cp /ops/files/startup.php ${PROJECT_DIR}/public/index.php && \
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
    chown -R www-data:www-data ${PROJECT_DIR}

WORKDIR ${PROJECT_DIR}

ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 80
EXPOSE 443