FROM caddy:builder AS builder

RUN xcaddy build \
    --with github.com/caddy-dns/cloudflare \
    --with github.com/caddy-dns/dnspod \
    --with github.com/caddy-dns/alidns

FROM caddy:latest

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
