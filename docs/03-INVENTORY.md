# Inventory — Personal Cloud & Backup

> **Gerado em:** 2026-07-13
> **Servidor:** ubunto (192.168.100.30)

---

## Hardware

| Componente | Especificação |
|-----------|--------------|
| CPU | AMD A8-6410 APU (4 cores, 1 thread/core) |
| RAM | 3.3 GB DDR3 SODIMM 1600MHz (1 slot vago) |
| Disco | Toshiba MQ01ABD100 — 1 TB, 2.5", 5400 RPM |
| Partições | sda1 (1GB vfat), sda2 (400GB ext4), sda3 (530GB ext4) |
| SMART | ✅ PASSED, 41°C, 0 setores ruins |
| Filesystem | / (ext4), /boot/efi (vfat), /srv/personal-cloud (ext4) |

## Sistema

| Item | Valor |
|------|-------|
| SO | Ubuntu 24.04.4 LTS |
| Kernel | 6.8.0-134-generic |
| Hostname | ubunto |
| Uptime | 1h20 |
| Load | 0.20 (baixo) |
| Swap | 8 GB (300 MB used) |
| Usuários | root, usuario, configurator, dev |

## Docker

| Item | Valor |
|------|-------|
| Engine | 29.6.1 (Community) |
| Compose | v5.3.1 |
| Containers | 12 Personal Cloud + 0 KAOS (parados) |
| Images | 25+ (5.5GB kaos-api, 5GB open-webui, 4.8GB ollama) |
| Volumes | 15 (bind mounts + Docker volumes) |
| Redes | 16 redes (personal-cloud: 172.31.0.0/24) |

### Containers Ativos (Personal Cloud)

| Nome | Status | Portas |
|------|--------|--------|
| personal-cloud-cloudflared | Up | — |
| homepage | Up (healthy) | 3000 |
| nextcloud | Up | 80 |
| postgres-nextcloud | Up | 5432 |
| redis-nextcloud | Up | 6379 |
| postgres-immich | Up | 5432 |
| redis-immich | Up | 6379 |
| minio | Up | 9000 |
| ntfy | Up | 80 |
| uptime-kuma | Up (healthy) | 3001 |
| immich-server | Parado | — |
| paperless | Parado | — |
| syncthing | Parado | — |

## Ferramentas Instaladas

✅ docker, docker compose, git, curl, wget, rsync, restic, jq, python3, node, npm, openssl, smartctl
❌ rclone, fio, iperf3, sysbench, ffmpeg, ocrmypdf, tesseract, samba, nfs, mc, aws

## Cloudflare

| Item | Valor |
|------|-------|
| Domínio | kaostech.com.br |
| Zone ID | c446a158f37b10a28d0ada843ffb3be6 |
| Account ID | a37f39e8319b86a41a2a8402b24321c0 |
| Tunnel | cloud (ID: ea6f317b...) |
| Conexões | 4 (for01, gru17, gru19, gru08) |
| Token | Configurado no .env |

### Subdomínios

| Subdomínio | Serviço | Status |
|-----------|---------|--------|
| cloud.kaostech.com.br | Homepage | ✅ Ativo |
| drive.kaostech.com.br | Nextcloud | ✅ Ativo |
| photos.kaostech.com.br | Immich | ⏸️ Offline (RAM) |
| docs.kaostech.com.br | Paperless | ⏸️ Offline (RAM) |
| notify.kaostech.com.br | ntfy | ✅ Ativo |
| status.kaostech.com.br | Uptime Kuma | ✅ Ativo |
| storage.kaostech.com.br | MinIO | ✅ Ativo |

## Segurança

| Item | Status |
|------|--------|
| UFW | ✅ Ativo (22, 80, 443 liberados) |
| Fail2ban | ✅ Ativo (sshd, nginx-http-auth) |
| SSH | ✅ Key-only (ed25519) |
| Docker | ✅ Usuário dev no grupo docker |

## Backup

| Item | Status |
|------|--------|
| Restic | ✅ Repositório criado (MinIO) |
| Próximo backup | 2026-07-14 02:00 (cron) |
| Retenção | 7 daily, 4 weekly, 6 monthly |

## Problemas Conhecidos

| # | Problema | Impacto | Solução |
|---|---------|---------|---------|
| 1 | RAM insuficiente (3.3 GB) | Impossível rodar Immich + Paperless | Comprar DDR3 SODIMM 4GB |
| 2 | HD 5400 RPM | IO lento | Upgrade para SSD futuro |
| 3 | UFW com muitas regras legadas | Risco de segurança | Limpar regras não utilizadas |
