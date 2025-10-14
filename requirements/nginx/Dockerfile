FROM debian:latest

RUN apt update && apt upgrade -y && apt install -y nginx

COPY default /etc/nginx/sites-avialable/.

CMD ["nginx", "-g", "daemon off;"]
