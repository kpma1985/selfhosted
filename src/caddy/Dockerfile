ARG CADDY_VERSION=2.5.1

FROM caddy:${CADDY_VERSION}-builder AS builder

RUN xcaddy build \
	--with github.com/lucaslorentz/caddy-docker-proxy/plugin@e1d70e7 \
	--with github.com/caddy-dns/cloudflare \
	--with github.com/greenpau/caddy-security@v1.1.7 \
	--with github.com/greenpau/caddy-trace@v1.1.9

FROM caddy:${CADDY_VERSION}-alpine

COPY --from=builder /usr/bin/caddy /usr/bin/caddy

CMD ["caddy", "docker-proxy"]
