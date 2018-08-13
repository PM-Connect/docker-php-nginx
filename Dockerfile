ARG PHP_INSTALL_VERSION='7.2'

FROM php:${PHP_INSTALL_VERSION}-fpm-alpine

ARG PROJECT_DIR='/var/app'

ENV PROJECT_DIR=$PROJECT_DIR

COPY ./nginx.conf ./site.conf.template ./php.ini.template ./www.conf.template ./entrypoint.sh ./startup.php /ops/files/

RUN apk update && \
    apk --no-cache add gettext shadow nginx bash libmcrypt-dev && \
    #
    # Copy config files/templates to where they need to be.
    cp /ops/files/nginx.conf /etc/nginx/nginx.conf && \
    cp /ops/files/entrypoint.sh /entrypoint.sh && \
    mkdir -p ${PROJECT_DIR}/public && \
    cp /ops/files/startup.php ${PROJECT_DIR}/public/index.php && \
    #
    # Remove php and nginx files that are not needed and can cause issues when run.
    rm -rf /usr/local/etc/php-fpm.d/docker.conf /usr/local/etc/php-fpm.d/www.conf /usr/local/etc/php-fpm.d/www.conf.default /usr/local/etc/php-fpm.d/zz-docker.conf && \
    rm -rf /etc/nginx/conf.d/default.conf && \
    #
    # Configure php extensions.
    docker-php-ext-install opcache && \
    #
    # Configure PHP and NGINX directories.
    mkdir -p /var/run/php && \
    mkdir -p /var/tmp/nginx && \
    chown -R www-data:www-data "/var/tmp/nginx" && \
    #
    # Set the permissions of the project directory.
    chown -R www-data:www-data "${PROJECT_DIR}" && \
    #
    # Setup the entrypoint.
    chown root /entrypoint.sh && \
    chmod +x /entrypoint.sh

WORKDIR ${PROJECT_DIR}

ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 80
EXPOSE 443
