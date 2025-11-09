FROM debian:latest

RUN apt update && apt upgrade -y && apt install -y nginx

COPY default /etc/nginx/sites-available/

# Link the site config
RUN ln -sf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

# Remove default nginx
RUN rm -rf /var/www/html/*

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
