# Docker Caddy

一个使用 Docker 运行 Caddy 的开箱即用模板。

## 包含模块

- caddy-dns/cloudflare
- ~~caddy-dns/dnspod~~
- caddy-dns/alidns
- caddy-dns/tencentcloud

**注意**：从Caddy 2.10版本开始，libdns已升级到稳定的1.0版本，其中包含许多破坏性API更改。[libdns/dnspod](https://github.com/libdns/dnspod)尚未适应此更新，导致最新构建不再包含`caddy-dns/dnspod`模块，直到libdns/dnspod解决这个问题。在此期间，您可以使用`caddy-dns/tencentcloud`作为替代方案。

### Plus 版本

同时提供了一个 Plus 版的镜像，其中包含以下附加模块：

- caddyserver/replace-response
- mholt/caddy-dynamicdns

如果需要这些模块，可以使用带有标签 `plus` 的镜像，例如 `xm798/caddy:plus`。

## 配置

### 克隆本仓库

```bash
git clone https://github.com/Xm798/docker-caddy.git
```

### 修改 compose file

1. 中国大陆用户可以使用 `registry.cn-shanghai.aliyuncs.com/xm798/caddy:latest` 代替 `xm798/caddy:latest`，避免网络原因无法拉取镜像。
2. 使用 `user: 1000:1000` 配置用户和用户组（1000:1000 需要配置为想要使用的用户和用户组 id），避免使用 root 用户运行导致的安全风险。
3. 如果不使用标准端口，自行修改 `ports`
4. 如果不想使用网桥，可以直接使用 `network_mode: host`

### 配置自动 DNS 质询

在 `Caddyfiles/Caddyfile` 中头部的全局配置段中添加对应配置，例如：

Cloudflare：

```Caddyfile
email user@example.com
acme_dns cloudflare "YOUR_CLOUDFLARE_TOKEN"
```

阿里 DNS：

```Caddyfile
email user@example.com
acme_dns alidns {
    access_key_id "YOUR_KEY"
    access_key_secret "YOUR_ID"
    }
```

### 配置站点

在 Caddyfiles 文件夹中新建以 `.Caddyfile` 结尾的文件，例如 `proxy.Caddyfile`（当然也可以在 Caddyfile 中直接添加，分文件更便于管理），在其中添加站点配置即可。

#### 反向代理

以下配置段可以启动一个反向代理，`172.17.0.1:8080` 是目标地址，如果容器已经加入了 `caddy_default` 网络，那么可以直接使用 `容器:端口` 来指定。

```Caddyfile
hello.example.com {
  reverse_proxy 172.17.0.1:8080
}
```

以下配置段可以启动一个后端是 HTTPS 的代理。

```Caddyfile
https.example.com {
  reverse_proxy https://test.example.com
}
```

以下配置段可以启动一个后端是 HTTPS 的代理，并且忽略证书验证，这对一些不受信任的自签证书很有效。

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

以下配置段可以配置一个需要使用 PHP 的网站。 

`php83-fpm:9000` 是 php-fpm docker 的地址，`/srv/php-api` 是站点根目录，注意修改。

```Caddyfile
php-api.example.com {
  root * /srv/php-api
  php_fastcgi php83-fpm:9000
  file_server
}
```

#### 设置日志

设置日志，可以添加以下 snippet：

```Caddyfile
import log app_name
```

会自动将日志存储到 `./log/app_name/access.log` 中，并应用 roll 规则。

#### 限制白名单访问反代

使用 `import rp_ipwl 10.0.0.8:1234` 可以反代一个具有只允许部分 IP 访问的站点，可以参考：[一行代码快速配置 Caddy 站点日志——复用 Caddy 配置段 - Cyrus's Blog](https://blog.xm.mk/posts/f04a/)。白名单 IP 段在 `Caddyfile` 的 `rp_ipwl` 中配置。可以很方便的反代只允许在局域网内访问的服务。

## 使用

### 创建网络

```bash
docker network create  -d bridge caddy_default
```

### 创建挂载目录

```bash
mkdir data config log srv
```

如果在 compose file 中指定用户了，需要对应修改权限：

```bash
sudo chown -R 1000:1000 .
```

### 启动

配置完成后，启动容器：

```bash
docker compose up -d
```

### 重载

修改 Caddyfile 后，可以使用以下命令来重载配置：

```bash
docker exec -w /etc/caddy caddy sh -c "caddy fmt --overwrite && caddy reload"
```
