#!/bin/bash

echo ""
echo "  ____  __  __  ____"
echo " |  _ \|  \/  |/ ___|"
echo " | |_) | |\/| | |"
echo " |  __/| |  | | |___"
echo " |_|__ |_|__|_|\____|____  ____  ____"
echo " |  _ \| ____\ \   / / _ \|  _ \/ ___|"
echo " | | | |  _|  \ \ / / | | | |_) \___ \\"
echo " | |_| | |___  \ V /| |_| |  __/ ___) |"
echo " |____/|_____|  \_/  \___/|_|   |____/"
echo ""
echo " Author: joseph@pmconnect.co.uk"
echo ""

set -e

nginx -v
php -v

echo ""

export APPLICATION_ROOT="${PROJECT_DIR:-/var/app}"

#
# NGINX Config Variables
#
export NGINX_SERVER_ROOT="${NGINX_SERVER_ROOT:-${APPLICATION_ROOT}/public}"
export NGINX_SERVER_INDEX="${NGINX_SERVER_INDEX:-index.php}"
export NGINX_CLIENT_MAX_BODY_SIZE="${NGINX_CLIENT_MAX_BODY_SIZE:-8m}"

export NGINX_DEFAULT_TIMEOUT="${NGINX_DEFAULT_TIMEOUT:-60s}"
export NGINX_CLIENT_HEADER_TIMEOUT="${NGINX_CLIENT_HEADER_TIMEOUT:-${NGINX_DEFAULT_TIMEOUT}}"
export NGINX_CLIENT_BODY_TIMEOUT="${NGINX_CLIENT_BODY_TIMEOUT:-${NGINX_DEFAULT_TIMEOUT}}"
export NGINX_SEND_TIMEOUT="${NGINX_SEND_TIMEOUT:-${NGINX_DEFAULT_TIMEOUT}}"
export NGINX_PROXY_CONNECT_TIMEOUT="${NGINX_PROXY_CONNECT_TIMEOUT:-${NGINX_DEFAULT_TIMEOUT}}"
export NGINX_PROXY_SEND_TIMEOUT="${NGINX_PROXY_SEND_TIMEOUT:-${NGINX_DEFAULT_TIMEOUT}}"
export NGINX_PROXY_READ_TIMEOUT="${NGINX_PROXY_READ_TIMEOUT:-${NGINX_DEFAULT_TIMEOUT}}"

export NGINX_FASTCGI_READ_TIMEOUT="${NGINX_FASTCGI_READ_TIMEOUT:-300}"
export NGINX_FASTCGI_IGNORE_CLIENT_ABORT="${NGINX_FASTCGI_IGNORE_CLIENT_ABORT:-on}"

export NGINX_ERROR_LOG="${NGINX_ERROR_LOG:-/var/log/nginx/app_error.log}"
export NGINX_ERROR_LOG_LEVEL="${NGINX_ERROR_LOG_LEVEL:-error}"
export NGINX_ACCESS_LOG="${NGINX_ACCESS_LOG:-/var/log/nginx/app_access.log}"

export NGINX_EXPIRES_HTML="${NGINX_EXPIRES_HTML:-epoch}"
export NGINX_EXPIRES_CSS="${NGINX_EXPIRES_CSS:-7d}"
export NGINX_EXPIRES_JS="${NGINX_EXPIRES_JS:-7d}"
export NGINX_EXPIRES_IMAGES="${NGINX_EXPIRES_IMAGES:-7d}"

export NGINX_FASTCGI_BUFFER_SIZE="${NGINX_FASTCGI_BUFFER_SIZE:-8k}"
export NGINX_FASTCGI_BUFFERS_NUMBER="${NGINX_FASTCGI_BUFFERS_NUMBER:-8}"
export NGINX_FASTCGI_BUFFERS_SIZE="${NGINX_FASTCGI_BUFFERS_SIZE:-8k}"

#
# PHP Config Variables
#
export PHP_POST_MAX_SIZE="${PHP_POST_MAX_SIZE:-8M}"
export PHP_UPLOAD_MAX_FILESIZE="${PHP_UPLOAD_MAX_FILESIZE:-8M}"

export PHP_MEMORY_LIMIT="${PHP_MEMORY_LIMIT:-128M}"

export PHP_OPCACHE_ENABLE="${PHP_OPCACHE_ENABLE:-1}"
export PHP_OPCACHE_MEMORY_CONSUMPTION="${PHP_OPCACHE_MEMORY_CONSUMPTION:-64}"
export PHP_OPCACHE_MAX_ACCELERATED_FILES="${PHP_OPCACHE_MAX_ACCELERATED_FILES:-10000}"
export PHP_OPCACHE_VALIDATE_TIMESTAMPS="${PHP_OPCACHE_VALIDATE_TIMESTAMPS:-0}"
export PHP_OPCACHE_REVALIDATE_FREQ="${PHP_OPCACHE_REVALIDATE_FREQ:-0}"
export PHP_OPCACHE_INTERNED_STRINGS_BUFFER="${PHP_OPCACHE_INTERNED_STRINGS_BUFFER:-16}"
export PHP_OPCACHE_FAST_SHUTDOWN="${PHP_OPCACHE_FAST_SHUTDOWN:-1}"

#
# PHP FPM Config Variables
#
export PHP_FPM_PM_MAX_CHILDREN="${PHP_FPM_PM_MAX_CHILDREN:-15}"
export PHP_FPM_PM_START_SERVERS="${PHP_FPM_PM_START_SERVERS:-5}"
export PHP_FPM_PM_MIN_SPARE_SERVERS="${PHP_FPM_PM_MIN_SPARE_SERVERS:-5}"
export PHP_FPM_PM_MAX_SPARE_SERVERS="${PHP_FPM_PM_MAX_SPARE_SERVERS:-10}"
export PHP_FPM_PM_MAX_REQUESTS="${PHP_FPM_PM_MAX_REQUESTS:-200}"
export PHP_FPM_RLIMIT_FILES="${PHP_FPM_RLIMIT_FILES:-4096}"
export PHP_FPM_RLIMIT_CORE="${PHP_FPM_RLIMIT_CORE:-0}"
export PHP_FPM_CHDIR="${PHP_FPM_CHDIR:-${APPLICATION_ROOT}}"

# Configure NGINX/PHP/PHP-FPM
envsubst '${APPLICATION_ROOT},${PHP_VERSION},${NGINX_EXPIRES_HTML},${NGINX_EXPIRES_CSS},${NGINX_EXPIRES_JS},${NGINX_EXPIRES_IMAGES},${NGINX_SERVER_ROOT},${NGINX_SERVER_INDEX},${NGINX_CLIENT_MAX_BODY_SIZE},${NGINX_CLIENT_HEADER_TIMEOUT},${NGINX_CLIENT_BODY_TIMEOUT},${NGINX_SEND_TIMEOUT},${NGINX_PROXY_CONNECT_TIMEOUT},${NGINX_PROXY_SEND_TIMEOUT},${NGINX_PROXY_READ_TIMEOUT},${NGINX_FASTCGI_READ_TIMEOUT},${NGINX_FASTCGI_IGNORE_CLIENT_ABORT},${NGINX_ERROR_LOG},${NGINX_ACCESS_LOG},${NGINX_FASTCGI_BUFFER_SIZE},${NGINX_FASTCGI_BUFFERS_NUMBER},${NGINX_FASTCGI_BUFFERS_SIZE},${NGINX_ERROR_LOG_LEVEL}' < /ops/files/site.conf.template > /etc/nginx/conf.d/site.conf
envsubst '${APPLICATION_ROOT},${PHP_VERSION},${PHP_POST_MAX_SIZE},${PHP_OPCACHE_ENABLE},${PHP_OPCACHE_MEMORY_CONSUMPTION},${PHP_OPCACHE_MAX_ACCELERATED_FILES},${PHP_OPCACHE_VALIDATE_TIMESTAMPS},${PHP_OPCACHE_REVALIDATE_FREQ},${PHP_OPCACHE_INTERNED_STRINGS_BUFFER},${PHP_OPCACHE_FAST_SHUTDOWN},${PHP_MEMORY_LIMIT},${PHP_MAX_UPLOAD_FILE_SIZE}' < /ops/files/php.ini.template > /usr/local/etc/php/php.ini
envsubst '${APPLICATION_ROOT},${PHP_VERSION},${PHP_FPM_PM_MAX_CHILDREN},${PHP_FPM_PM_START_SERVERS},${PHP_FPM_PM_MIN_SPARE_SERVERS},${PHP_FPM_PM_MAX_SPARE_SERVERS},${PHP_FPM_PM_MAX_REQUESTS},${PHP_FPM_RLIMIT_FILES},${PHP_FPM_RLIMIT_CORE},${PHP_FPM_CHDIR}' < /ops/files/www.conf.template > /usr/local/etc/php-fpm.d/www.conf

# Calculate user/group ids and set if required. (Mostly for linux)
WWW_DATA_DEFAULT=$(id -u www-data)

if [[ -z "$(ls -n $APPLICATION_ROOT | awk '{print $3}' | grep $WWW_DATA_DEFAULT)" ]]; then
  : ${WWW_DATA_UID=$(ls -ldn /var/app | awk '{print $3}')}
  : ${WWW_DATA_GID=$(ls -ldn /var/app | awk '{print $4}')}

  export WWW_DATA_UID
  export WWW_DATA_GID

  if [ "$WWW_DATA_UID" != "0" ] && [ "$WWW_DATA_UID" != "$(id -u www-data)" ]; then
    echo "Changing www-data UID and GID to ${WWW_DATA_UID} and ${WWW_DATA_GID}."
    usermod -u $WWW_DATA_UID www-data
    groupmod -g $WWW_DATA_GID www-data
    chown -R www-data:www-data $APPLICATION_ROOT
    chown -R www-data:www-data /var/tmp/nginx

    echo "Setting nginx to run using the user www-data instead of root."
    sed -i "s/user root;/user www-data;/g" /etc/nginx/nginx.conf

    echo "Setting php-fpm to run using the user www-data instead of root."
    sed -i "s/user = root/user = www-data/g" /usr/local/etc/php-fpm.d/www.conf
    sed -i "s/group = root/group = www-data/g" /usr/local/etc/php-fpm.d/www.conf

    export STARTUP_SCRIPT_USER=www-data

    echo "Changed www-data UID and GID to ${WWW_DATA_UID} and ${WWW_DATA_GID}."
  fi
fi

# Check if we have a startup script and execute.
if [ ! -z ${STARTUP_SCRIPT+x} ]; then
  if [ -f "$STARTUP_SCRIPT" ]; then
    echo "Making start-up script executable..."

    if [ ! -z ${STARTUP_SCRIPT_USER+x} ]; then
      chown "${STARTUP_SCRIPT_USER}" "$STARTUP_SCRIPT"
      chmod +x "$STARTUP_SCRIPT"

      echo "Running startup script as user: ${STARTUP_SCRIPT_USER}"

      su -c "export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin; bash ${STARTUP_SCRIPT}" -s /bin/bash "${STARTUP_SCRIPT_USER}"
    else
      chmod +x "$STARTUP_SCRIPT"
      bash "$STARTUP_SCRIPT"
    fi
  fi
fi

if [ ! -z "$@" ]; then
  # If we have arguments, run those against php instead of running php-fpm and nginx.
  set -- php "$@"
  exec "$@"
else
  # Capture the nginx and php pids for monitoring.
  running_pids=( )

  echo ""

  php-fpm -R --nodaemonize & running_pids+=( $! )

  echo ""

  nginx & running_pids+=( $! )

  echo ""

  echo ""
  echo "Monitoring php-fpm and nginx processes and exiting on failures (${running_pids[@]})..."
  echo ""

  # Monitor php-fpm and nginx and if either exit, stop the container.
  while (( ${#running_pids[@]} )); do
    for pid_idx in "${!running_pids[@]}"; do
      pid=${running_pids[$pid_idx]}
      if ! kill -0 "$pid" 2>/dev/null; then
        exit
      fi
    done
    sleep 0.2
  done
fi
