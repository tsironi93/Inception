#!/bin/bash

set -e

if [ -f /run/secrets/db_user_pass ]; then
	export DB_PASS="$(cat /run/secrets/db_user_pass)"
fi

if [ -f /run/secrets/db_root_pass ]; then
	export ROOT_PASS="$(cat /run/secrets/db_root_pass)"
fi

echo "[wp-entrypoint] Waiting for MariaDB at ${DB_HOST_ONLY}:${DB_PORT}..."
i=0
until mysqladmin ping -h"$DB_HOST_ONLY" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASS" --silent >/dev/null 2>&1; do
  i=$((i+1))
  if [ "$i" -gt 60 ]; then
    echo "Timed out waiting for MariaDB." >&2
    exit 1
  fi
  sleep 1
done
echo "[wp-entrypoint] MariaDB reachable."

if [ ! -f /var/www/html/wp-config.php ]; then
  echo "[wp-entrypoint] WP not configured — installing..."
  cd /var/www/html

  if [ ! -f wp-cli.phar ]; then
    curl -sSL -o wp-cli.phar https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
  fi

  ./wp-cli.phar core download --allow-root

  ./wp-cli.phar config create \
    --dbname="${DB_NAME}" \
    --dbuser="${DB_USER}" \
    --dbpass="${DB_PASS}" \
    --dbhost="${DB_HOST_ONLY}" \
    --dbprefix="${TABLE_PREFIX:-wp_}" \
    --allow-root

  # install
  ./wp-cli.phar core install \
    --url="${SITE_URL}" \
    --title="${WP_TITLE:-MySite}" \
    --admin_user="${WP_ADMIN_USER}" \
    --admin_password="${WP_ADMIN_PASS}" \
    --admin_email="${WP_ADMIN_EMAIL}" \
    --skip-email \
    --allow-root

  echo "[wp-entrypoint] WordPress installed (admin: ${WP_ADMIN_USER})."

  if [ -n "${WP_USER:-}" ]; then
    ./wp-cli.phar user create "${WP_USER}" "${WP_USER_EMAIL}" --user_pass="${WP_USER_PASS}" --role=subscriber --allow-root || true
    echo "[wp-entrypoint] Additional WP user created: ${WP_USER}"
  fi

  chown -R www-data:www-data /var/www/html
else
  echo "[wp-entrypoint] WordPress already installed — skipping wp-cli steps."
fi

echo "[wp-entrypoint] Starting php-fpm..."
exec php-fpm8.1 -F
