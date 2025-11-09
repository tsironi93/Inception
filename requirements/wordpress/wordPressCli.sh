#!/bin/bash
set -e

# Load environment variables from .env
if [ -f /var/www/html/.env ]; then
    export $(grep -v '^#' /var/www/html/.env | xargs)
fi

# Parse DB host and port
DB_HOST_ONLY=${DB_HOST%:*}
DB_PORT=${DB_HOST##*:}

# Wait for MariaDB
echo "Waiting for MariaDB at $DB_HOST..."
until mysqladmin ping -h "$DB_HOST_ONLY" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" --silent; do
    sleep 3
done
echo "MariaDB is ready!"

# Ensure database exists
echo "Ensuring database '$DB_NAME' exists..."
mysql -h "$DB_HOST_ONLY" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" -e "CREATE DATABASE IF NOT EXISTS $DB_NAME CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

# Install WordPress if not installed
if [ ! -f /var/www/html/wp-config.php ]; then
    echo "Installing WordPress..."
    cd /var/www/html

    # Download wp-cli if missing
    if [ ! -f wp-cli.phar ]; then
        curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
        chmod +x wp-cli.phar
    fi

    ./wp-cli.phar core download --allow-root

    ./wp-cli.phar config create \
        --dbname="$DB_NAME" \
        --dbuser="$DB_USER" \
        --dbpass="$DB_PASS" \
        --dbhost="$DB_HOST_ONLY" \
        --dbprefix="$TABLE_PREFIX" \
        --allow-root

    ./wp-cli.phar core install \
        --url="${SITE_URL:-http://localhost}" \
        --title="$SITE_TITLE" \
        --admin_user="$ADMIN_USER" \
        --admin_password="$ADMIN_PASS" \
        --admin_email="$ADMIN_EMAIL" \
        --allow-root

    echo "WordPress installed!"

    # Optional additional user
    if [ ! -z "$USER" ]; then
        ./wp-cli.phar user create "$USER" "$USER_EMAIL" \
            --user_pass="$USER_PASS" \
            --role=subscriber \
            --allow-root
        echo "Additional WordPress user created: $USER"
    fi
else
    echo "WordPress already installed — skipping."
fi

# Start PHP-FPM in foreground
echo "Starting PHP-FPM..."
php-fpm8.4 -F

