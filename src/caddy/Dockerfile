ARG CADDY_VERSION=2.6.2

FROM caddy:${CADDY_VERSION}-builder AS builder

RUN xcaddy build \
        --with github.com/caddy-dns/cloudflare@ed330a8 \
        --with github.com/greenpau/caddy-security@v1.1.16 \
        --with github.com/greenpau/caddy-trace@v1.1.10

FROM caddy:${CADDY_VERSION}-alpine

COPY --from=builder /usr/bin/caddy /usr/bin/caddy

CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]