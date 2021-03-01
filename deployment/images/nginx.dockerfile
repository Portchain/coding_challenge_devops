FROM nginx:1.19.7-alpine

RUN apk add --no-cache openssl \
    && mkdir -p /etc/nginx/ssl \
    && chown nginx:nginx -R /etc/nginx/ssl \
    && openssl req -x509 -nodes -newkey rsa:4096 \
      -keyout /etc/nginx/ssl/server.key \
      -out /etc/nginx/ssl/server.crt \
    -days 365 -subj "/O=Portchain/OU=DevOps/CN=localhost"

COPY nginx-entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]