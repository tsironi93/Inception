#!/bin/bash
set -e

# Read DB secrets (support both _password and _pass legacy names)
if [ -f /run/secrets/db_user_password ]; then
    export DB_PASS="$(cat /run/secrets/db_user_password)"
elif [ -f /run/secrets/db_user_pass ]; then
    export DB_PASS="$(cat /run/secrets/db_user_pass)"
fi

if [ -f /run/secrets/db_root_password ]; then
    export ROOT_PASS="$(cat /run/secrets/db_root_password)"
elif [ -f /run/secrets/db_root_pass ]; then
    export ROOT_PASS="$(cat /run/secrets/db_root_pass)"
fi

# Determine DB host and port (accept WP_DB_HOST or DB_HOST)
DB_HOST_VALUE="${WP_DB_HOST:-${DB_HOST:-mariadb:3306}}"
DB_HOST_ONLY="${DB_HOST_VALUE%%:*}"
DB_PORT="${DB_HOST_VALUE##*:}"
if [ "$DB_PORT" = "$DB_HOST_ONLY" ]; then
  DB_PORT=3306
fi

# Accept WP_DB_* env names (compose provides these)
DB_USER="${WP_DB_USER:-${DB_USER}}"
DB_NAME="${WP_DB_NAME:-${DB_NAME}}"

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
  ./wp-cli.phar config create \
    --dbname="${DB_NAME}" \
    --dbuser="${DB_USER}" \
    --dbpass="${DB_PASS}" \
    --dbhost="${DB_HOST_ONLY}" \
    --dbprefix="${TABLE_PREFIX:-wp_}" \
    --extra-php='define("FORCE_SSL_ADMIN", true); define("FORCE_SSL", true);' \
    --allow-root

  echo "[wp-entrypoint] WordPress installed (admin: ${WP_ADMIN_USER})."

  if [ -n "${WP_USER:-}" ]; then
    ./wp-cli.phar user create "${WP_USER}" "${WP_USER_EMAIL}" --user_pass="${WP_USER_PASS:-$(cat /run/secrets/wp_user_pass.txt 2>/dev/null || echo '')}" --role=subscriber --allow-root || true
    echo "[wp-entrypoint] Additional WP user created: ${WP_USER}"
  fi

  chown -R www-data:www-data /var/www/html
else
  echo "[wp-entrypoint] WordPress already installed — skipping wp-cli steps."
fi

echo "[wp-entrypoint] Starting php-fpm..."
exec php-fpm8.2 -F
