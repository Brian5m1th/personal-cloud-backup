# Network Architecture — Personal Cloud & Backup

## Topologia

```
INTERNET
    │
    ▼
CLOUDFLARE (DNS + DDoS + Proxy)
    │
    ▼
Cloudflare Tunnel (cloudflared container)
    │
    ▼
Docker Bridge: personal-cloud (172.31.0.0/24)
    │
    ├── cloudflared      (172.31.0.x)
    ├── homepage         (172.31.0.x:3000)
    ├── nextcloud        (172.31.0.x:80)
    ├── immich-server    (172.31.0.x:3001)
    ├── paperless        (172.31.0.x:8000)
    ├── minio            (172.31.0.x:9000/9001)
    ├── ntfy             (172.31.0.x:80)
    ├── uptime-kuma      (172.31.0.x:3001)
    ├── postgres-*       (172.31.0.x:5432)
    └── redis-*          (172.31.0.x:6379)
```

## Firewall (UFW)

| Porta | Servico | Origem |
|-------|---------|--------|
| 22/tcp | SSH | Admin IP / LAN |
| 80/tcp | HTTP (Cloudflare) | Cloudflare IPs |
| 443/tcp | HTTPS (Cloudflare) | Cloudflare IPs |

## Subdominios (Cloudflare Tunnel)

| Subdominio | Servico Interno |
|------------|----------------|
| cloud.kaostech.com.br | homepage:3000 |
| drive.kaostech.com.br | nextcloud:80 |
| photos.kaostech.com.br | immich-server:3001 |
| docs.kaostech.com.br | paperless:8000 |
| notify.kaostech.com.br | ntfy:80 |
| status.kaostech.com.br | uptime-kuma:3001 |
| storage.kaostech.com.br | minio:9001 |

## Docker Network

| Propriedade | Valor |
|-------------|-------|
| Nome | personal-cloud |
| Driver | bridge |
| Subnet | 172.31.0.0/24 |
| Gateway | 172.31.0.1 |
