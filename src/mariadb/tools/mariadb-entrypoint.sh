#!/bin/bash
set -eu

DATADIR=/var/lib/mysql
SOCKET=/var/run/mysqld/mysqld.sock

DB_ROOT_PASS="$(cat /run/secrets/db_root_password)"
DB_USER_PASS="$(cat /run/secrets/db_user_password)"

: "${MYSQL_DATABASE:=wordpress}"
: "${MYSQL_USER:=wpuser}"

# Initialize database if empty
if [ ! -d "$DATADIR/mysql" ]; then
  echo "[mariadb-entrypoint] First run: initializing MariaDB data directory..."
  mysql_install_db --user=mysql --datadir="$DATADIR"

  mysqld_safe --skip-networking &
  MYSQ_PID=$!

  # wait for the socket to be ready
  for i in {1..30}; do
    if mysqladmin --socket="$SOCKET" ping >/dev/null 2>&1; then
      break
    fi
    sleep 1
  done

  mysql --socket="$SOCKET" <<SQL
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASS}';
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_USER_PASS}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
SQL

  mysqladmin --socket="$SOCKET" -uroot -p"${DB_ROOT_PASS}" shutdown
  echo "[mariadb-entrypoint] Initialization complete."
fi

exec mysqld_safe
