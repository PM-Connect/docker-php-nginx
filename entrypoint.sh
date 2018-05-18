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
echo " Author: joseph@pmconnect.co.uk"
echo ""

set -e

nginx -v
php -v

echo ""

#chown -R www-data:www-data /var/app

NGINX_ERROR_PATH="/var/log/nginx/app_error.log"

if [ ! -z ${PHP_ENV_PATH+x} ]; then
  if [ -f "$PHP_ENV_PATH" ]; then
    echo "Adding PHP env variables..."
    cp "$PHP_ENV_PATH" /etc/php/7.1/fpm/env.d/env
  fi
fi

if [ ! -z ${NGINX_DOCUMENT_ROOT+x} ]; then
  echo "Changing nginx document root..."
  sed -i "s#/var/app/public#$NGINX_DOCUMENT_ROOT#g" /etc/nginx/sites-available/site.conf
fi

if [ ! -z ${NGINX_INDEX+x} ]; then
  echo "Changing nginx index file..."
  sed -i "s#index.php#$NGINX_INDEX#g" /etc/nginx/sites-available/site.conf
fi

if [ ! -z ${NGINX_APP_ERROR_FILE+x} ]; then
  echo "Changing nginx error path..."
  NGINX_ERROR_PATH="$NGINX_APP_ERROR_FILE"
  sed -i "s#/var/log/nginx/app_error.log#$NGINX_APP_ERROR_FILE#g" /etc/nginx/sites-available/site.conf
fi

if [ ! -z ${NGINX_APP_ACCESS_FILE+x} ]; then
  echo "Changing nginx access path..."
  sed -i "s#/var/log/nginx/app_access.log#$NGINX_APP_ACCESS_FILE#g" /etc/nginx/sites-available/site.conf
fi

if [ ! -z ${NGINX_APP_RESPONSE_FILE+x} ]; then
  echo "Changing nginx response path..."
  sed -i "s#/var/log/nginx/app_responses.log#$NGINX_APP_RESPONSE_FILE#g" /etc/nginx/sites-available/site.conf
fi

if [ ! -z ${DEPLOYMENT_SCRIPT_PATH+x} ]; then
  if [ -f "$DEPLOYMENT_SCRIPT_PATH" ]; then
    echo "Making deployment up script executable..."
    chmod +x "$DEPLOYMENT_SCRIPT_PATH"
    bash "$DEPLOYMENT_SCRIPT_PATH"
  fi
fi

# Capture the nginx and php pids for monitoring.
running_pids=( )

echo ""

php-fpm --nodaemonize & running_pids+=( $! )

echo ""

nginx & running_pids+=( $! )

echo ""

echo ""
echo "Monitoring php-fpm and nginx processes and exiting on failures (${running_pids[@]})..."
echo ""

# Monitor php and nginx and if either exit, stop the container.
while (( ${#running_pids[@]} )); do
  for pid_idx in "${!running_pids[@]}"; do
    pid=${running_pids[$pid_idx]}
    if ! kill -0 "$pid" 2>/dev/null; then
      exit
    fi
  done
  sleep 0.2
done
