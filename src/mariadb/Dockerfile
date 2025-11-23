FROM debian:buster
LABEL maintainer="itsiros"

RUN apt-get update && apt-get install -y --no-install-recommends \
  mariadb-server \
  && rm -rf /var/lib/apt/lists/*

COPY ./50-server.cnf /etc/mysql/mariadb.conf.d/50-custom.cnf

COPY tools/mariadb-entrypoint.sh /usr/local/bin/mariadb-entrypoint.sh
RUN chmod +x /usr/local/bin/mariadb-entrypoint.sh

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/mariadb-entrypoint.sh"]
CMD ["mariadb", "--user=$DB_USER", "--datadir=/var/lib/mysql"]
