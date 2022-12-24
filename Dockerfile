FROM caddy:builder AS builder

RUN xcaddy build \
    --with github.com/caddy-dns/cloudflare \
    --with github.com/caddy-dns/dnspod \
    --with github.com/caddy-dns/alidns \
    --with github.com/caddyserver/certmagic@master=github.com/mohammed90/certmagic@master --output caddy-custom-certmagic

FROM caddy:latest

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
