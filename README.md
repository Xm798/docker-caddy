# Docker Caddy

[简体中文](README_ZH.md)

An out-of-the-box template for running Caddy with Docker.

## Included Modules

- caddy-dns/cloudflare
- caddy-dns/dnspod
- caddy-dns/alidns
- caddy-dns/tencentcloud

### Plus version

There is also a plus version of the image, which includes the following additional modules:

- caddyserver/replace-response
- mholt/caddy-dynamicdns

If you need these modules, you can use the image with the tag `plus`, for example `xm798/caddy:plus`.

## Configuration

### Clone This Repository

```bash
git clone https://github.com/Xm798/docker-caddy.git
```

### Modify the Compose File

1. Users in mainland China can use `registry.cn-shanghai.aliyuncs.com/xm798/caddy:latest` instead of `xm798/caddy:latest` to avoid image pull failures due to network issues.
2. Use `user: 1000:1000` to configure the user and group ID (1000:1000 should be set to the desired user and group ID) to avoid security risks associated with running as the root user.
3. Modify `ports` if not using the standard ports.
4. If you do not want to use a bridge network, you can directly use `network_mode: host`.

### Configure Automatic DNS Challenge

Add the corresponding configuration at the top of the global configuration section in `Caddyfiles/Caddyfile`, for example:

Cloudflare:

```Caddyfile
email user@example.com
acme_dns cloudflare "YOUR_CLOUDFLARE_TOKEN"
```

Ali DNS:

```Caddyfile
email user@example.com
acme_dns alidns {
    access_key_id "YOUR_KEY"
    access_key_secret "YOUR_ID"
    }
```

### Configure Sites

Create new files ending with `.Caddyfile` in the Caddyfiles folder, such as `proxy.Caddyfile` (you can also directly add configurations to Caddyfile, but separate files are easier to manage), and add site configurations as needed.

#### Reverse Proxy

The following configuration snippet can start a reverse proxy, `172.17.0.1:8080` is the target address. If the container has joined the `caddy_default` network, then you can directly use `container:port` to specify.

```Caddyfile
hello.example.com {
  reverse_proxy 172.17.0.1:8080
}
```

The following configuration snippet can start a proxy with a backend over HTTPS.

```Caddyfile
https.example.com {
  reverse_proxy https://test.example.com
}
```

The following configuration snippet can start a proxy with a backend over HTTPS and ignore certificate validation, which is effective for some untrusted self-signed certificates.

```Caddyfile
https.example.com {
  reverse_proxy {
    to https://10.0.0.10:443
    transport http {
      tls
      tls_insecure_skip_verify
    }
  }
}
```

#### PHP

The following configuration snippet can configure a site that requires PHP.

`php83-fpm:9000` is the address of the php-fpm docker, `/srv/php-api` is the site root directory, modify as necessary.

```Caddyfile
php-api.example.com {
  root * /srv/php-api
  php_fastcgi php83-fpm:9000
  file_server
}
```

#### Set Logs

To set logs, you can add the following snippet:

```Caddyfile
import log app_name
```

This will automatically store logs in `./log/app_name/access.log` and apply roll rules.

#### Limit Reverse Proxy Access to Whitelisted IPs

Use `import rp_ipwl 10.0.0.8:1234` to reverse proxy a site that only allows access from certain IPs, as discussed in: [一行代码快速配置 Caddy 站点日志——复用 Caddy 配置段 - Cyrus's Blog](https://blog.xm.mk/posts/f04a/). The whitelist IP ranges are configured in `Caddyfile` under `rp_ipwl`. This can be very convenient for reverse proxying services that are only allowed within a local network.

## Usage

### Create Network

```bash
docker network create  -d bridge caddy_default
```

### Create Mount Directories

```bash
mkdir data config log srv
```

If a user is specified in the compose file, you need to adjust the permissions accordingly:

```bash
sudo chown -R 1000:1000 .
```

### Start

After completing the configuration, start the container:

```bash
docker compose up -d
```

### Reload

After modifying the Caddyfile, use the following command to reload the configuration safely and quickly:

```bash
docker exec -w /etc/caddy caddy sh -c "caddy fmt --overwrite && caddy reload"
```
