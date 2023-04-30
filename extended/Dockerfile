FROM caddy:builder AS builder

RUN xcaddy build \
    --with github.com/caddyserver/certmagic \
    --with github.com/caddy-dns/cloudflare \
    --with github.com/caddy-dns/dnspod \
    --with github.com/caddy-dns/alidns \
    --with github.com/caddyserver/replace-response

FROM caddy:latest

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
