FROM debian:12-slim
LABEL maintainer="itsiros"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    php8.2-fpm php8.2-mysql php8.2-xml php8.2-mbstring php8.2-curl \
    php8.2-gd php8.2-zip curl ca-certificates default-mysql-client \
    && rm -rf /var/lib/apt/lists/*


RUN mkdir -p /var/www/html && chown -R www-data:www-data /var/www/html

COPY www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY tools/wp-entrypoint.sh /usr/local/bin/wp-entrypoint.sh
RUN chmod +x /usr/local/bin/wp-entrypoint.sh

EXPOSE 9000

STOPSIGNAL SIGTERM

ENTRYPOINT ["/usr/local/bin/wp-entrypoint.sh"]
CMD ["php-fpm8.2", "-F"]
