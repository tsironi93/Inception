FROM debian:12-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
  nginx \
  ca-certificates \
  && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/nginx/ssl

EXPOSE 443

STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]
