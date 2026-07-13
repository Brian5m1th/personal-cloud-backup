# Plano de Implementação v3.0 — Personal Cloud & Backup

> **Projeto:** Personal Cloud & Backup
> **Repositório:** `C:\workspace\Extras\personal-cloud-backup`
> **Servidor Alvo:** Ubuntu Server (produção — serviços ativos)
> **Domínio:** `kaostech.com.br`
> **Data:** 2026-07-12
> **Status:** ⏳ Aguardando execução

---

## Índice

1. [Visão Geral](#1-visão-geral)
2. [Pré-requisitos](#2-pré-requisitos)
3. [Setup Local — MCP Platform](#3-setup-local--mcp-platform)
4. [Fase 0 — Auditoria do Servidor](#4-fase-0--auditoria-do-servidor)
5. [Fase 1 — Fundação](#5-fase-1--fundação)
6. [Fase 2 — Serviços](#6-fase-2--serviços)
7. [Fase 3 — Operação](#7-fase-3--operação)
8. [Arquitetura de Rede](#8-arquitetura-de-rede)
9. [Storage Design](#9-storage-design)
10. [Notification Layer](#10-notification-layer)
11. [Cloudflare Tunnel](#11-cloudflare-tunnel)
12. [ADR — Architecture Decision Records](#12-adr--architecture-decision-records)
13. [Regras de Execução](#13-regras-de-execução)
14. [Calendário de Manutenção](#14-calendário-de-manutenção)

---

## 1. Visão Geral

Transformar um servidor Ubuntu em uma infraestrutura pessoal completa de cloud e backup, substituindo serviços comerciais.

### Arquitetura Final

```
INTERNET
    │
    ▼
CLOUDFLARE (DNS + Proxy + DDoS)
    │
    ▼
Cloudflare Tunnel (dedicado — personal-cloud)
    │
    ▼
Ubuntu Server
    ├── Docker Bridge (subnet dinâmica)
    │     ├── cloudflared (túnel)
    │     ├── proxy reverso (NPM / Traefik / Caddy)
    │     ├── homepage (dashboard)
    │     ├── nextcloud + postgres + redis
    │     ├── immich + postgres + redis + ML
    │     ├── paperless + tika + gotenberg
    │     ├── minio (S3 compatível)
    │     ├── syncthing
    │     ├── prometheus + loki + grafana
    │     ├── uptime-kuma
    │     └── ntfy (notificações)
    │
    ├── Firewall (UFW): 22, 80, 443, 51820 (WireGuard)
    ├── Fail2ban: sshd, nextcloud, immich, nginx
    └── Usuário dedicado: personal-cloud
```

### Serviços e Subdomínios

| Subdomínio | Serviço | Porta Interna |
|------------|---------|---------------|
| `cloud.kaostech.com.br` | Homepage Dashboard | homepage:3000 |
| `drive.kaostech.com.br` | Nextcloud | nextcloud:80 |
| `photos.kaostech.com.br` | Immich | immich-server:3001 |
| `docs.kaostech.com.br` | Paperless-ngx | paperless:8000 |
| `storage.kaostech.com.br` | MinIO Console | minio:9001 |
| `notify.kaostech.com.br` | ntfy | ntfy:80 |
| `grafana.kaostech.com.br` | Grafana | grafana:3000 |
| `status.kaostech.com.br` | Uptime Kuma | uptime-kuma:3001 |

---

## 2. Pré-requisitos

### Servidor Ubuntu

| Requisito | Mínimo | Recomendado |
|-----------|--------|-------------|
| CPU | 2 cores | 4+ cores |
| RAM | 4 GB | 8+ GB |
| Disco | 500 GB | 1 TB+ |
| Ubuntu | 22.04 LTS | 24.04 LTS |
| Docker | 24+ | 27+ |
| Docker Compose | v2 | v2 |

### Máquina Local (Windows)

| Programa | Versão | Verificar |
|----------|--------|-----------|
| Python | ≥ 3.11 | `python --version` |
| Node.js | ≥ 18 | `node --version` |
| npm | ≥ 9 | `npm --version` |
| Git | ≥ 2 | `git --version` |
| gh (GitHub CLI) | ≥ 2 | `gh --version` |

### Domínio

- `kaostech.com.br` configurado no Cloudflare
- Cloudflare API Token com permissão para criar Tunnels e DNS

---

## 3. Setup Local — MCP Platform

### 3.1 Verificar instalação

```powershell
cd C:\workspace\Extras\personal-mcp-platform
python --version
python -m pip --version
```

### 3.2 Adicionar SSH MCP ao registry.yaml

Editar `registry.yaml` — adicionar entrada:

```yaml
- id: ssh
  name: SSH MCP Server
  version: 0.1.0
  category: remote-access
  description: SSH remote server management
  maturity: stable
  protocol:
    default: stdio
    transports:
      - type: stdio
        command: npx
        args: ["-y", "@modelcontextprotocol/server-ssh"]
        env:
          SSH_HOST: ${secrets.ssh.host}
          SSH_USER: ${secrets.ssh.user}
          SSH_KEY: ${secrets.ssh.key}
  permissions:
    filesystem: none
    network: ssh-port
    shell: true
    secrets: [SSH_HOST, SSH_USER, SSH_KEY]
    risks:
      - level: critical
        description: Shell access to remote server
  requirements:
    node: ">=18"
    npm: true
  agents: [opencode, claude-code, cursor]
  platforms: [linux, macos, windows, wsl]
  install:
    method: npx
    command: npx @modelcontextprotocol/server-ssh
    auto_update: true
```

### 3.3 Criar profile cloud-backup

Criar `profiles/cloud-backup.yaml`:

```yaml
name: "Cloud Backup Infrastructure"
description: "MCPs para deploy do servidor cloud-backup"
icon: "cloud"
priority: 30
enabled_servers:
  - id: ssh
    tools: "*"
  - id: docker
    tools: "*"
  - id: filesystem
    workspace_bound: true
    allowed_paths:
      - "{{workspace}}/**"
  - id: sequential-thinking
    tools: "*"
  - id: fetch
    tools: "*"
  - id: memory
    tools: "*"
disabled_servers:
  - postgres
  - playwright
  - serena
  - context7
```

### 3.4 Instalar MCPs e vincular projeto

```powershell
# Ativar profile
& "C:\Users\brian\AppData\Local\Python\pythoncore-3.14-64\Scripts\mcp.exe" profile set cloud-backup

# Instalar servidores
& "C:\Users\brian\AppData\Local\Python\pythoncore-3.14-64\Scripts\mcp.exe" install ssh
& "C:\Users\brian\AppData\Local\Python\pythoncore-3.14-64\Scripts\mcp.exe" install docker
& "C:\Users\brian\AppData\Local\Python\pythoncore-3.14-64\Scripts\mcp.exe" install filesystem
& "C:\Users\brian\AppData\Local\Python\pythoncore-3.14-64\Scripts\mcp.exe" install sequential-thinking
& "C:\Users\brian\AppData\Local\Python\pythoncore-3.14-64\Scripts\mcp.exe" install fetch
& "C:\Users\brian\AppData\Local\Python\pythoncore-3.14-64\Scripts\mcp.exe" install memory

# Configurar secrets SSH
$env:SSH_HOST = "ip-do-servidor"
$env:SSH_USER = "usuario"
$env:SSH_KEY = "caminho-da-chave"

# Vincular projeto
cd C:\workspace\Extras\personal-cloud-backup
& "C:\Users\brian\AppData\Local\Python\pythoncore-3.14-64\Scripts\mcp.exe" project add --agent opencode --profile cloud-backup

# Gerar config OpenCode
& "C:\Users\brian\AppData\Local\Python\pythoncore-3.14-64\Scripts\mcp.exe" generate opencode

# Iniciar servidores MCP
& "C:\Users\brian\AppData\Local\Python\pythoncore-3.14-64\Scripts\mcp.exe" start
```

---

## 4. Fase 0 — Auditoria do Servidor

> **⚠ Regra:** Servidor em produção. Nenhuma alteração — apenas coleta de dados.

### Checklist de Auditoria

```bash
# Hardware e discos
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT
blkid
df -h && df -i
fdisk -l / parted -l

# SMART (obrigatório)
smartctl -a /dev/sda
smartctl -H /dev/sda
# Verificar: PASSED, Reallocated_Sector_Ct, Power_On_Hours, Temperature

# Docker
docker info
docker ps -a
docker network ls
docker network inspect $(docker network ls -q)
docker volume ls
docker system df

# Rede
ss -tlnp
ip route
ip addr
wg show 2>/dev/null || echo "no wireguard"
tailscale status 2>/dev/null || echo "no tailscale"

# Firewall
ufw status verbose

# Sistema
cat /etc/os-release && uname -a
systemctl list-units --type=service --state=running
cat /etc/fstab
lsof -i -P -n | grep LISTEN

# Espaço
du -sh /srv/* /var/lib/docker/* 2>/dev/null
```

### Entregável

`docs/02-AUDITORIA-SERVIDOR.md` com todos os outputs e análise.

---

## 5. Fase 1 — Fundação

### 5.1 Docker Network (subnet dinâmica)

```bash
# 1. Listar redes existentes
docker network ls

# 2. Verificar conflitos
ip route
ip addr
docker network inspect $(docker network ls -q) --format '{{.Name}} {{.IPAM.Config}}'

# 3. Verificar VPNs
wg show 2>/dev/null
tailscale status 2>/dev/null

# 4. Criar rede com subnet LIVRE
# ⚠ NUNCA usar subnet fixa — detectar range disponível primeiro
docker network create \
  --driver bridge \
  --attachable \
  --subnet <SUBNET-LIVRE> \
  personal-cloud

# ⚠ NENHUM IP fixo — usar DNS interno do Docker
# Container: postgres-nextcloud → Resolve via DNS: postgres-nextcloud:5432
```

### 5.2 Usuário dedicado

```bash
sudo useradd -r -s /bin/bash -m -d /srv/personal-cloud personal-cloud
sudo usermod -aG docker personal-cloud
```

### 5.3 Estrutura de diretórios

```bash
# Árvore final:
/srv/personal-cloud/
├── apps/volumes/       # Dados dos containers (bind mounts)
│   ├── nextcloud/
│   ├── postgres-*/
│   ├── immich/
│   ├── redis/
│   ├── minio/
│   ├── paperless/
│   ├── syncthing/
│   ├── grafana/
│   ├── prometheus/
│   ├── loki/
│   ├── ntfy/
│   ├── homepage/
│   └── cloudflared/
├── config/             # Configs manuais
├── media/              # Dados pessoais (imutáveis)
├── documents/          # Dados pessoais
├── photos/             # Dados pessoais
├── archives/           # Dados frios
├── backups/            # Restic + dumps + snapshots
└── tmp/                # Descartável
```

```bash
# Criar estrutura
sudo mkdir -p /srv/personal-cloud/{apps/volumes,config,media,documents,photos,archives,backups,tmp}
sudo chown -R personal-cloud:personal-cloud /srv/personal-cloud
sudo chmod 755 /srv/personal-cloud
```

### 5.4 Cloudflare Tunnel

```yaml
# docker/stacks/cloudflared/docker-compose.yml
services:
  cloudflared:
    image: cloudflare/cloudflared:2026.7.0
    container_name: cloudflared
    restart: unless-stopped
    command: tunnel --no-autoupdate run
    environment:
      - TUNNEL_TOKEN=${TUNNEL_TOKEN}
    volumes:
      - /srv/personal-cloud/apps/volumes/cloudflared:/home/nonroot/.cloudflared
    networks:
      - personal-cloud
    logging:
      driver: json-file
      options:
        max-size: 10m
        max-file: "3"
```

### 5.5 Proxy Reverso

**Pesquisa obrigatória antes da decisão:** Comparar Nginx Proxy Manager vs Traefik vs Caddy vs Nginx puro. Ver ADR-0004.

### 5.6 Dashboard

Homepage ou Homarr como landing page. Ver ADR-0005.

### 5.7 Monitoramento

Prometheus + Loki + Promtail + Grafana + Uptime Kuma.

### 5.8 Notificações

ntfy + Telegram + SMTP. Ver [Seção 10](#10-notification-layer).

---

## 6. Fase 2 — Serviços

### 6.1 Banco de Dados (PostgreSQL + Redis)

Stacks separadas para Nextcloud e Immich:

```yaml
# docker/stacks/databases/postgres.yml (template)
services:
  postgres-nextcloud:
    image: postgres:17.5
    container_name: postgres-nextcloud
    restart: unless-stopped
    volumes:
      - /srv/personal-cloud/apps/volumes/postgres-nextcloud:/var/lib/postgresql/data
    environment:
      POSTGRES_DB: nextcloud
      POSTGRES_USER: nextcloud
      POSTGRES_PASSWORD: ${POSTGRES_NEXTCLOUD_PASSWORD}
    networks:
      - personal-cloud
```

### 6.2 Nextcloud

| Item | Configuração |
|------|-------------|
| Imagem | `nextcloud:30.0.6` |
| Banco | PostgreSQL 17.5 |
| Cache | Redis 7.4 |
| Volumes | `apps/volumes/nextcloud/{files,config,apps,themes}` |
| Proxy | Via reverse proxy (NPM/Traefik/Caddy) |

### 6.3 Immich

| Item | Configuração |
|------|-------------|
| Imagem | `ghcr.io/immich-app/immich-server:v1.x` |
| Banco | PostgreSQL 17.5 |
| Cache | Redis 7.4 |
| ML | `immich-machine-learning` |
| Volumes | `apps/volumes/immich/{upload,library,thumbs,profile,video}` |

### 6.4 MinIO

| Item | Configuração |
|------|-------------|
| Imagem | `minio/minio:RELEASE.2026-XX-XX` |
| Portas | 9000 (API), 9001 (Console) |
| Buckets | nextcloud, immich, backups, archives |
| Volumes | `apps/volumes/minio/data` |

> **⚠ ATENÇÃO:** MinIO está no MESMO servidor. Backup externo REAL é obrigatório futuramente (HD USB, Backblaze, Wasabi, outro servidor). MinIO protege contra erro humano, não contra desastre físico.

### 6.5 Paperless-ngx

| Item | Configuração |
|------|-------------|
| Imagem | `ghcr.io/paperless-ngx/paperless-ngx:2.x` |
| Tika | `ghcr.io/paperless-ngx/tika:latest` (versão fixa) |
| Gotenberg | `gotenberg/gotenberg:8.x` |
| Volumes | `apps/volumes/paperless/{data,media,consume}` |

### 6.6 Syncthing

| Item | Configuração |
|------|-------------|
| Imagem | `syncthing/syncthing:1.28` |
| Portas | 8384 (GUI), 22000 (TCP), 21027 (UDP) |
| Volumes | `apps/volumes/syncthing/{config,data}` |

---

## 7. Fase 3 — Operação

### 7.1 Pipeline de Backup de Bancos

```bash
# scripts/backup-bancos.sh
# Para CADA banco PostgreSQL:
#   1. pg_dump -Fc > /srv/personal-cloud/backups/dumps/<db>-<date>.dump
#   2. gzip
#   3. sha256sum > checksum
#   4. restic backup (apenas o dump)
#   5. restic check
#   6. Limpar dumps > 7 dias
```

### 7.2 Pipeline Restic

```bash
# Destino: MinIO (bucket: backups)
# Frequência: Diária (cron)
# Retenção: 7 daily, 4 weekly, 6 monthly
# Tags por serviço: nextcloud, immich, paperless, postgres, configs

restic backup \
  --tag "nextcloud-$(date +%Y%m%d)" \
  /srv/personal-cloud/apps/volumes/nextcloud

restic forget \
  --keep-daily 7 --keep-weekly 4 --keep-monthly 6 \
  --prune
```

### 7.3 Política de Atualização

```
1. Ler release notes
2. Verificar breaking changes
3. Executar snapshot.sh (backup completo + dumps)
4. Atualizar tag no docker-compose.yml
5. docker compose pull && docker compose up -d
6. Executar health-check.sh
7. Se falhar: docker compose down + reverter tag e volumes
8. Monitorar por 24h antes de remover snapshot
```

### 7.4 Política de Snapshots

```bash
# scripts/snapshot.sh
# Antes de qualquer upgrade:
restic backup \
  --tag "pre-upgrade-$1-$(date +%Y%m%d)" \
  /srv/personal-cloud/apps/volumes/$1

pg_dump -h postgres-$1 -U $1 -Fc > /tmp/$1-$(date +%Y%m%d).dump
restic backup --tag "db-$1-pre-upgrade" /tmp/$1-*.dump
```

### 7.5 Segurança / Hardening

- UFW: permitir apenas 22, 80, 443, 51820 (WireGuard)
- Fail2ban: sshd, nextcloud, immich, nginx-proxy
- SSH: key-only, desabilitar password
- Docker: containers com `read_only` quando possível
- Secrets: `.env` files com permissão 600
- Certificados: Let's Encrypt via Cloudflare (automático)

### 7.6 Testes

| Teste | Frequência |
|-------|-----------|
| `tests/backup/test-restore.sh` | Semanal |
| `tests/network/test-ports.sh` | Diário |
| `tests/network/test-ssl.sh` | Diário |
| `tests/security/test-hardening.sh` | Semanal |
| `tests/performance/test-benchmark.sh` | Mensal |

### 7.7 Benchmark

| Teste | Ferramenta |
|-------|-----------|
| IOPS sequencial leitura | `fio --rw=read --bs=1M --size=1G --direct=1` |
| IOPS sequencial escrita | `fio --rw=write --bs=1M --size=1G --direct=1` |
| IOPS aleatório 4K | `fio --rw=randrw --bs=4k --size=1G --iodepth=64` |
| Latência disco | `ioping -c 100 /srv/personal-cloud/` |
| Throughput rede | `iperf3` |
| Referência rápida | `dd if=/dev/zero of=/tmp/test bs=1M count=1024` |

---

## 8. Arquitetura de Rede

```
INTERNET
    │
    ▼
CLOUDFLARE (DNS + Proxy + Tunnel)
    │
    ▼
Cloudflare Tunnel (cloudflared container — dedicado)
    │
    ▼
Docker Bridge: personal-cloud (subnet DETECTADA, não fixa)
    │
    ├── cloudflared
    ├── proxy-reverso (NPM/Traefik/Caddy)
    ├── homepage (dashboard)
    ├── nextcloud:80
    ├── immich-server:3001
    ├── paperless:8000
    ├── minio:9000 / minio:9001
    ├── syncthing:8384
    ├── grafana:3000
    ├── uptime-kuma:3001
    ├── ntfy:80
    └── postgres-*:5432 / redis:6379
```

### Regras de Firewall (UFW)

| Direção | Porta | Serviço | Origem |
|---------|-------|---------|--------|
| IN | 22/tcp | SSH | Admin IP / VPN |
| IN | 80/tcp | HTTP (redirect) | Cloudflare IPs |
| IN | 443/tcp | HTTPS | Cloudflare IPs |
| IN | 51820/udp | WireGuard | Qualquer (opcional) |
| OUT | * | Livre | — |

### Portas Internas (Docker — nunca expostas)

| Porta | Serviço |
|-------|---------|
| 5432 | PostgreSQL |
| 6379 | Redis |
| 9000 | MinIO API |
| 9001 | MinIO Console |
| 8384 | Syncthing GUI |
| 22000 | Syncthing TCP |
| 21027 | Syncthing UDP |

---

## 9. Storage Design

### Processo de Decisão

```
Auditoria → Layout Atual → Espaço Livre → Partições
→ Filesystem Check → Benchmark → Proposta
→ APROVAÇÃO HUMANA → Migração
```

### Estrutura de Dados

```
/srv/personal-cloud/
│
├── apps/volumes/          ← Dados dos containers (mutáveis, com backup)
│   ├── nextcloud/
│   ├── postgres-*/
│   ├── immich/
│   └── ...
│
├── config/                ← Configs editadas manualmente
├── media/                 ← SEUS ARQUIVOS (imutáveis)
├── documents/             ← SEUS ARQUIVOS
├── photos/                ← SEUS ARQUIVOS
├── archives/              ← Dados frios
├── backups/               ← Restic + dumps + snapshots
│   ├── dumps/
│   ├── restic/
│   └── exports/
├── tmp/                   ← Descartável
└── logs/                  ← Persistência opcional
```

### Regra de Volumes

> **Nenhum container monta fora de `/srv/personal-cloud/apps/volumes/`.**

### Imagens Docker

> **⚠ PROIBIDO usar `:latest`. Toda imagem com versão fixa.**

✅ `image: postgres:17.5`
❌ `image: postgres:latest`

---

## 10. Notification Layer

### Arquitetura

```
Evento → notify.sh (script central)
           ├── Telegram Sender
           ├── SMTP Sender
           └── ntfy Sender (self-hosted)
```

### Eventos Obrigatórios

| Categoria | Eventos |
|-----------|---------|
| Backup | iniciado, concluído, falhou, parcial |
| Restore | iniciado, concluído, falhou |
| Storage | disco 80%, 90%, 95%, cheio |
| Containers | iniciado, parado, reiniciado, unhealthy |
| Sistema | reboot, updates, falha serviço, cert expirando |
| Segurança | SSH suspeito, Fail2ban block, config alterada |
| Health | all OK, serviço indisponível |

### Regras

1. Nenhum serviço envia notificação diretamente — tudo via `notify.sh`
2. Se um canal falha, os demais continuam
3. Toda notificação é logada em `logs/notifications/`
4. Templates reutilizáveis (success, warning, error, info)

---

## 11. Cloudflare Tunnel

### Stack Dedicada

```yaml
# docker/stacks/cloudflared/docker-compose.yml
services:
  cloudflared:
    image: cloudflare/cloudflared:2026.7.0
    container_name: cloudflared
    restart: unless-stopped
    command: tunnel --no-autoupdate run
    environment:
      - TUNNEL_TOKEN=${TUNNEL_TOKEN}
    volumes:
      - /srv/personal-cloud/apps/volumes/cloudflared:/home/nonroot/.cloudflared
    networks:
      - personal-cloud
    logging:
      driver: json-file
      options:
        max-size: 10m
        max-file: "3"
```

### Regras

- Container **exclusivo** para este projeto
- Token próprio (nunca reutilizar de outros projetos)
- Reinício automático (`restart: unless-stopped`)
- Logs persistentes
- Rede `personal-cloud` apenas
- Nenhuma alteração em túneis existentes sem aprovação

---

## 12. ADR — Architecture Decision Records

| ADR | Título | Status |
|-----|--------|--------|
| 0001 | Storage Layout | Pendente |
| 0002 | Network Architecture | Pendente |
| 0003 | Docker Structure | Pendente |
| 0004 | Proxy Reverse (pesquisa obrigatória) | Pendente |
| 0005 | Dashboard Choice | Pendente |
| 0006 | Notification Layer | Pendente |
| 0007 | Backup Strategy | Pendente |
| 0008 | Cloudflare Tunnel | Pendente |
| 0009 | Technology Selection | Pendente |

---

## 13. Regras de Execução

### Regras Gerais

1. **Nunca assumir** que a tecnologia do plano inicial é a melhor — pesquisar antes de cada deploy
2. **Nenhuma alteração destrutiva sem aprovação** — `fdisk`, `mkfs`, `docker rm -f` só após confirmação
3. **Backup antes de editar** — qualquer config alterada tem cópia em `/srv/personal-cloud/backups/pre-setup/`
4. **Validação pós-deploy** — todo serviço verificado antes de passar ao próximo
5. **Log de tudo** — cada comando executado salvo em `logs/`
6. **Reproduzível** — qualquer pessoa com este repo e um servidor Ubuntu recria tudo
7. **Sem secrets no repo** — senhas, tokens, chaves em `.env` (gitignored) ou MCP secrets manager
8. **`docker compose ps` + `curl`** em todo deploy para validar health

### Regras de Imagens Docker

- **Nunca usar `:latest`** — sempre versão fixa
- Verificar release notes antes de atualizar
- Seguir política de snapshot antes de upgrades

### Regras de Rede Docker

- **Nunca definir subnet fixa** no plano — detectar range livre no momento da criação
- **Nunca definir IPs fixos** para containers — usar DNS interno do Docker
- Verificar WireGuard, Tailscale e outras VPNs antes de escolher a subnet

### Regra de Tecnologia

> A IA nunca deve assumir que uma tecnologia é a melhor apenas porque estava no plano inicial. Antes de implantar cada serviço, deve pesquisar o estado atual do ecossistema, apresentar comparação se houver alternativa superior, e solicitar aprovação antes de alterar o plano.

---

## 14. Calendário de Manutenção

| Frequência | Tarefa |
|-----------|--------|
| **Diário** | health-check.sh |
| **Diário** | Verificar notificações |
| **Semanal** | test-restore.sh (1 arquivo aleatório) |
| **Semanal** | smartctl / df -h |
| **Mensal** | Atualizar containers (com snapshot) |
| **Mensal** | Revisar logs (Loki, Docker, Restic) |
| **Mensal** | benchmark.sh |
| **Trimestral** | Teste completo de restore |
| **Trimestral** | Revisar certificados SSL |
| **Trimestral** | Atualizar documentação |
| **Semestral** | Teste de DR (servidor do zero) |
| **Semestral** | Backup externo (HD USB / cloud) |

---

## Política de Retenção de Logs

| Fonte | Retenção | Tamanho |
|-------|----------|---------|
| Loki | 30 dias | 10 GB |
| ntfy | 7 dias | 1 GB |
| Docker (json-file) | 3 x 10 MB | 30 MB/container |
| Restic logs | 90 dias | — |
| Notification logs | 30 dias | 500 MB |

---

## Plano de Energia (`POWER.md`)

### Comportamento pós-queda

| Componente | Comportamento |
|-----------|---------------|
| Ubuntu | Auto-start (se BIOS permitir) |
| Docker | `systemctl enable docker` |
| Containers | `restart: unless-stopped` |
| PostgreSQL | WAL + recovery automático |
| Restic | Próximo cron retoma |
| Cloudflare Tunnel | Reconexão automática |

### Checklist pós-energia

1. `systemctl status docker`
2. `docker ps` — todos running?
3. `docker compose ps` em cada stack
4. `curl -I https://drive.kaostech.com.br`
5. `restic check`
6. Verificar `journalctl -xe | grep -i error`

### Recomendação futura

Nobreak (UPS) com `apcupsd` ou `nut` para desligamento automático + notificação.

---

## Expansão Futura (`EXPANSION.md`)

| Cenário | Solução |
|---------|---------|
| Disco cheio | Adicionar HDD, montar em `/srv/personal-cloud` |
| SSD para banco | Migrar volumes PostgreSQL/Redis para SSD |
| NAS | Montar NFS em `/srv/personal-cloud/archive/` |
| RAID | mdadm ou ZFS mirror |
| Migrar servidor | Script `restore.sh` + rsync dos volumes |
| Backup externo | Backblaze B2, Wasabi, HD USB, outro servidor |

---

## Estrutura do Repositório

```
personal-cloud-backup/
├── PLANO_COMPLETO.md          ← Este documento
├── README.md
├── ARCHITECTURE.md
├── ROADMAP.md
├── CHANGELOG.md
├── EXPANSION.md
├── POWER.md
├── .editorconfig
├── .gitignore
├── ADR/
├── docs/
├── docker/stacks/
├── docker/shared/
├── scripts/
├── notification/
├── configs/
├── inventory/
├── tests/
├── benchmarks/
└── logs/
```

---

> **Documento gerado em:** 2026-07-12
> **Versão do Plano:** v3.0
> **Próxima ação:** Setup MCP Platform + Auditoria do Servidor
