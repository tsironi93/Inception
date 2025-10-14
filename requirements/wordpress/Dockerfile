FROM debian:latest

RUN apt update && apt upgrade -y && apt install -y php8.4-fpm \
php-mysqli \
curl

COPY www.conf /etc/php/8.4/fpm/pool.d/.

CMD ["php-fpm8.4", "-F"]
