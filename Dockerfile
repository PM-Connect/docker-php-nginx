ARG PHP_INSTALL_VERSION='7.4'

FROM php:${PHP_INSTALL_VERSION}-fpm-alpine

ARG PROJECT_DIR='/var/app'
ARG PHPREDIS_VERSION='5.0.2'

ENV PROJECT_DIR=$PROJECT_DIR
ENV PHPREDIS_VERSION=$PHPREDIS_VERSION

COPY . /ops/files/

RUN set -eux; \
    apk update && \
    apk --no-cache add gettext shadow nginx bash libmcrypt-dev icu-dev && \
	mkdir -p /entry/util && \
    #
    # Copy config files/templates to where they need to be.
    cp /ops/files/nginx.conf /etc/nginx/nginx.conf && \
    cp /ops/files/entrypoint.sh /entry/entrypoint.sh && \
    cp /ops/files/util/* /entry/util/ && \
    mkdir -p ${PROJECT_DIR}/public && \
    cp /ops/files/startup.php ${PROJECT_DIR}/public/index.php && \
    #
    # Remove php and nginx files that are not needed and can cause issues when run.
    rm -rf /usr/local/etc/php-fpm.d/docker.conf /usr/local/etc/php-fpm.d/www.conf /usr/local/etc/php-fpm.conf /usr/local/etc/php-fpm.d/www.conf.default /usr/local/etc/php-fpm.d/zz-docker.conf && \
    rm -rf /etc/nginx/conf.d/default.conf && \
    #
    # Configure php extensions.
    curl -L -o /tmp/redis.tar.gz https://github.com/phpredis/phpredis/archive/$PHPREDIS_VERSION.tar.gz && \
    tar -xzf /tmp/redis.tar.gz -C /tmp && \
    rm -r /tmp/redis.tar.gz && \
    mkdir -p /usr/src/php/ext && \
    mv /tmp/phpredis-$PHPREDIS_VERSION /usr/src/php/ext/redis && \
    docker-php-ext-install opcache intl redis && \
    #
    # Configure PHP and NGINX directories.
    # These should also be added to the entrypoint.sh file in the calculation of the user group section.
    mkdir -p /var/run/php && \
    mkdir -p /var/tmp/nginx && \
    chown -R www-data:www-data "/var/tmp/nginx" && \
    #
    # Set the permissions of the project directory.
    chown -R www-data:www-data "${PROJECT_DIR}" && \
    #
    # Setup the entrypoint.
    chown root /entry/entrypoint.sh && \
    chmod +x /entry/entrypoint.sh

WORKDIR ${PROJECT_DIR}

RUN wget -P / https://github.com/hipages/php-fpm_exporter/releases/download/v1.0.0/php-fpm_exporter_1.0.0_linux_amd64 \ 
    && chmod +x /php-fpm_exporter_1.0.0_linux_amd64

ENTRYPOINT /php-fpm_exporter_1.0.0_linux_amd64 server --phpfpm.scrape-uri="unix:///var/run/php/php${PHP_VERSION}-fpm.sock;/fpm_status" & /entry/entrypoint.sh

EXPOSE 80
EXPOSE 443
EXPOSE 9253

HEALTHCHECK --interval=30s --timeout=1s CMD curl -f http://localhost/fpm_ping || exit 1
