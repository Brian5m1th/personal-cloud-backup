# Auditoria do Servidor — Personal Cloud & Backup

> **Data:** 2026-07-12
> **Hostname:** ubunto
> **IP:** 192.168.100.30
> **SO:** Ubuntu 24.04.4 LTS (Noble Numbat)
> **Kernel:** 6.8.0-134-generic

---

## Hardware

| Componente | Especificação |
|-----------|--------------|
| CPU | AMD A8-6410 APU (4 cores) |
| RAM | 3.3 GB total (1.7 GB used, 1.5 GB available) |
| Swap | 8 GB (1.9 GB used) |
| Disco | Toshiba MQ01ABD100 — 1 TB, 2.5", 5400 RPM, SATA 3.0 Gb/s |

## Disk Layout

```
Dispositivo  Tamanho  Tipo     FS     Montagem
sda          931.5G   disk
├─sda1          1G    part    vfat   /boot/efi
└─sda2        400G    part    ext4   /
[LIVRE]       ~530G   —       —      Não alocado
```

| Partição | UUID | FS | Uso |
|----------|------|----|-----|
| sda1 | C08C-F318 | vfat | /boot/efi (6.2 MB usado) |
| sda2 | 28657b3c-... | ext4 | / (62 GB usado de 393 GB — 17%) |

### Espaço Livre Imediato

| Local | Disponível |
|-------|-----------|
| / (sda2) | 312 GB |
| Não alocado (sda) | ~530 GB |

## SMART Status

> **Overall Health: PASSED** ✅

| Métrica | Valor | Status |
|---------|-------|--------|
| Power-On Hours | 13.391 h (~1,5 anos) | ⚠️ Normal |
| Reallocated Sectors | 0 | ✅ |
| Current Pending Sector | 0 | ✅ |
| Offline Uncorrectable | 0 | ✅ |
| Temperature | 35°C (max 56°C) | ✅ |
| Start/Stop Count | 85.279 | ⚠️ Elevado |
| Load Cycle Count | 678.893 | ⚠️ Elevado (HD de laptop) |
| Spin Retry Count | 0 | ✅ |

## Docker

| Item | Versão/Valor |
|------|-------------|
| Docker Engine | 29.6.1 (Community) |
| Docker Compose | v5.3.1 |
| Containers | 15 (todos Running) |
| Images | 25 |
| Storage Driver | overlay2 |
| Cgroup Driver | systemd |
| Docker Root | /var/lib/docker |

### Containers em Execução

| Nome | Imagem | Portas |
|------|--------|--------|
| kaos-platform-kaos-api-1 | kaos-platform-kaos-api:latest | 1010→8000 |
| kaos-platform-open-webui-1 | open-webui:latest | 3000→8080 |
| kaos-platform-cloudflared-1 | cloudflare/cloudflared:latest | — |
| kaos-platform-n8n-1 | n8n:latest | 5678→5678 |
| kaos-platform-promtail-1 | grafana/promtail:3.0.0 | — |
| kaos-platform-grafana-1 | grafana/grafana:11.1.0 | 3001→3000 |
| kaos-platform-qdrant-1 | qdrant/qdrant:latest | 6333-6334 |
| kaos-platform-loki-1 | grafana/loki:3.0.0 | 3100→3100 |
| kaos-platform-blackbox-exporter-1 | blackbox-exporter:v0.25.0 | 9115→9115 |
| kaos-platform-postgres-1 | postgres:16-alpine | 5433→5432 |
| kaos-platform-prometheus-1 | prometheus:v2.54.0 | 9090→9090 |
| kaos-platform-node-exporter-1 | node-exporter:v1.8.2 | — |
| kaos-platform-ollama-1 | ollama:latest | 11434→11434 |
| kaos-platform-alertmanager-1 | alertmanager:v0.27.0 | 9093→9093 |
| kaos-platform-cadvisor-1 | cadvisor:v0.49.1 | — |

### Redes Docker

| Rede | Driver | Subnet |
|------|--------|--------|
| kaos-platform_default | bridge | 172.28.0.0/16 |
| kaos-platform_kaos_prod_network | bridge | — |
| + 12 outras redes (api, chat, wireguard, etc.) | bridge | — |

### Volumes Docker

| Volume | Uso |
|--------|-----|
| kaos-platform_postgres_data | PostgreSQL KAOS |
| kaos-platform_grafana_data | Grafana |
| kaos-platform_loki_data | Loki |
| kaos-platform_n8n_data | n8n |
| kaos-platform_ollama_data | Ollama |
| kaos-platform_open_webui_data | Open WebUI |
| kaos-platform_prometheus_data | Prometheus |
| kaos-platform_qdrant_data | Qdrant |
| kaos-platform_evolution_instances_prod | Evolution API |
| kaos-platform_hf_cache | HuggingFace cache |
| wireguard_config | WireGuard |
| postgresql-docker_pgdata | PostgreSQL outro projeto |

## Portas Abertas

| Porta | Serviço | Container |
|-------|---------|-----------|
| 22 | SSH | — |
| 53 | DNS (local) | — |
| 3000 | Open WebUI | kaos-platform |
| 3001 | Grafana | kaos-platform |
| 1010 | KAOS API | kaos-platform |
| 3100 | Loki | kaos-platform |
| 5433 | PostgreSQL | kaos-platform |
| 5678 | n8n | kaos-platform |
| 6333-6334 | Qdrant | kaos-platform |
| 9090 | Prometheus | kaos-platform |
| 9093 | Alertmanager | kaos-platform |
| 9100 | Node Exporter | kaos-platform |
| 9115 | Blackbox Exporter | kaos-platform |
| 11434 | Ollama | kaos-platform |

## Firewall

> **UFW: NÃO ATIVO** ⚠️ — Risco de segurança. Server exposto.

## Storage

- `/home/dev` — 2.0 GB
- `/var/lib/docker` — uso via overlay2

## Observações

1. **530 GB não alocados no disco** — ideal para criar partição de dados
2. **UFW desligado** — ativar como parte do hardening
3. **Cloudflared existente** (KAOS) — tunnel separado necessário para personal-cloud
4. **Subnet 172.28.0.0/16** em uso pelo KAOS — personal-cloud deve usar subnet diferente
5. **Muitas imagens `:latest`** — sem versão fixa (risco)
6. **HD 5400 rpm** — esperado desempenho de IO limitado. Priorizar benchmark com fio
