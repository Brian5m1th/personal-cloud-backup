# Architecture — Personal Cloud & Backup

## Diagrama de Rede

```
INTERNET
    │
    ▼
CLOUDFLARE (DNS + Proxy + DDoS)
    │
    ▼
Cloudflare Tunnel (dedicado)
    │
    ▼
Ubuntu Server
    ├── UFW: 22, 80, 443
    ├── Fail2ban: sshd, nextcloud, immich, nginx
    │
    ├── Docker Bridge: personal-cloud
    │     ├── cloudflared (túnel)
    │     ├── proxy-reverso (NPM/Traefik/Caddy)
    │     ├── homepage (dashboard)
    │     ├── nextcloud + postgres + redis
    │     ├── immich + postgres + redis + ML
    │     ├── paperless + tika + gotenberg
    │     ├── minio (S3)
    │     ├── syncthing
    │     ├── prometheus + loki + grafana
    │     ├── uptime-kuma
    │     └── ntfy
    │
    └── /srv/personal-cloud/
          ├── apps/volumes/   (containers)
          ├── media/          (arquivos pessoais)
          ├── documents/
          ├── photos/
          └── backups/
```

## Stack Tecnológica

| Camada | Tecnologia |
|--------|-----------|
| SO | Ubuntu 24.04 LTS |
| Container | Docker + Compose V2 |
| Rede | Docker bridge (subnet dinâmica) |
| Proxy | A definir (NPM / Traefik / Caddy) |
| DNS | Cloudflare |
| Tunnel | Cloudflare Tunnel (dedicado) |
| Backup | Restic + MinIO |
| Banco | PostgreSQL 17, Redis 7 |
| Logs | Loki + Promtail |
| Métricas | Prometheus + Node Exporter |
| Dashboard | Grafana + Homepage |
| Notificação | ntfy + Telegram + SMTP |
