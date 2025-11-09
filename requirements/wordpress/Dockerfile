FROM debian:latest

RUN apt update && apt upgrade -y && apt install -y \
	php8.4-fpm \
	php-mysqli \
	curl \
	mariadb-client

COPY www.conf /etc/php/8.4/fpm/pool.d/www.conf
COPY wordPressCli.sh /wordPressCli.sh

RUN chmod +x /wordPressCli.sh

ENTRYPOINT ["bash", "/wordPressCli.sh"]
