# Relatório de Auditoria Completa — Servidor Ubuntu

**Data:** 2026-07-13  
**Servidor:** ubunto (192.168.100.30)  
**Anfitrião:** Toshiba Satellite C55D-B (Laptop, 2014)  
**Sistema:** Ubuntu 24.04.4 LTS (Noble Numbat)  
**Kernel:** 6.8.0-134-generic x86_64  
**CPU:** AMD A8-6410 APU (4× 2.0GHz, sem hyper-threading)  
**RAM:** 3.3 GiB  
**Disco:** TOSHIBA MQ01ABD100 — 1TB 5400rpm HDD 2.5"  
**Uptime:** 4h31min  
**Load Average:** 8.47 / 5.70 / 5.06 (crítico — acima de 4× núcleos)

---

## Sumário Executivo

O servidor opera em **hardware extremamente limitado** (laptop 2014, 3.3GB RAM, HDD 5400rpm) e está severamente sobrecarregado. Diversos containers estão quebrados ou parados, o monitoramento está completamente inoperante, e há riscos de segurança significativos com credenciais expostas em plaintext.

**Nota Geral: 3.5 / 10**

---

## 1. Sistema Operacional — Nota: 4/10

### Pontos Positivos
- Ubuntu 24.04.4 LTS — versão atual
- Kernel 6.8.0-134 — atualizado
- Livepatch ativo (Canonical) — suportado até 2027-07
- Unattended-upgrades ativo
- Sem reboot pendente

### Problemas

| Problema | Severidade |
|---|---|
| 23 kernels antigos desinstalados mas registrados (`rc`) | Média |
| Kernel antigo `6.8.0-64-generic` ainda instalado | Baixa |
| Linux headers `6.8.0-64` ocupando espaço | Baixa |
| Snap: apenas 3 snaps (ok), livepatch ativo | OK |
| Firmware de 2014 (12 anos desatualizado) | Média |
| Sem microcode updates para AMD | Média |

### Firmware
- **Firmware Version:** 1.30 (06/2014) — 12 anos desatualizado
- **Firmware Age:** 12y 1m — BIOS/UEFI desatualizado
- AMD A8-6410 não possui microcode atualizável via linux-firmware

### Logs de Atualização
- Últimas instalações: smartmontools (Jul 13), restic (Jul 13), curl/jq/dnsutils (Jul 11)
- wireguard removido (Jul 11)

---

## 2. Hardware — Nota: 2/10

### CPU
- **Frequência:** 1000-2000MHz, escalando 50% — governor `schedutil`
- **Temperatura:** 60.1°C (k10temp), 62°C (GPU)
- **Throttling:** não detectado (dmesg indisponível sem root total)
- **Sem thermal throttling aparente**
- **Load avg:** 8.47 — **mais que o dobro da capacidade** (4 cores sem HT)

### Memória
- **Total:** 3.3 GiB (insuficiente para a carga)
- **Used:** 1.7 GiB + 1.9 GiB buffers/cache
- **Available:** 1.6 GiB
- **Swap total:** 8 GiB (2 arquivos de 4GB)
- **Swap used:** 247 MiB
- **Swappiness:** 60 (muito alto — causa swap prematura)
- **ZRAM:** não configurado (deveria estar, dada a RAM limitada)

### Disco (HDD)

| Métrica | Valor | Status |
|---|---|---|
| Modelo | TOSHIBA MQ01ABD100 1TB | — |
| RPM | 5400 | LENTO |
| Interface | SATA 3.0 Gb/s | OK |
| Horas ligado | 13,398h (~1.5 anos) | OK |
| Start/Stop | 85,287 | Muito alto (laptop) |
| **Load Cycle Count** | **678,901** | ⚠️ **CRÍTICO** |
| Reallocated Sectors | 0 | OK |
| Pending Sectors | 0 | OK |
| Temperatura | 40°C | OK |
| SMART Errors | 1 (ICRC — possível cabo) | Baixo |
| **iowait** | **15-65%** | ⚠️ **CRÍTICO** |
| **Disk util** | **48-69%** | ⚠️ **ALTO** |

**Load Cycle Count de 678,901** está próximo do limite típico de 600k-1M para este modelo. Em laptops, o Load Cycle reduz a vida útil do HDD.

### IO Stats
- **Iowait pico:** 65.65% (CPU esperando disco)
- **Disk util:** 68.6% no pico — saturado
- **Scheduler:** mq-deadline (adequado para HDD)
- **TRIM:** ativo mas irrelevante para HDD
- **Sem fstrim funcional** (HDD não suporta)

---

## 3. Partições — Nota: 5/10

| Partição | Tamanho | Uso | FSTYPE | Montagem | Opções |
|---|---|---|---|---|---|
| sda1 | 1G | 1% | vfat | /boot/efi | defaults |
| sda2 | 400G | 19% | ext4 | / | defaults,relatime |
| sda3 | 531G | 1% | ext4 | /srv/personal-cloud | defaults,relatime,nofail |

### Problemas
- **Falta `noatime`** em ambas as partições ext4 → writes extras no HDD
- **Falta `discard`** (não que faça diferença em HDD)
- **UUID inconsistente**: fstab usa `/dev/disk/by-uuid/` e também `UUID=` — funcional mas não padronizado
- **2 swap files**: `/swap.img` e `/swap2.img` — ambos 4G. Desnecessário ter dois
- **Partição sda3** (530G) praticamente vazia (1% usado)
- **Sem compressão** nas partições ext4 (não suportado)

---

## 4. Sistema de Arquivos — Nota: 6/10

- **Inodes:** sda2 4% usado, sda3 1% usado — sem preocupação
- **Fragmentação:** não verificável remotamente (e2fsck não executado)
- **Journaling:** ext4 com journal ativo (padrão)
- **Permissões:** razoáveis, sem world-writable suspeitos

---

## 5. Docker — Nota: 3/10

### Containers

| Container | Status | Healthcheck | Restart | Memória | CPU |
|---|---|---|---|---|---|
| homepage | ✅ Up | ✅ healthy | unless-stopped | 80MB | 0% |
| paperless | ✅ Up | ❌ unhealthy (exit 7) | unless-stopped | 66MB | 37% |
| **syncthing** | ❌ **Restarting loop** | ❌ **BROKEN** | unless-stopped | — | — |
| immich-server | ✅ Up | ❌ **unhealthy** | unless-stopped | 148MB | 14% |
| minio | ✅ Up | ❌ nenhum | unless-stopped | 125MB | 9% |
| nextcloud | ✅ Up | ❌ nenhum | unless-stopped | 391MB | 0% |
| postgres-nextcloud | ✅ Up | ❌ nenhum | unless-stopped | 85MB | 5% |
| postgres-immich | ✅ Up | ❌ nenhum | unless-stopped | 12MB | 0% |
| redis-immich | ✅ Up | ❌ nenhum | unless-stopped | 4MB | 1% |
| redis-nextcloud | ✅ Up | ❌ nenhum | unless-stopped | 3MB | 3% |
| ntfy | ✅ Up | ❌ nenhum | unless-stopped | 11MB | 0% |
| uptime-kuma | ✅ Up | ✅ healthy | unless-stopped | 84MB | 2% |
| cloudflared | ✅ Up | ❌ nenhum | unless-stopped | 21MB | 2% |
| **kaos-cloudflared** | ❌ **Exited (137)** | ❌ | unless-stopped | — | — |
| **kaos-blackbox** | ❌ **Exited (0)** | ❌ | unless-stopped | — | — |
| **kaos-node-exporter** | ❌ **Exited (143)** | ❌ | unless-stopped | — | — |
| **kaos-alertmanager** | ❌ **Exited (137)** | ❌ | unless-stopped | — | — |
| **kaos-cadvisor** | ❌ **Exited (0)** | ❌ | unless-stopped | — | — |

### Problemas Críticos do Docker

| Problema | Impacto |
|---|---|
| **Nenhum container tem limits de memória ou CPU** | Um container pode derrubar todo o servidor |
| **Nenhum healthcheck** em postgres, redis, nextcloud, minio, ntfy, cloudflared | Sem detecção de falha |
| **Syncthing completamente quebrado** (cert.pem permission denied) | Serviço inoperante |
| **Immich marcado unhealthy** | Microserviço imich-api com problemas |
| **Paperless unhealthy** (exit 7) | Não responde na porta 8000 |
| **Todos os 8 containers kaos-platform parados** | Monitoramento 100% inoperante |
| **Docker socket exposto** ao homepage (bind mount) | Risco de escalada de privilégios |
| **cadvisor rodou privileged** | Risco de segurança (já parado) |

### Imagens Docker — Desperdício

| Item | Tamanho | Observação |
|---|---|---|
| 8 imagens kaos-api (diferentes SHAs) | ~5.48 GB **cada** | **Apenas 1 necessária** |
| **Total imagens: 36** | **30.39 GB** | **13 GB reclaimable (42%)** |
| **12 volumes órfãos** | **6.894 GB** | **100% reclaimable** |
| ollama/ollama (latest) | 4.77 GB | Container não está rodando |
| open-webui (latest) | 4.99 GB | Container não está rodando |
| n8n (latest) | 1.49 GB | Container não está rodando |
| qdrant/qdrant (latest) | 185 MB | Container não está rodando |

### Orphan Networks Docker
- **12 bridge networks paradas (todas DOWN)** — poluição de rede
- Apenas `br-8c4838e9edff` e `personal-cloud` em uso

---

## 6. Docker Compose — Nota: 4/10

### Problemas nos Compose Files

1. **Sem `healthcheck`** em: postgres-nextcloud, postgres-immich, redis-nextcloud, redis-immich, nextcloud, minio, ntfy, cloudflared
2. **Sem `depends_on`** — containers podem iniciar antes do banco
3. **Sem `security_opt`** — sem perfil de segurança
4. **Sem `cap_drop`** — todas as capabilities Linux mantidas
5. **Sem resource limits** (`deploy.resources.limits`) em nenhum serviço
6. **Sem `read_only`** rootfs — containers têm escrita total
7. **Sem `tmpfs`** para dados temporários
8. **`.env.backup`** armazena **credenciais em plaintext** — AWS keys, MinIO, Restic password
9. **qbittorrent/jellyfin** compose aponta para `/docker/qbittorrent/` — caminho inexistente
10. **Papéis** variáveis de ambiente com `${VAR}` mas .env não fornecido (só .env.backup)
11. **Sem user não-root** — containers rodam como root
12. **immich-server** expõe porta 3001 sem publicar
13. **postgres-dev** expõe porta 5432 publicamente com senha `admroot` — risco grave

---

## 7. Segurança — Nota: 3/10

### SSH
- ✅ PasswordAuthentication desabilitado
- ✅ Apenas chave SSH
- ❌ **X11Forwarding yes** — desnecessário, risco
- ❌ AllowUsers/AllowGroups não configurado

### UFW
- ✅ Ativo, default deny incoming
- ❌ **Muitas portas abertas**: 22, 80, 443, 8080, 8686, 8088, 8585, 8484, 5454, 8282, 81, 50, 90, 51820/udp
- ❌ Muitas portas sem serviço correspondente
- ❌ 51820 (Wireguard) aberto mas wireguard removido

### Fail2Ban
- ✅ Ativo com 2 jails (sshd, nginx-http-auth)
- ❌ **0 bans registrados** — configuração pode não estar efetiva
- ❌ Jail `nginx-http-auth` mas nginx não existe (Nextcloud usa Apache)
- ❌ Sem jail para nextcloud, postgres, apache

### AppArmor
- ✅ Ativo, 126 profiles carregados
- ✅ `docker-default` profile presente
- ❌ Perfil docker-default não é suficiente para hardening

### Credenciais Expostas (CRÍTICO)
| Arquivo | Conteúdo |
|---|---|
| `/srv/personal-cloud/CREDENCIAIS.txt` | Senhas em plaintext |
| `/home/dev/personal-cloud-docker/.env.backup` | `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `RESTIC_PASSWORD` |
| `/home/dev/personal-cloud-docker/*/docker-compose.yml` | Variáveis de ambiente referenciam senhas |
| `/home/dev/postgresql-docker/docker-compose.yml` | Senha postgres `admroot` em plaintext |

### Outros
- ❌ **dev no grupo docker** — acesso root equivalente
- ❌ **dev no grupo sudo** — acesso admin total
- ❌ **github actions runner** rodando sob usuário dev — risco de supply chain
- ❌ **Sem secrets management** (Docker secrets, HashiCorp Vault, etc.)
- ❌ **SUID/SGID** não auditados
- ❌ **ACLs** não verificadas

---

## 8. Performance — Nota: 2/10

### Gargalos Identificados

1. **RAM insuficiente (3.3GB)**
   - Nextcloud: 391MB, Immich: 148MB, MinIO: 125MB, PostgreSQL: 97MB total
   - Sem headroom para picos ou Ollama/Qdrant/n8n/Open WebUI
   - Swap já em uso (247MB) com apenas 4h de uptime

2. **HDD 5400rpm gargalo**
   - iowait chegando a 65%
   - Utilização do disco em 69%
   - 678k load cycles — degradação acelerada

3. **CPU sobrecarregada**
   - Load average 8.47 em 4 cores (sem HT)
   - Apache (Nextcloud): 10+ processos consumindo 2-4% cada
   - Immich-api consumindo 35% CPU

4. **Sem limites de recursos**
   - Containers competem sem controle
   - Um container pode causar OOM no servidor

### Kernel Parameters
- `vm.swappiness = 60` — muito alto (recomendado: 10)
- `vm.dirty_ratio = 10` — aceitável
- `vm.dirty_background_ratio = 5` — aceitável
- `vm.vfs_cache_pressure = 100` — padrão, poderia reduzir
- `net.core.somaxconn = 4096` — OK
- `kernel.pid_max = 4194304` — OK

### HugePages / THP
- HugePages: 0 (não configurado)
- THP: `always [madvise] never` — `madvise` ativo (configuração razoável)

---

## 9. PostgreSQL — Nota: 4/10

| Instância | Versão | Status |
|---|---|---|
| postgres-nextcloud | 17.5 | ✅ Rodando, 85MB |
| postgres-immich | 17.5 | ✅ Rodando, 12MB |
| dev_postgres | 16 | ✅ Rodando, porta 5432 exposta |

### Problemas

- **Sem configuração de tuning** (postgresql.conf não auditado)
- **shared_buffers** não configurado — padrão (128MB provavelmente)
- **effective_cache_size** não configurado
- **work_mem** padrão (4MB) — pode causar disk spills
- **maintenance_work_mem** padrão (64MB)
- **wal_buffers** padrão
- **Sem limites de conexão** — pode exaurir RAM
- **Sem healthcheck** nos containers
- **Sem log de queries lentas** ativado
- **autovacuum** ativo (padrão)
- **dev_postgres exposto na rede** com senha fraca `admroot`

---

## 10. Qdrant — Nota: 1/10

- **Container não está rodando**
- Imagem `qdrant/qdrant:latest` presente (185MB)
- Volume `kaos-platform_qdrant_data` órfão (138MB)
- Serviço indisponível

---

## 11. Nextcloud — Nota: 5/10

- **Versão:** 30.0.6
- **Container rodando:** ✅
- **Healthcheck:** ❌ Nenhum
- **Uptime:** 4h
- **Memória:** 391MB (container)
- **Apache:** 10+ processos (alto consumo de RAM)
- **Cron:** ❌ não verificado (precisa `occ background:cron`)
- **Redis cache:** ✅ configurado (redis-nextcloud)
- **PHP Memory Limit:** 512MB
- **PHP Upload Limit:** 10G
- **Custom apps:** Recognize (TensorFlow.js) — consome CPU e armazenamento
- **Storage:** 2.0GB em /srv/personal-cloud/apps/volumes/nextcloud/files
- **Opcache:** não verificado (precisa acessar o container)

---

## 12. Syncthing — Nota: 1/10

- **Status:** BROKEN — restart loop
- **Erro:** `save cert: open /var/syncthing/config/cert.pem: permission denied`
- **Causa:** Permissão do volume montado incorreta
- **Após 4 tentativas:** desistiu (`not retrying further`)
- **Versão:** 1.28.1 (relativamente recente)

---

## 13. Ollama — Nota: 1/10

- **Container não está rodando**
- **Imagem:** 4.77GB presente
- **Volume:** kaos-platform_ollama_data — 274MB (modelos já baixados?)
- **Sem GPU** — rodaria apenas em CPU (extremamente lento no AMD A8-6410)
- **Serviço indisponível**

---

## 14. n8n — Nota: 1/10

- **Container não está rodando**
- **Imagem:** 1.49GB presente
- **Volume:** kaos-platform_n8n_data — 5.7MB
- **Serviço indisponível**

---

## 15. Grafana — Nota: 1/10

- **Container não está rodando** (kaos-platform parado)
- **Imagem:** grafana/grafana:11.1.0 (2 anos desatualizada)
- **Volume:** kaos-platform_grafana_data — 1MB
- **Serviço indisponível**

---

## 16. Prometheus — Nota: 1/10

- **Container não está rodando**
- **Imagem:** prom/prometheus:v2.54.0 (2 anos)
- **Volume:** kaos-platform_prometheus_data — 153MB
- **Targets:** todos inalcançáveis
- **Serviço indisponível**

---

## 17. Loki — Nota: 1/10

- **Container não está rodando**
- **Imagem:** grafana/loki:3.0.0 (2 anos)
- **Volume:** kaos-platform_loki_data — 921KB
- **Promtail:** imagem presente mas container não roda
- **Serviço indisponível**

---

## 18. Cloudflare — Nota: 6/10

### Cloudflare Tunnel
- ✅ `personal-cloud-cloudflared` rodando (2026.7.0)
- ❌ Sem healthcheck
- ❌ `kaos-platform-cloudflared` parado
- ✅ Usando token (Cloudflare Access)

### Cloudflare DDNS
- ✅ Script em `/opt/cloudflare-ddns/update.sh`
- ❌ **Rodando a cada 5 minutos** (cron `*/5`) — desnecessário, poderia ser a cada 30-60min

### Domínios
- `cloud.kaostech.com.br` — homepage
- `drive.kaostech.com.br` — nextcloud
- `docs.kaostech.com.br` — paperless

### Possíveis Problemas
- TLS/SSL não verificado
- HTTP/3 não verificado
- Cabeçalhos de segurança não verificados

---

## 19. Backups — Nota: 5/10

### Restic Backup
- ✅ Script em `/home/dev/personal-cloud-docker/backup.sh`
- ✅ Backup via cron (2:00 AM diário)
- ✅ Dump PostgreSQL de ambos os bancos
- ✅ Rotação: 7 daily, 4 weekly, 6 monthly
- ✅ Prune ativo
- ✅ Verificação pós-backup (`restic check`)

### Problemas

| Problema | Severidade |
|---|---|
| ❌ **Credenciais AWS/MinIO/Restic em plaintext** em `.env.backup` | CRÍTICA |
| ❌ **Nenhum teste de restore documentado** | ALTA |
| ❌ **Backup depende do MinIO estar rodando** | ALTA |
| ❌ Sem backup de configs Docker (compose, env) no script | MÉDIA |
| ❌ Log de backup em `/srv/personal-cloud/logs/` — sem rotação | MÉDIA |
| ❌ Dumps ficam em `/tmp` — podem ser perdidos no reboot | MÉDIA |
| ❌ Sem criptografia dos dumps antes do envio | MÉDIA |

### Pre-setup-backup
- Backup inicial com `daemon.json`, `fstab`, `containers.json` — boa prática

---

## 20. Logs — Nota: 3/10

- ✅ journald ativo
- ✅ Docker logging configurado (max-size: 10m, max-file: 3)
- ❌ **Loki/Promtail parados** — sem centralização de logs
- ❌ **Logs do kernel** (dmesg) inacessíveis sem root
- ❌ Docker logs json-file em disco (sem rotação externa)
- ❌ Backup logs sem rotação em `/srv/personal-cloud/logs/`
- ❌ Sem rsyslog remoto

---

## 21. Rede — Nota: 5/10

### Interfaces
- `enp1s0` (eth): 192.168.100.31 — rota principal
- `wlp2s0` (wifi): 192.168.100.30 — rota secundária
- ❌ **Duas interfaces na mesma sub-rede** — cria rota duplicada, pode causar problemas

### DNS
- ✅ systemd-resolved ativo (127.0.0.53)
- ✅ DNS local em 127.0.0.54:53

### Network Performance
- `tcp_congestion_control = cubic` (padrão, BBR seria melhor)
- `tcp_rmem / tcp_wmem` — valores padrão (pequenos)
- MTU: 1500 (padrão)
- **12 bridge networks paradas** — poluição

### Wireguard
- ✅ Porta 51820 aberta no UFW
- ❌ `wireguard-tools` removido
- ❌ Volume `wireguard_config` órfão

---

## 22. Monitoramento — Nota: 1/10

**Stack kaos-platform completamente inoperante:**

| Serviço | Status |
|---|---|
| Prometheus | ❌ Parado |
| Grafana | ❌ Parado |
| Loki | ❌ Parado |
| Promtail | ❌ Parado |
| Alertmanager | ❌ Parado |
| Blackbox Exporter | ❌ Parado |
| Node Exporter | ❌ Parado |
| cAdvisor | ❌ Parado |

**Apenas healthchecks do Docker e Uptime Kuma funcionando**

---

## 23. Consumo de Recursos — Ranking

### CPU (instantâneo)
| Processo | %CPU |
|---|---|
| immich (microserviços) | 51% |
| restic backup | 42% |
| immich-api | 35% |
| apache2 (Nextcloud ×10) | 6% cada |
| redis-server | 4% |
| dockerd | 2% |
| cloudflared | 2% |

### RAM
| Container/Processo | RAM |
|---|---|
| nextcloud | 391MB (11.7%) |
| immich-server | 148MB (4.4%) |
| immich-api | 204MB (5.9%) |
| minio | 125MB (3.7%) |
| Apache (×10) | ~100MB cada (3%) |
| postgres-nextcloud | 85MB (2.6%) |
| uptime-kuma | 84MB (2.5%) |
| homepage | 80MB (2.4%) |

### Disco
| Categoria | Tamanho |
|---|---|
| **Imagens Docker** | **30.39 GB** |
| **Volumes Docker (dados)** | **~6.9 GB** |
| Nextcloud files | 2.0 GB |
| Ollama data (volume) | 274 MB |
| Prometheus data | 153 MB |
| Qdrant data | 138 MB |

---

## 24. Atualizações Pendentes

### Docker Images (desatualizadas)

| Imagem | Versão Atual | Lançamento | Tempo |
|---|---|---|---|
| immich-server | v1.130.3 | Mar 2025 | 16 meses |
| paperless-ngx | 2.15.1 | Abr 2025 | 15 meses |
| grafana | 11.1.0 | 2024 | ~2 anos |
| prometheus | v2.54.0 | 2024 | ~2 anos |
| loki | 3.0.0 | 2024 | ~2 anos |
| promtail | 3.0.0 | 2024 | ~2 anos |
| homepage | v1.2.0 | Abr 2025 | ~14 meses |
| ntfy | v2.11.0 | 2024 | ~2 anos |
| uptime-kuma | 1.23.16 | 2024 | ~19 meses |
| syncthing | 1.28.1 | Nov 2024 | ~19 meses |
| Nextcloud | 30.0.6 | 2024 | ~16 meses |
| Redis | 7.4.2 | 2024 | ~18 meses |
| PostgreSQL | 17.5 | 2024 | ~11 meses |
| MinIO | RELEASE.2025-09-07 | Set 2025 | ~10 meses |
| cloudflared | 2026.7.0 | Jul 2026 | Atual |

### Pacotes APT
- `apt list --upgradable` vazio — sistema atualizado
- Smartmontools, restic, curl, jq, dnsutils instalados recentemente

### Kernel
- Versão atual: 6.8.0-134 (atual)
- Kernel antigo: `linux-image-6.8.0-64-generic` ainda instalado

---

## 25. Hardening — Propostas

### Pendências de Hardening

| Item | Status | Ação Proposta |
|---|---|---|
| sysctl hardening | ❌ Não implementado | Aplicar hardening básico |
| AppArmor | ⚠️ Padrão | Criar perfis customizados |
| Docker hardening | ❌ Não implementado | `seccomp`, `cap_drop`, `read_only`, `no-new-privileges` |
| SSH hardening | ⚠️ Parcial | Desativar X11Forwarding, limitar usuários |
| Kernel hardening | ❌ Não implementado | `kernel.kptr_restrict`, `kernel.dmesg_restrict` |
| UFW | ⚠️ Básico | Restringir portas ao necessário |
| Fail2Ban | ⚠️ Inefetivo | 0 bans — revisar configuração |
| Resource limits | ❌ Não implementado | systemd limits, ulimits, Docker limits |
| Secrets management | ❌ Não implementado | Docker secrets / .env seguro |
| Privilégios mínimos | ❌ Não implementado | Containers como não-root |

---

## 26. Limpeza — O Que Pode Ser Removido

### Reclamação Imediata (Recuperação de ~50GB)

| Item | Tamanho | Ação |
|---|---|---|
| 7 imagens kaos-api antigas | ~38 GB | `docker rmi` |
| 12 volumes Docker órfãos | ~6.9 GB | `docker volume rm` |
| ollama/ollama image | 4.77 GB | Remover se não for usar |
| open-webui image | 4.99 GB | Remover se não for usar |
| n8n image | 1.49 GB | Remover se não for usar |
| docker build cache | 0 B | N/A |
| **Potencial recuperação** | **~56 GB** | |

### Imagens kaos-api para remover (manter apenas a latest)
- `kaos-platform-kaos-api:sha-00df1ad` (5.48GB)
- `kaos-platform-kaos-api:sha-1c04713` (5.48GB)
- `kaos-platform-kaos-api:sha-5867a30` (5.48GB)
- `kaos-platform-kaos-api:sha-0fb7e91` (5.48GB)
- `kaos-platform-kaos-api:sha-094afb2` (5.48GB)
- `kaos-platform-kaos-api:sha-87b1835` (5.48GB)
- `kaos-platform-kaos-api:sha-5a68f84` (5.48GB)
- `kaos-platform-kaos-api:sha-bd4cdc4` (5.48GB)

### Outros
- 23 kernels antigos (`rc` state) — `apt purge` (não ocupam muito espaço mas poluem)
- Kernel headers 6.8.0-64 — `apt purge`
- Wireguard config volume — `docker volume rm wireguard_config`
- 12 bridge networks paradas — `docker network prune`
- `CREDENCIAIS.txt` — mover para local seguro ou criptografar

---

## 27. Score Final

| Área | Nota | Justificativa |
|---|---|---|
| **Sistema** | 4/10 | Ubuntu 24.04 atual, mas HDD dying + firmware 2014 |
| **Docker** | 3/10 | Sem limites, healthcheck ausentes, 13GB desperdiçado |
| **Segurança** | 3/10 | Credenciais plaintext, X11 forwarding, portas expostas |
| **Performance** | 2/10 | 3.3GB RAM, HDD 5400rpm, load >8 em 4 cores |
| **Banco** | 4/10 | PG 17.5 rodando, sem tuning, sem healthcheck |
| **Rede** | 5/10 | Funcional, redes órfãs, dual interface confusa |
| **Backups** | 5/10 | Restic configurado, mas creds expostas, sem teste restore |
| **Monitoramento** | 1/10 | Stack kaos-platform 100% parada |
| **Cloud** | 6/10 | Tunnel ativo, DDNS funcional, mas sem healthcheck |
| **Containers** | 3/10 | Múltiplos parados/quebrados, sem boas práticas |
| **Armazenamento** | 2/10 | HDD crítico, 56GB reclaimable |
| **Geral** | **3.5/10** | |

---

# 28. Plano de Implementação

## Prioridade Crítica (Corrigir Imediatamente)

### C1. Syncthing — Permission Denied
- **Impacto:** Serviço de sincronização completamente inoperante
- **Risco:** Perda de sincronização de arquivos
- **Dificuldade:** Baixa
- **Tempo:** 5 min
- **Comando:**
  ```bash
  # Ajustar permissão do volume syncthing
  docker stop syncthing
  sudo chown -R 1000:1000 /srv/personal-cloud/apps/volumes/syncthing/config
  docker start syncthing
  ```
- **Rollback:** `sudo chown -R root:root /srv/personal-cloud/apps/volumes/syncthing/config`
- **Validação:** `docker logs syncthing --tail 5` — deve mostrar "syncthing v1.28.1 ... OK"

### C2. Remover Credenciais em Plaintext
- **Impacto:** Eliminar risco de exposição de AWS/MinIO/Restic credentials
- **Risco:** Se o servidor for comprometido, todas as credenciais são expostas
- **Dificuldade:** Baixa
- **Tempo:** 10 min
- **Comando:**
  ```bash
  # Backup do arquivo original
  sudo cp /srv/personal-cloud/CREDENCIAIS.txt /srv/personal-cloud/CREDENCIAIS.txt.bak
  # Mover para local protegido
  sudo mv /srv/personal-cloud/CREDENCIAIS.txt /home/dev/CREDENCIAIS.txt.gpg
  # Criptografar (se GPG disponível) ou mover para pendrive
  # Proteger .env.backup
  chmod 600 /home/dev/personal-cloud-docker/.env.backup
  ```
- **Rollback:** `sudo mv /home/dev/CREDENCIAIS.txt.gpg /srv/personal-cloud/CREDENCIAIS.txt`
- **Validação:** `ls -la /srv/personal-cloud/CREDENCIAIS.txt` deve retornar "No such file"

### C3. Adicionar Resource Limits nos Containers
- **Impacto:** Evitar OOM, garantir QoS entre serviços
- **Risco:** Algum container pode precisar de mais RAM
- **Dificuldade:** Média
- **Tempo:** 30 min
- **Ação:** Adicionar em todos os docker-compose.yml:
  ```yaml
  deploy:
    resources:
      limits:
        cpus: '0.5'  # ou '1.0' para serviços críticos
        memory: 512M
      reservations:
        memory: 128M
  ```
- **Rollback:** Reverter alterações no compose
- **Validação:** `docker stats --no-stream`

### C4. Remover Desperdício de Disco (Recuperar ~56GB)
- **Impacto:** Liberar mais da metade do espaço em disco
- **Risco:** Baixo (imagens não utilizadas)
- **Dificuldade:** Baixa
- **Tempo:** 15 min
- **Comandos:**
  ```bash
  # Remover volumes órfãos
  sudo docker volume prune -f
  
  # Remover imagens kaos-api antigas (manter apenas latest)
  sudo docker images | grep "kaos-platform-kaos-api" | grep -v "latest" | awk '{print $3}' | xargs sudo docker rmi -f
  
  # Remover imagens não utilizadas
  sudo docker image prune -a -f
  
  # Remover redes não utilizadas
  sudo docker network prune -f
  ```
- **Rollback:** Não aplicável (imagens seriam baixadas novamente)
- **Validação:** `sudo docker system df`

---

## Alta Prioridade

### A1. Restaurar Stack de Monitoramento (kaos-platform)
- **Impacto:** 0 métricas, logs, alertas
- **Risco:** Médio — Sem visibilidade do servidor
- **Dificuldade:** Média
- **Tempo:** 1h
- **Ação:** Identificar por que os containers pararam e restartar
  ```bash
  # Encontrar compose da kaos-platform
  find /home/dev -name "compose*" -path "*kaos*" 2>/dev/null
  # Se não encontrar, reconstruir com docker-compose ou criar novo stack
  ```
- **Rollback:** `docker compose down`

### A2. Adicionar Healthchecks nos Serviços Críticos
- **Impacto:** Detecção automática de falhas
- **Risco:** Baixo
- **Dificuldade:** Baixa
- **Tempo:** 15 min
- **Ação:** Adicionar healthcheck nos docker-compose.yml:
  ```yaml
  healthcheck:
    test: ["CMD", "pg_isready", "-U", "nextcloud"]
    interval: 30s
    timeout: 10s
    retries: 5
    start_period: 30s
  ```

### A3. Configurar noatime nas Partições
- **Impacto:** Reduzir writes no HDD, prolongar vida útil
- **Risco:** Baixo
- **Dificuldade:** Baixa
- **Tempo:** 5 min
- **Comandos:**
  ```bash
  # Backup do fstab
  sudo cp /etc/fstab /etc/fstab.backup.$(date +%Y%m%d)
  # Editar /etc/fstab — adicionar noatime às opções ext4
  # /dev/disk/by-uuid/... / ext4 defaults,noatime 0 1
  # UUID=... /srv/personal-cloud ext4 defaults,noatime,nofail 0 2
  sudo mount -o remount,noatime /
  sudo mount -o remount,noatime /srv/personal-cloud
  ```
- **Rollback:** Restaurar `/etc/fstab.backup`
- **Validação:** `mount | grep noatime`

### A4. Reduzir swappiness para 10
- **Impacto:** Reduzir swap desnecessária, melhorar resposta
- **Risco:** Baixo (com 3.3GB RAM, swap ainda disponível se necessário)
- **Dificuldade:** Baixa
- **Tempo:** 5 min
- **Comando:**
  ```bash
  echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.d/99-swap.conf
  sudo sysctl -p /etc/sysctl.d/99-swap.conf
  ```
- **Rollback:** Remover o arquivo ou reverter
- **Validação:** `sysctl vm.swappiness`

### A5. Desativar X11Forwarding no SSH
- **Impacto:** Eliminar risco de segurança desnecessário
- **Risco:** Baixo (ninguém usa X11 via SSH)
- **Dificuldade:** Baixa
- **Tempo:** 2 min
- **Comandos:**
  ```bash
  sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup.$(date +%Y%m%d)
  sudo sed -i 's/^X11Forwarding yes/X11Forwarding no/' /etc/ssh/sshd_config
  sudo systemctl restart sshd
  ```
- **Rollback:** Restaurar backup
- **Validação:** `grep X11Forwarding /etc/ssh/sshd_config`

### A6. Corrigir Immich Healthcheck
- **Impacto:** Microserviço immich-api com problemas
- **Risco:** Médio — Pode indicar problema real
- **Dificuldade:** Média
- **Tempo:** 30 min
- **Ação:** Verificar logs do immich-api:
  ```bash
  sudo docker logs immich-server
  sudo docker logs immich-microservices
  restart: Restartar container
  ```

---

## Média Prioridade

### M1. Limpar Kernels Antigos
```bash
sudo apt purge linux-image-6.8.0-64-generic linux-headers-6.8.0-64 linux-headers-6.8.0-64-generic
sudo apt autoremove --purge
```

### M2. Consolidar Swap Files em Um
```bash
sudo swapoff /swap2.img
sudo rm /swap2.img
# Remover linha do fstab
```

### M3. Limpar Redes Docker Órfãs
```bash
sudo docker network prune -f
```

### M4. Atualizar Imagens Docker Desatualizadas
- Próximas imagens a atualizar (prioridade):
  1. grafana/grafana: latest (2 anos defasada)
  2. prom/prometheus: latest
  3. grafana/loki: latest
  4. nextcloud: stable
  5. immich-server e immich-microservices: v1.130.x → mais recente

### M5. Configurar UFW com Portas Mínimas
- Remover regras para portas sem serviço: 50, 90, 81, 8282, 5454, 8088, 8585, 8484
- Manter apenas: 22 (SSH), 80, 443 (Cloudflare tunnel)
- Se Wireguard não for usado, remover 51820

### M6. Configurar Log Rotation para Docker
```bash
# /etc/docker/daemon.json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
```

### M7. Configurar TCP BBR
```bash
echo "net.core.default_qdisc=fq" | sudo tee -a /etc/sysctl.d/99-bbr.conf
echo "net.ipv4.tcp_congestion_control=bbr" | sudo tee -a /etc/sysctl.d/99-bbr.conf
sudo sysctl -p /etc/sysctl.d/99-bbr.conf
```

### M8. Adicionar `depends_on` nos Compose Files
```yaml
depends_on:
  postgres-nextcloud:
    condition: service_healthy
  redis-nextcloud:
    condition: service_healthy
```

### M9. Corrigir Fail2Ban Jails
- Adicionar jail para Apache (Nextcloud)
- Corrigir jail do nginx (Nextcloud usa Apache)
  ```bash
  sudo fail2ban-client set apache-auth addjail
  ```

### M10. Parar Cloudflare DDNS (muito frequente)
- Alterar cron de `*/5` para `*/30` ou `0 *` * * *

---

## Baixa Prioridade

### B1. Atualizar Firmware da BIOS
- **Risco:** Requer reboot físico
- **Nota:** BIOS 1.30 de 2014 — Toshiba não fornece mais atualizações para este modelo

### B2. Instalar hddtemp
```bash
sudo apt install hddtemp
```

### B3. Configurar Backups Criptografados
- Migrar .env.backup para Docker secrets
- Testar restore: `restic restore latest --target /tmp/test-restore`

### B4. Configurar Kernel Hardening
```bash
# /etc/sysctl.d/99-security.conf
kernel.kptr_restrict=2
kernel.dmesg_restrict=1
kernel.perf_event_paranoid=3
kernel.randomize_va_space=2
fs.suid_dumpable=0
net.ipv4.conf.all.log_martians=1
net.ipv4.icmp_echo_ignore_broadcasts=1
```

### B5. Consolidar Docker Compose em Um Único Projeto
- Atualmente: 7 compose files separados em subpastas
- Benefício: Gerenciamento centralizado, dependências entre serviços

### B6. Configurar AppArmor para Docker
```bash
# /etc/apparmor.d/docker-custom
# Perfil customizado para containers
```

### B7. Teste de Restore dos Backups
```bash
# Listar snapshots
sudo docker exec minio mc ls minio/backups
# Testar restore em diretório temporário
restic restore latest --target /tmp/test-restore
```

### B8. Adicionar Monitoramento Básico (Substituto kaos-platform)
- netdata (leve, 100MB RAM) como alternativa ao Prometheus/Grafana
- Ou configurar healthchecks via Uptime Kuma + webhooks no ntfy

### B9. Configurar ZRAM (para compensar pouca RAM)
```bash
sudo apt install zram-tools
# /etc/default/zramswap
PERCENT=50
# Aumenta memória efetiva em ~1.6GB
```

---

## Recomendações Finais

### Curto Prazo (hoje)
1. ✅ Corrigir Syncthing (C1)
2. ✅ Remover credenciais expostas (C2)
3. ✅ Adicionar resource limits (C3)
4. ✅ Limpar desperdício de disco (C4)
5. ✅ Desativar X11Forwarding (A5)

### Médio Prazo (1-2 semanas)
1. Restaurar monitoramento (A1)
2. Corrigir healthchecks (A2)
3. Configurar noatime (A3)
4. Reduzir swappiness (A4)
5. Consolidar compose files (B5)

### Longo Prazo (1-3 meses)
1. **Substituir hardware** — SSD + 8GB+ RAM ou VPS na nuvem
2. Atualizar imagens Docker
3. Implementar secrets management
4. Teste de restore dos backups

### Hardware Upgrade Recomendado
Dado que este é um **laptop de 2014 com 3.3GB RAM e HDD 5400rpm** executando 18 containers com Nextcloud, Immich, Paperless e potencialmente Ollama/Qdrant/n8n/Open WebUI:

**Mínimo viável:** SSD SATA 1TB + 8GB RAM (se o laptop suportar)
**Ideal:** Migrar para VPS (4 vCPU, 8GB RAM, SSD NVMe) ou mini PC (Intel N100, 16GB RAM, NVMe)
**Custo-benefício:** Mini PC ~$150-200 ou Hetzner VPS ~€8/mês

---

*Relatório gerado automaticamente em 2026-07-13 20:00 BRT*
