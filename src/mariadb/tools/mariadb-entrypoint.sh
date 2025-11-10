
#!/bin/sh
set -eu

DATADIR=/var/lib/mysql
SOCKET=/var/run/mysqld/mysqld.sock

if [ -f /run/secrets/db_root_password ]; then
  DB_ROOT_PASS="$(cat /run/secrets/db_root_password)"
else
  echo "Missing secret /run/secrets/db_root_password" >&2
  exit 1
fi

if [ -f /run/secrets/db_user_password ]; then
  DB_USER_PASS="$(cat /run/secrets/db_user_password)"
else
  echo "Missing secret /run/secrets/db_user_password" >&2
  exit 1
fi

: "${MYSQL_DATABASE:=wordpress}"
: "${MYSQL_USER:=wpuser}"

if [ ! -d "$DATADIR/mysql" ] || [ ! -f "$DATADIR/mysql/user.frm" ] 2>/dev/null; then
  echo "[mariadb-entrypoint] First run: initializing MariaDB data directory..."
  mysqld --initialize-insecure --datadir="$DATADIR" --user=mysql

  # start temporary mysqld in background
  mysqld --skip-networking --socket="$SOCKET" --datadir="$DATADIR" --user=mysql &
  MYSQ_PID=$!

  # wait for socket
  i=0
  until mysqladmin --socket="$SOCKET" ping >/dev/null 2>&1; do
    i=$((i+1))
    if [ $i -gt 30 ]; then
      echo "MariaDB failed to start for init" >&2
      kill $MYSQ_PID || true
      wait $MYSQ_PID || true
      exit 1
    fi
    sleep 1
  done

  mysql --socket="$SOCKET" <<SQL
-- set root password for local root@localhost
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASS}';
-- create database if missing
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
-- create application user (accessible from any host)
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_USER_PASS}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
SQL

  mysqladmin --socket="$SOCKET" -uroot -p"${DB_ROOT_PASS}" shutdown

  echo "[mariadb-entrypoint] Initialization complete."
fi

exec mysqld
