# Auditoria Completa — Personal Cloud & Backup

> **Data:** 2026-07-13
> **Projeto:** Personal Cloud & Backup
> **Repositório:** `C:\workspace\Extras\personal-cloud-backup`
> **Servidor:** ubunto (192.168.100.30) — Ubuntu 24.04.4 LTS
> **Domínio:** kaostech.com.br
> **Cloudflare Tunnel:** cloud (ID: ea6f317b-...)
> **Autor:** Auditoria automatizada via MCP

---

## FASE 1 — INVENTÁRIO

### 1.1 Repositório Local (Git)

| Item | Caminho | Objetivo | Status | Maturidade | Dependências | Riscos |
|------|---------|----------|--------|------------|--------------|--------|
| PLANO_COMPLETO.md | `./PLANO_COMPLETO.md` | Plano de implementação v3.0 | ✅ Redigido | Rascunho | Nenhum | Desatualizado vs servidor real |
| README.md | `./README.md` | Documentação inicial | ✅ Redigido | Rascunho | Nenhum | Menciona serviços offline como ativos, cita scripts que não existem |
| ARCHITECTURE.md | `./ARCHITECTURE.md` | Diagrama de arquitetura | ✅ Redigido | Rascunho | Nenhum | Menciona proxy reverso (não implementado), monitoramento (não implementado) |
| ROADMAP.md | `./ROADMAP.md` | Roadmap de 3 fases | ✅ Redigido | Rascunho | Nenhum | Nada foi marcado como concluído |
| CHANGELOG.md | `./CHANGELOG.md` | Registro de versões | ✅ Redigido | v0.1.0 | Nenhum | Apenas 1 entrada |
| EXPANSION.md | `./EXPANSION.md` | Cenários de crescimento | ✅ Redigido | Rascunho | Nenhum | Nada implementado do que descreve |
| POWER.md | `./POWER.md` | Plano pós-queda de energia | ✅ Redigido | Rascunho | Nenhum | UPS não implementada, NUT não configurado |
| .gitignore | `./.gitignore` | Regras de git | ✅ Completo | Estável | Nenhum | OK |
| .editorconfig | `./.editorconfig` | Padrões de edição | ✅ Completo | Estável | Nenhum | OK |

### 1.2 ADRs (Architecture Decision Records)

| ADR | Título | Status Real | Conteúdo |
|-----|--------|------------|----------|
| 0001 | Storage Layout | ✅ Decidido | Partição sda3 ext4 montada em /srv/personal-cloud |
| 0002 | Network Architecture | ✅ Decidido | Subnet 172.31.0.0/24 |
| 0003 | Volume Strategy | ✅ Decidido | Bind mounts em /srv/personal-cloud/apps/volumes/ |
| 0004 | Docker Structure | ✅ Decidido | Stacks separadas por serviço |
| 0005 | Cloudflare Tunnel | ✅ Decidido | Container dedicado, token próprio |
| 0006 | Backup Strategy | ✅ Decidido | Restic + MinIO + pg_dump |
| 0007 | (Proxy Reverse) | 🔴 Pendente | Pesquisa não realizada |
| 0008 | (Dashboard Choice) | 🔴 Pendente | Homepage já escolhido mas ADR não escrito |
| 0009 | (Notification Layer) | 🔴 Pendente | ntfy deployado mas ADR não escrito |
| 0010 | (Technology Selection) | 🔴 Pendente | Não escrito |

### 1.3 Docker Stacks (Repositório)

| Stack | Caminho | Objetivo | Status | Imagens | Riscos |
|-------|---------|----------|--------|---------|--------|
| foundation | `docker/stacks/foundation/` | ntfy + Homepage + Uptime Kuma | ✅ Redigido | Versões fixas | Baixo |
| databases | `docker/stacks/databases/` | PostgreSQL + Redis (Nextcloud + Immich) | ✅ Redigido | Postgres 17.5, Redis 7.4.2 | Baixo |
| nextcloud | `docker/stacks/nextcloud/` | Cloud pessoal | ✅ Redigido | Nextcloud 30.0.6 | Baixo |
| immich | `docker/stacks/immich/` | Fotos e vídeos | ✅ Redigido | Immich v1.130.3 | ML desabilitado, sem microserviços |
| minio | `docker/stacks/minio/` | Object storage S3 | ✅ Redigido | MinIO RELEASE.2025-09-07 | Buckets não definidos no compose |
| paperless | `docker/stacks/paperless/` | Documentos com OCR | ⚠️ Incompleto | Paperless 2.15.1 | **Faltam Tika + Gotenberg** (serviços obrigatórios para OCR) |
| syncthing | `docker/stacks/syncthing/` | Sincronia de dispositivos | ✅ Redigido | Syncthing 1.28.1 | Baixo |
| cloudflared-personal | `docker/stacks/cloudflared-personal/` | Cloudflare Tunnel | ✅ Redigido | cloudflared 2026.7.0 | Token no .env (segurança OK) |
| **monitoring** | 🔴 **Não existe** | Prometheus + Loki + Grafana | 🔴 Ausente | — | Sem observabilidade |
| **reverse-proxy** | 🔴 **Não existe** | NPM / Traefik / Caddy | 🔴 Ausente | — | Cloudflare Tunnel faz proxy direto |

### 1.4 Docker Stacks (Servidor Real em /home/dev/personal-cloud-docker/)

| Stack | Status no Docker | Portas | Observações |
|-------|-----------------|--------|-------------|
| foundation | ✅ Running (3 containers) | — | ntfy:80, homepage:3000, uptime-kuma:3001 |
| databases | ✅ Running (4 containers) | — | postgres-nextcloud:5432, postgres-immich:5432, redis-x2:6379 |
| nextcloud | ✅ Running | 80 | Conectado a postgres-nextcloud + redis-nextcloud |
| immich | ✅ Running (desde 13/07) | 2283 | ML desabilitado. Retornando 502 via Cloudflare |
| minio | ✅ Running | 9000 | Bucket `backups` criado. IP: 172.31.0.2 |
| paperless | ✅ Running (desde 13/07) | 8000 | Retornando 502 via Cloudflare |
| syncthing | 🔄 Restarting | 8384, 22000, 21027 | Em estado de restart |
| cloudflared-personal | ✅ Running | — | Tunnel saudável (4 conexões QUIC) |

### 1.5 Documentação

| Documento | Objetivo | Status | Observações |
|-----------|----------|--------|-------------|
| `docs/02-AUDITORIA-SERVIDOR.md` | Auditoria inicial do servidor | ✅ Completo | Dados corretos na data |
| `docs/03-INVENTORY.md` | Inventário do servidor | ✅ Completo | Desatualizado (Immich/Paperless agora running) |
| `docs/.gitkeep` | Placeholder | ✅ | Vazio |
| `inventory/README.md` | Descrição do sistema de inventory | ✅ Redigido | Script `generate-inventory.sh` não existe |
| `docker/shared/README.md` | Regras Docker compartilhadas | ✅ Redigido | Rede externa definida |

### 1.6 Configurações do OpenCode

| Item | Caminho | Status |
|------|---------|--------|
| opencode.json | `.opencode/opencode.json` | ✅ Configurado com MCPs |
| .gitignore | `.opencode/.gitignore` | ✅ OK |

### 1.7 Itens Planejados que NÃO Existem

| Item Planejado | Status | Observação |
|----------------|--------|-------------|
| `scripts/` diretório | 🔴 **Não existe** | Nenhum script (.sh) no repositório |
| `tests/` diretório | 🔴 **Não existe** | Nenhum teste implementado |
| `notification/` diretório | 🔴 **Não existe** | Layer de notificação não implementada |
| `configs/` diretório | 🔴 **Não existe** | Configs não versionadas |
| `benchmarks/` diretório | 🔴 **Não existe** | Nenhum benchmark |
| `logs/` diretório | 🔴 **Não existe** | (gitignored) |
| `scripts/setup.sh` | 🔴 **Não existe** | README referencia como `sudo ./scripts/setup.sh` |
| `scripts/backup-bancos.sh` | 🔴 **Não existe** | Pipeline de backup não implementado |
| `scripts/snapshot.sh` | 🔴 **Não existe** | Snapshots não implementados |
| `scripts/generate-inventory.sh` | 🔴 **Não existe** | inventory/README.md referencia |
| `tests/backup/test-restore.sh` | 🔴 **Não existe** | Testes de restore não existem |
| `tests/network/test-ports.sh` | 🔴 **Não existe** | Testes de rede não existem |
| `tests/network/test-ssl.sh` | 🔴 **Não existe** | Testes SSL não existem |
| `tests/security/test-hardening.sh` | 🔴 **Não existe** | Testes de hardening não existem |
| `tests/performance/test-benchmark.sh` | 🔴 **Não existe** | Testes de performance não existem |
| `notify.sh` | 🔴 **Não existe** | Script central de notificação não implementado |

---

## FASE 2 — FEATURES

### Tabela de Funcionalidades

| Funcionalidade | Status | Evidência |
|----------------|--------|-----------|
| **Homepage Dashboard** | ✅ Completa | cloud.kaostech.com.br responde 200, serviços.yaml configurado |
| **Cloudflare Tunnel** | ✅ Completa | 4 conexões QUIC ativas, DNS configurado |
| **Nextcloud** | ✅ Completa | drive.kaostech.com.br responde 302 (redirect to login) |
| **MinIO Object Storage** | ✅ Completa | storage.kaostech.com.br responde 200, bucket backups criado |
| **ntfy Notificações** | ✅ Completa | notify.kaostech.com.br responde 200 |
| **Uptime Kuma** | ✅ Completa | status.kaostech.com.br responde 302 |
| **PostgreSQL** | ✅ Completa | 2 instâncias running (nextcloud + immich) |
| **Redis** | ✅ Completa | 2 instâncias running (nextcloud + immich) |
| **Cloudflare DNS + Proxy** | ✅ Completa | 7 subdomínios configurados |
| **Tags de imagem fixas** | ✅ Completa | Nenhum `:latest` nos containers ativos |
| **Docker network dedicada** | ✅ Completa | `personal-cloud` bridge, 172.31.0.0/24 |
| **Logging configurado** | ✅ Completa | Todos containers com max-size 10m, max-file 3 |
| **Immich** | 🟡 Parcial | Running mas 502 via Cloudflare. ML desabilitado. Sem microserviços |
| **Paperless-ngx** | 🟡 Parcial | Running mas 502 via Cloudflare. **Sem Tika + Gotenberg** (sem OCR) |
| **Syncthing** | 🟡 Parcial | Container restartando. Portas GUI internas. Sem dispositivo configurado |
| **Restic Backup** | 🟡 Parcial | Repositório existe no MinIO mas **credentials no backup.sh não funcionam** (Access Denied) |
| **Fail2Ban** | 🟡 Parcial | Serviço running, mas **não é possível verificar jails** sem sudo |
| **Firewall (UFW)** | 🔴 Ausente | docs/02 fala "UFW NÃO ATIVO", não foi possível confirmar via SSH |
| **Proxy Reverso** | 🔴 Ausente | NPM/Traefik/Caddy não existem no servidor |
| **Grafana** | 🔴 Ausente | Não instalado |
| **Prometheus** | 🔴 Ausente | Não instalado |
| **Loki + Promtail** | 🔴 Ausente | Não instalado |
| **Alertas** | 🔴 Ausente | Alertmanager não existe |
| **Telegram Bot** | 🔴 Ausente | Mencionado no plano mas não implementado |
| **Backup Automático via Cron** | 🟡 Parcial | Cron configurado para 02:00 mas **backup.sh nunca executou** (sem logs, sem dumps em /tmp) |
| **Backup de Banco (pg_dump)** | 🟡 Parcial | Script existe mas nunca gerou dumps |
| **Snapshots pré-upgrade** | 🔴 Ausente | Nenhum snapshot realizado |
| **Restore Testes** | 🔴 Ausente | Nenhum teste de restore |
| **SSH Key Only** | 🟡 Parcial | Config padrão (PasswordAuthentication comentado = yes por default) |
| **Docker Security (read_only)** | 🔴 Ausente | Nenhum container usa `read_only` |
| **Secrets (.env 600)** | 🟡 Parcial | .env files existem no servidor, permissão não verificada |
| **Certificates Let's Encrypt** | 🔴 Ausente | Cloudflare Tunnel provê SSL automático |
| **Homepage Docker Integration** | ✅ Completa | Docker socket montado, serviços.yaml configurado |
| **Notificações Push** | 🟡 Parcial | ntfy deployado mas **nenhum serviço configurado para usar ntfy** |
| **Multiusuário** | 🔴 Ausente | Apenas admin do Nextcloud. Sem SSO, LDAP, MFA |
| **WireGuard** | 🔴 Ausente | Plano menciona porta 51820 mas não implementado |
| **UPS / Nobreak** | 🔴 Ausente | Mencionado no POWER.md, não implementado |
| **Backup Externo** | 🔴 Ausente | Mencionado no EXPANSION.md, não implementado |
| **Benchmark (fio, iperf3)** | 🔴 Ausente | Ferramentas nem instaladas |

---

## FASE 3 — COMPARAÇÃO (vs Concorrentes)

### CasaOS / Umbrel / TrueNAS / YunoHost / Cloudron / Coolify

| Funcionalidade | Este Projeto | CasaOS | Umbrel | TrueNAS | YunoHost | Cloudron | Coolify |
|----------------|-------------|--------|--------|---------|----------|----------|---------|
| **App Store / 1-click install** | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Dashboard integrado** | ✅ (Homepage) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Observabilidade nativa** | ❌ | ❌ | ❌ | ✅ (TrueCommand) | ❌ | ✅ (Grafana) | ❌ |
| **Backup integrado** | 🟡 (parcial) | 🟡 | ❌ | ✅ (ZFS snapshots) | 🟡 | ✅ (integrado) | ✅ (automático) |
| **Restore com 1 clique** | ❌ | ❌ | ❌ | ✅ | ❌ | ✅ | ✅ |
| **Multiusuário nativo** | ❌ | ❌ | ❌ | ✅ | ✅ | ✅ | ✅ |
| **SSO / LDAP** | ❌ | ❌ | ❌ | ✅ | ✅ | ✅ | 🟡 |
| **MFA / 2FA** | ❌ | ❌ | ❌ | ✅ | 🟡 | ✅ | ❌ |
| **Mobile App** | ❌ | ✅ | ✅ | ✅ | ❌ | ✅ | ❌ |
| **Domínio próprio** | ✅ | 🟡 | 🟡 | ✅ | ✅ | ✅ | ✅ |
| **SSL automático** | ✅ (Cloudflare) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Proxy reverso nativo** | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Firewall integrado** | ❌ | ❌ | ❌ | ✅ | 🟡 | ❌ | ❌ |
| **Atualizações 1-click** | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Marketplace de apps** | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ | 🟡 |
| **Sistema de arquivos avançado** | ❌ | ❌ | ❌ | ✅ (ZFS) | ❌ | ❌ | ❌ |
| **Auditoria de segurança** | ❌ | ❌ | ❌ | ✅ | 🟡 | 🟡 | ❌ |

### O que outros têm que falta aqui:

| Funcionalidade | Importância | Concorrentes que têm |
|---------------|------------|---------------------|
| **App Store / Easy Install** | Alta | Todos exceto este |
| **Atualizações automáticas com 1 clique** | Alta | CasaOS, Umbrel, TrueNAS, Cloudron |
| **Multiusuário com permissões granulares** | Alta | TrueNAS, YunoHost, Cloudron |
| **Backup de sistema completo com restore** | Alta | TrueNAS, Cloudron, Coolify |
| **SSO / Autenticação centralizada** | Média | TrueNAS, YunoHost, Cloudron |
| **Interface mobile responsiva** | Média | CasaOS, Umbrel, TrueNAS, Cloudron |
| **ZFS / Snapshots nativos** | Média | TrueNAS |
| **Notificações integradas** | Média | Todos |
| **Marketplace / Comunidade** | Média | CasaOS, Umbrel, TrueNAS |

---

## FASE 4 — DOCUMENTAÇÃO

### O que está documentado

| Documento | Cobertura | Qualidade |
|-----------|-----------|-----------|
| PLANO_COMPLETO.md | Arquitetura geral, redes, stacks, backup, segurança | ⭐⭐⭐ Bom, mas desatualizado |
| ARCHITECTURE.md | Diagrama de rede, stack tecnológica | ⭐⭐⭐ Claro e objetivo |
| README.md | Quick start, tabela de serviços | ⭐⭐ Mínimo |
| ROADMAP.md | 3 fases com checklist | ⭐⭐ Sem datas, sem prioridades |
| POWER.md | Comportamento pós-energia, checklist | ⭐⭐ Bom, mas UPS não implementada |
| EXPANSION.md | Cenários de crescimento | ⭐⭐ Rascunho, sem procedimentos |
| ADR/ | Decisões de arquitetura | ⭐⭐⭐ Boas decisões documentadas (6/10) |
| docs/02-AUDITORIA-SERVIDOR.md | Hardware, Docker, Rede, Firewall | ⭐⭐⭐⭐ Excelente |
| docs/03-INVENTORY.md | Inventário completo do servidor | ⭐⭐⭐⭐ Excelente (parcialmente desatualizado) |
| docker/shared/README.md | Regras Docker | ⭐ Mínimo |
| inventory/README.md | Descrição do inventory | ⭐⭐ OK, mas script não existe |
| CHANGELOG.md | Histórico de versões | ⭐ Apenas 1 entrada |

### O que NÃO está documentado

| O que falta | Impacto |
|-------------|---------|
| **Procedimento de deploy** (como subir cada stack) | Crítico — sem script setup.sh, ninguém reproduz |
| **Procedimento de restore** | Crítico — sem docs de DR, dados podem ser perdidos |
| **Playbook de manutenção** | Importante — sem instruções de updates |
| **Diagrama de rede atualizado** | Importante — ARCHITECTURE.md menciona proxy reverso que não existe |
| **Inventário de secrets** (quais .env necessários) | Importante —新人 não sabe o que configurar |
| **Guia de monitoramento** (o que observar) | Desejável |
| **Guia de troubleshooting** | Desejável |
| **Política de segurança** (senhas, acesso, rotação) | Importante |
| **Matriz de responsabilidade** (quem faz o quê) | Opcional |
| **SLA / RPO / RTO documentados** | Importante — sem métricas de backup |

---

## FASE 5 — UX (Experiência do Usuário)

### Homepage (cloud.kaostech.com.br)

- ✅ Acessível via Cloudflare Tunnel (SSL/TLS 1.3)
- ✅ Responde 200
- ✅ Serviços.yaml configurado com ícones e links
- ✅ Docker socket integrado (status dos containers)
- ⚠️ Immich e Paperless marcados como "offline" (desatualizado)
- ❌ Sem search bar (Homepage não tem nativamente)
- ❌ Não há categorias visuais (apenas grupos de texto)

### Navegação

| Aspecto | Avaliação |
|---------|-----------|
| **Descoberta de serviços** | 🟡 Precisa saber os subdomínios ou usar Homepage |
| **Links diretos** | ✅ Todos serviços têm subdomínio próprio |
| **Mobile** | 🟡 Cloudflare Tunnel funciona, Homepage tem layout responsivo parcial |
| **Desktop** | ✅ Funcional |
| **Tempo de carregamento** | 🟡 HD 5400RPM + Cloudflare Tunnel adiciona latência |
| **TLS/SSL** | ✅ Automático via Cloudflare |
| **Página de erro** | ❌ Cloudflare retorna páginas genéricas (502, 530) |

### Mobile

- Homepage é parcialmente responsiva
- Sem PWA (Progressive Web App)
- Sem apps mobile nativos (Nextcloud tem app, Immich tem app, mas Paperless não)
- Uptime Kuma tem mobile OK

### Desktop

- Navegação via subdomínios funciona bem
- Homepage serve como bom ponto de partida
- Falta autenticação centralizada (cada serviço tem login próprio)

---

## FASE 6 — MULTIUSUÁRIO

### Situação Atual

| Aspecto | Status | Detalhes |
|---------|--------|----------|
| **Usuários do sistema** | 🔴 | Apenas admin local (dev) + root. Usuário dedicado `personal-cloud` não criado |
| **Usuários Nextcloud** | 🟡 | Admin único configurado (admin/CloudBackup2026!). Sem usuários adicionais |
| **Usuários Immich** | 🔴 | Não configurado (502) |
| **Usuários Paperless** | 🔴 | Não configurado (502) |
| **SSO / AutentCentralizada** | 🔴 | Cada serviço com login próprio |
| **LDAP / OAuth / OIDC** | 🔴 | Não implementado |
| **MFA / 2FA** | 🔴 | Não disponível em nenhum serviço |
| **Compartilhamento de arquivos** | 🟡 | Nextcloud permite compartilhamento interno |
| **Permissões granulares** | 🔴 | Apenas admin/não-admin |
| **Convidados (links públicos)** | 🟡 | Nextcloud suporta, não configurado |
| **Quotas de armazenamento** | 🔴 | Não configuradas |

### Recomendação

A falta de multiusuário é aceitável para um projeto pessoal, mas se houver planos de compartilhar com família, é essencial implementar Authelia/Authentik + LDAP.

---

## FASE 7 — SEGURANÇA

### Mapeamento Completo

| Aspecto | Status | Evidência | Risco |
|---------|--------|-----------|-------|
| **HTTPS** | ✅ | Cloudflare Tunnel provê SSL automático (TLS 1.3) | Baixo |
| **Cloudflare Proxy (DDoS)** | ✅ | Proxy habilitado, IP real oculto | Baixo |
| **Cloudflare Tunnel (Zero Trust)** | ✅ | Nenhuma porta exposta além de 22 | Baixo |
| **Firewall (UFW)** | 🔴 | docs/02 diz "NÃO ATIVO". Não confirmado via SSH | **Crítico** |
| **SSH Password Auth** | 🔴 | Config padrão: PasswordAuthentication comentado (= yes) | **Crítico** |
| **SSH Porta padrão (22)** | 🟡 | Porta 22, não alterada | Médio |
| **Fail2Ban** | 🟡 | Serviço running (systemctl). Não é possível verificar jails sem sudo | Médio |
| **Docker socket exposto** | 🟡 | Homepage monta /var/run/docker.sock:ro | Médio (read-only) |
| **Secrets em .env** | 🟡 | .env files existem com senhas em texto plano | Médio |
| **Secrets HARDCODED no script** | 🔴 | backup.sh tem AWS_ACCESS_KEY, AWS_SECRET, RESTIC_PASSWORD em texto plano | **Crítico** |
| **Docker read_only containers** | 🔴 | Nenhum container usa `read_only: true` | Médio |
| **Docker non-root users** | 🔴 | Containers rodam como root/default | Médio |
| **Imagens com versão fixa** | ✅ | Nenhuma imagem `:latest` | Baixo |
| **Restic criptografia** | 🟡 | Repositório existe mas password não é gerenciado com segurança | Alto |
| **Cloudflare Tunnel token** | 🟡 | Token em .env file,mas válido | Médio |
| **Auditoria de acesso** | 🔴 | Nenhum log de acesso auditado | Médio |
| **Atualizações de segurança** | 🟡 | unattended-upgrades ativo (systemd) | Baixo |
| **Snap packages** | 🟡 | snapd + canonical-livepatch ativos | Baixo |

### Ataques Possíveis no Estado Atual

1. **Força bruta SSH** se PasswordAuthentication estiver ativo (Porta 22 aberta)
2. **Vazamento de secrets** pelo backup.sh versionado (se repo for público)
3. **Acesso ao MinIO** via credenciais hardcoded no backup.sh
4. **Container escape** via Docker socket (homepage tem acesso read-only, risco reduzido)
5. **Sem隔离 de rede** entre stacks (todas na mesma bridge)

---

## FASE 8 — BACKUP

### Situação Real

| Componente | Status | Detalhes |
|------------|--------|----------|
| **Restic instalado** | ✅ | v0.16.4 |
| **Restic repo no MinIO** | ✅ | Bucket `backups` existe com estrutura restic (config, data, index, keys, snapshots) |
| **Credenciais Restic** | 🔴 | **Access Denied** ao tentar acessar repo com credenciais do backup.sh |
| **backup.sh script** | 🟡 | Existe em /home/dev/personal-cloud-docker/ (fora do repo) |
| **backup.sh - MinIO IP** | 🔴 | **Erro grave**: IP 172.31.0.11, mas MinIO está em 172.31.0.2 |
| **backup.sh - secrets** | 🔴 | **CRÍTICO**: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, RESTIC_PASSWORD hardcoded |
| **backup.sh - pg_dump paperless** | 🟡 | Tenta dump do banco `paperless` via postgres-nextcloud (funciona? depende) |
| **Cron configurado** | ✅ | `0 2 * * * /home/dev/personal-cloud-docker/backup.sh` |
| **Cron já executou** | 🔴 | **Nunca executou**: sem logs em /srv/personal-cloud/logs/, sem dumps em /tmp/ |
| **Snapshots pré-upgrade** | 🔴 | Não implementado |
| **Restic forget/prune** | 🟡 | Configurado: 7 daily, 4 weekly, 6 monthly |
| **Restic check** | 🔴 | Não executado (repo inacessível) |
| **Backup externo** | 🔴 | Não implementado (mencionado em EXPANSION.md) |
| **sda3 montado** | 🔴 | **Dados estão em sda2 (root, 400GB)**. sda3 (530GB) com fstab mas **não montado** |
| **/srv/personal-cloud/backups/** | 🔴 | Diretório não existe |
| **/srv/personal-cloud/config/** | 🔴 | Diretório não existe |

### Pipeline Real (backup.sh)

```
postgres-nextcloud → pg_dump -U nextcloud -Fc nextcloud → /tmp/nextcloud-<DATE>.dump
postgres-immich    → pg_dump -U immich -Fc immich       → /tmp/immich-<DATE>.dump
postgres-nextcloud → pg_dump -U nextcloud -Fc paperless  → /tmp/paperless-<DATE>.dump (2>/dev/null)
     ↓
restic backup --tag nextcloud-<DATE>  /srv/personal-cloud/apps/volumes/nextcloud
restic backup --tag immich-<DATE>     /srv/personal-cloud/apps/volumes/immich
restic backup --tag postgres-<DATE>   /tmp/*.dump
restic backup --tag config-<DATE>     /srv/personal-cloud/config/  ← NÃO EXISTE
restic backup --tag system-<DATE>     /etc/fstab /etc/docker/ /home/dev/personal-cloud-docker/
     ↓
restic forget --keep-daily 7 --keep-weekly 4 --keep-monthly 6 --prune
restic check --no-lock
find /tmp -name "*.dump" -mtime +7 -delete
```

### Problemas Graves no Pipeline

1. **backup.sh referencia MinIO IP errado** (172.31.0.11 → real 172.31.0.2) — falharia imediatamente
2. **backup.sh contém secrets em texto plano** — se repo for público, dados expostos
3. **backup.sh referencia `/srv/personal-cloud/config/` que não existe** — falharia silenciosamente
4. **Nunca foi testado** — sem logs, sem dumps
5. **sda3 (530GB) não está montado** — dados ocupam espaço da partição root (67G/393G)
6. **Sem backup externo** — desastre físico = perda total

---

## FASE 9 — OBSERVABILIDADE

### Situação Atual

| Componente | Status | Detalhes |
|------------|--------|----------|
| **Grafana** | 🔴 | Não instalado. Nenhum dashboard |
| **Prometheus** | 🔴 | Não instalado. Nenhuma métrica coletada |
| **Loki** | 🔴 | Não instalado. Nenhum log centralizado |
| **Promtail** | 🔴 | Não instalado |
| **Alertmanager** | 🔴 | Não instalado |
| **Node Exporter** | 🔴 | Não instalado |
| **cAdvisor** | 🔴 | Não instalado |
| **Blackbox Exporter** | 🔴 | Não instalado |
| **Uptime Kuma** | ✅ | status.kaostech.com.br, health checks externos |
| **Docker logs** | 🟡 | Apenas json-file local (max 10MB x 3 por container) |
| **systemd journal** | 🟡 | Logs do sistema disponíveis localmente |
| **Notificações de eventos** | 🔴 | Nenhum canal configurado (ntfy existe mas não é usado) |

### O que falta vs plano

O PLANO_COMPLETO.md e ARCHITECTURE.md prometem:
- Prometheus + Loki + Promtail + Grafana
- Uptime Kuma
- Alertas
- Notificações (ntfy + Telegram + SMTP)

**Realidade:** Apenas Uptime Kuma + ntfy estão instalados. Nada de monitoramento real.

---

## FASE 10 — AUTOMAÇÕES

### Situação Atual

| Automação | Status | Detalhes |
|-----------|--------|----------|
| **Cron: backup.sh** | 🟡 | Configurado em crontab do dev, mas nunca executou |
| **Cron: Cloudflare DDNS** | ✅ | `/opt/cloudflare-ddns/update.sh` a cada 5 min |
| **Cron: system (anacron)** | ✅ | Diário, semanal, mensal (default Ubuntu) |
| **Unattended Upgrades** | ✅ | Ativo (systemd) |
| **Renovação de certificados** | 🔴 | Cloudflare Tunnel gerencia SSL, mas certbot existe no cron.d |
| **Health checks automáticos** | 🔴 | Não implementados (Uptime Kuma faz externo, mas não local) |
| **Notificações automáticas** | 🔴 | Nenhum script de notificação |
| **Snapshot pré-upgrade** | 🔴 | Não implementado |
| **Restore automático** | 🔴 | Não implementado |
| **Limpeza de logs** | 🔴 | Docker logs com rotação, mas sem limpeza de sistema |
| **Monitoramento de disco** | 🔴 | Nenhum alerta de disco cheio |
| **Backup externo** | 🔴 | Não automatizado |

---

## FASE 11 — TESTES

### Situação Atual

| Teste | Status | Observação |
|-------|--------|------------|
| **Health check dos containers** | 🟡 | Docker `restart: unless-stopped` + health checks em alguns containers |
| **Health check via Uptime Kuma** | ✅ | Monitoramento externo via Cloudflare |
| **Teste de restore** | 🔴 | Nenhum teste. backup.sh nunca executou |
| **Teste de backup (restic check)** | 🔴 | Repositório inacessível |
| **Teste de portas** | 🔴 | ss -tlnp mostra apenas 22 |
| **Teste de SSL** | 🔴 | Cloudflare gerencia |
| **Teste de hardening** | 🔴 | Não implementado |
| **Teste de performance** | 🔴 | fio, iperf3 não instalados |
| **Smoke test pós-update** | 🔴 | Não documentado |
| **Teste de DR (Disaster Recovery)** | 🔴 | Não documentado |

---

## FASE 12 — PRODUÇÃO READINESS

### Confiabilidade

| Aspecto | Nota (0-10) | Justificativa |
|---------|------------|---------------|
| **Uptime** | 6 | Containers com restart: unless-stopped, mas sem monitoramento |
| **Recuperação pós-falha** | 4 | Sem teste de restore, backup não funcional |
| **Recuperação pós-energia** | 5 | restart: unless-stopped configurado, mas sda3 não monta (fstab pode falhar) |
| **Redundância** | 1 | Single point of failure: 1 servidor, 1 HD, 1 tunnel |
| **Backup verificável** | 0 | Nenhum backup funcional |

### Performance

| Aspecto | Nota (0-10) | Justificativa |
|---------|------------|---------------|
| **CPU** | 5 | AMD A8-6410 (4 cores, 2014). Load médio 3.81/4 — **quase 100%** |
| **RAM** | 2 | 3.3 GB DDR3. Swap ativo (222MB). **Criticamente baixa para todas as cargas** |
| **Disco IO** | 2 | Toshiba 5400 RPM 1TB. **Gargalo massivo** para banco de dados |
| **Rede** | 7 | Cloudflare Tunnel ok, mas latência adicional |
| **Swap ativo** | 3 | 222MB em swap = memória insuficiente para workload |

### Escalabilidade

| Aspecto | Nota (0-10) | Justificativa |
|---------|------------|---------------|
| **Armazenamento** | 5 | sda3 530GB não montado. Dados em sda2 de 400GB (67G usado) |
| **Usuários** | 2 | 1 admin. Sem suporte a múltiplos usuários |
| **Serviços** | 5 | 12 containers rodando, mas sem recursos para mais |
| **Rede** | 5 | Docker bridge única, sem segmentação |

### Manutenção

| Aspecto | Nota (0-10) | Justificativa |
|---------|------------|---------------|
| **Facilidade de update** | 4 | docker compose pull + up -d, mas sem snapshot prévio |
| **Documentação de manutenção** | 2 | PLANO_COMPLETO.md tem calendário, mas scripts não existem |
| **Rollback** | 3 | Sem snapshots, sem versões anteriores dos volumes |
| **Reproduzibilidade** | 2 | Repositório tem templates mas setup.sh não existe |
| **Logs acessíveis** | 4 | Docker logs locais, sem centralização |

---

## FASE 13 — GAP ANALYSIS

### 🔴 Crítico (IMPLEMENTAR IMEDIATAMENTE)

| # | Gap | Impacto | Solução |
|---|-----|---------|---------|
| C1 | **Backup pipeline quebrado** (Restic Access Denied, IP errado, secrets hardcoded) | Dados sem backup | Corrigir backup.sh, reinit repo Restic, testar restore |
| C2 | **sda3 (530GB) não montado** | Dados na partição root (400G), sem o storage dedicado planejado | Montar sda3 em /srv/personal-cloud, migrar dados |
| C3 | **RAM insuficiente (3.3 GB)** | Swap ativo, Immich/Paperless instáveis, load alto | Upgrade para 8GB+ DDR3 SODIMM |
| C4 | **UFW desativado** | Servidor exposto | Ativar UFW: permitir apenas 22 de IPs confiáveis |
| C5 | **SSH PasswordAuthentication possível** | Config padrão = yes comentado | Desabilitar PasswordAuthentication no sshd_config |
| C6 | **Secrets hardcoded no backup.sh** | Exposição se repo for público | Usar .env ou secrets manager |

### 🟡 Importante (PRÓXIMA SPRINT)

| # | Gap | Impacto | Solução |
|---|-----|---------|---------|
| I1 | **Sem observabilidade (Grafana/Prometheus/Loki)** | Cego para problemas de performance e erros | Deployar stack de monitoramento |
| I2 | **Immich retornando 502** | Serviço de fotos indisponível | Debug Cloudflare Tunnel route, verificar health do container |
| I3 | **Paperless retornando 502** | Serviço de documentos indisponível | Debug same as I2 |
| I4 | **Paperless sem Tika + Gotenberg** | OCR não funciona | Adicionar containers ao docker-compose |
| I5 | **Syncthing restartando** | Sincronia não funcional | Debug container, verificar health |
| I6 | **Nenhum teste de restore** | Incapacidade de recuperar dados em desastre | Criar script de restore, testar semanalmente |
| I7 | **Setup.sh não existe** | Repositório não reproduzível | Criar script de setup automatizado |
| I8 | **Config/ diretório não existe** | Configs manuais sem backup | Criar diretório, versionar configs |
| I9 | **backups/ diretório não existe** | Dumps e snapshots sem local padrão | Criar diretório |

### 🔵 Desejável (PRÓXIMOS MESES)

| # | Gap | Impacto | Solução |
|---|-----|---------|---------|
| D1 | **Proxy reverso** | Cloudflare Tunnel faz proxy direto, sem camada de segurança extra | Traefik ou NPM entre Cloudflare e serviços |
| D2 | **Notificações (Telegram/SMTP/ntfy)** | Ninguém sabe se algo falha | Configurar ntfy + Telegram bot + notify.sh |
| D3 | **Backup externo** | Desastre físico = perda total | Backblaze B2 / Wasabi / HD USB |
| D4 | **Snapshots pré-upgrade** | Sem rollback seguro | Script snapshot.sh |
| D5 | **Benchmarks** | Sem baseline de performance | Instalar fio, iperf3, sysbench |
| D6 | **Multiusuário (família)** | Cada usuário precisa de conta separada | Authelia / Authentik + LDAP |
| D7 | **Docker security (read_only, non-root)** | Container escape possível | read_only: true, user: nobody |
| D8 | **Fail2Ban jails configurados** | Sem proteção contra brute force | Configurar jails para todos serviços |

### ⚪ Opcional (FUTURO)

| # | Gap | Impacto | Solução |
|---|-----|---------|---------|
| O1 | **WireGuard VPN** | Acesso direto sem Cloudflare | Instalar WireGuard |
| O2 | **UPS / Nobreak** | Desligamento graceful em queda | NUT + apcupsd |
| O3 | **HDD → SSD upgrade** | Performance geral | SSD SATA 1TB |
| O4 | **Mobile App / PWA** | Experiência mobile | Criar PWA wrapper |
| O5 | **SSO / OIDC** | Login único para todos serviços | Authentik |
| O6 | **RAID / ZFS** | Redundância de disco | mdadm RAID1 ou ZFS mirror |
| O7 | **GitOps / CI/CD** | Deploy automatizado | GitHub Actions |
| O8 | **Migração para Coolify** | Gerenciamento mais fácil | Alternativa a considerar |

---

## FASE 14 — ROADMAP FINAL

### Fase Crítica — Semana 1 (Dias 1-7)

| # | Tarefa | Prioridade | Estimativa | Critério de Aceite |
|---|--------|-----------|------------|---------------------|
| 1 | **Corrigir backup.sh** — remover secrets hardcoded, corrigir IP do MinIO | P0 | 2h | backup.sh usa .env, IP correto (172.31.0.2) |
| 2 | **Reiniciar Restic repo** — init novo repositório com credenciais corretas | P0 | 1h | `restic snapshots` retorna lista vazia |
| 3 | **Executar backup manual** — testar pipeline completo | P0 | 2h | Dump gerado, restic backup OK, restic check OK |
| 4 | **Montar sda3 em /srv/personal-cloud** — corrigir fstab, migrar dados | P0 | 4h | df -h mostra sda3 em /srv/personal-cloud |
| 5 | **Ativar UFW** — portas 22 (admin IP), 80, 443 (Cloudflare IPs) | P0 | 1h | ufw status verbose mostra regras |
| 6 | **Desabilitar SSH PasswordAuthentication** | P0 | 0.5h | sshd_config: PasswordAuthentication no |
| 7 | **Criar .env para foundation + syncthing** | P0 | 0.5h | Todos stacks com .env |
| 8 | **Verificar saúde de Immich, Paperless, Syncthing** | P0 | 2h | 3 serviços retornam 200 via Cloudflare |

### Fase Importante — Semana 2-3 (Dias 8-21)

| # | Tarefa | Prioridade | Estimativa | Critério de Aceite |
|---|--------|-----------|------------|---------------------|
| 9 | **Adicionar Tika + Gotenberg ao Paperless** | P1 | 1h | OCR funcional, upload de PDF gera texto |
| 10 | **Deploy Prometheus + Node Exporter** | P1 | 2h | Métricas disponíveis em :9090 |
| 11 | **Deploy Loki + Promtail** | P1 | 2h | Logs centralizados |
| 12 | **Deploy Grafana + dashboards** | P1 | 3h | Dashboards de sistema, Docker, logs |
| 13 | **Deploy Alertmanager + regras** | P1 | 2h | Alertas de disco, CPU, memória, backup |
| 14 | **Configurar ntfy + Telegram** | P1 | 2h | Notificações de backup, health, alertas |
| 15 | **Criar notify.sh** | P1 | 2h | Script central de notificações |
| 16 | **Teste de restore completo** | P1 | 3h | Restore de arquivo aleatório + banco completo |
| 17 | **Criar setup.sh** | P1 | 4h | Script reproduzível do zero |
| 18 | **Criar /srv/personal-cloud/{config,backups,logs}** | P1 | 0.5h | Diretórios existem |

### Fase Desejável — Mês 2 (Dias 22-60)

| # | Tarefa | Prioridade | Estimativa | Critério de Aceite |
|---|--------|-----------|------------|---------------------|
| 19 | **Adicionar backup externo (Backblaze B2/Wasabi)** | P2 | 4h | Restic com 2 repositórios |
| 20 | **Traefik como proxy reverso** | P2 | 3h | Traefik entre Cloudflare e containers |
| 21 | **Benchmark de performance (fio, iperf3)** | P2 | 2h | Resultados documentados |
| 22 | **Snapshot.sh** | P2 | 2h | Snapshot pré-upgrade automatizado |
| 23 | **Teste de DR (servidor do zero)** | P2 | 8h | Restore completo em servidor limpo |
| 24 | **Multiusuário Nextcloud (criação de contas)** | P2 | 2h | 2+ usuários ativos |
| 25 | **Fail2Ban jails para todos serviços** | P2 | 1h | fail2ban-client status mostra 4+ jails |

### Fase Opcional — Mês 3+

| # | Tarefa | Prioridade | Estimativa |
|---|--------|-----------|------------|
| 26 | Authentik/Authelia para SSO | P3 | 8h |
| 27 | Nobreak + NUT | P3 | 4h |
| 28 | Upgrade RAM para 8GB | P3 | 1h (fisico) |
| 29 | WireGuard VPN | P3 | 2h |
| 30 | Upgrade SSD | P3 | 4h |

---

## FASE 15 — AUDITORIA DE CÓDIGO

### TODO / FIXME / HACK

| Arquivo | Linha | Tipo | Texto |
|---------|-------|------|-------|
| PLANO_COMPLETO.md:372 | — | TODO | "Pesquisa obrigatória antes da decisão: Comparar Nginx Proxy Manager vs Traefik vs Caddy vs Nginx puro" |
| PLANO_COMPLETO.md:376 | — | TODO | "Homepage ou Homarr como landing page. Ver ADR-0005." |
| ADR/README.md | — | TODO | 4 ADRs marcados como "Pendente" |

### Código Morto / Órfão

| Item | Tipo | Detalhes |
|------|------|----------|
| **docker/shared/README.md** | Documento | Define regras, mas conteúdo é mínimo e não referenciado |
| **docs/.gitkeep** | Placeholder | Vazio, sem utilidade |
| **inventory/README.md** | Documento | Referencia script generate-inventory.sh que não existe |

### Volumes Órfãos (Docker)

| Volume | Estado | Observação |
|--------|--------|------------|
| kaos-platform_* volumes (10 volumes) | ⚠️ Órfãos | Containers KAOS parados, volumes montados mas sem uso ativo |
| postgresql-docker_pgdata | ⚠️ Órfão | Projeto externo, sem container |
| wireguard_config | ⚠️ Órfão | Container WireGuard não está rodando |
| 3 volumes hash (7fc4..., 9b57..., 6278...) | ⚠️ Órfãos | Sem container associado |
| Total: **15 volumes, apenas 3 ativos** | ⚠️ | **12 volumes órfãos ocupando 6.894 GB (reclaimable)** |

### Duplicação

| O que | Onde | Problema |
|-------|------|----------|
| POSTGRES_NEXTCLOUD_PASSWORD | databases/.env + nextcloud/.env | Duplicado entre stacks |
| POSTGRES_IMMICH_PASSWORD | databases/.env + immich/.env | Duplicado entre stacks |
| Arquitetura descrita em | PLANO_COMPLETO.md + ARCHITECTURE.md + ADR/ | Conteúdo similar, pode divergir |
| docker-compose.yml | Repo docker/stacks/ + Servidor /home/dev/ | Cópias não sincronizadas |

### Imagens Docker não utilizadas

Docker system df mostra 30.39GB em imagens, 13GB reclaimable (42%). Imagens grandes:
- kaos-api: 5.5GB (parado)
- open-webui: 5GB (parado)
- ollama: 4.8GB (parado)

---

## FASE 16 — NOTAS (0-10)

| Critério | Nota | Justificativa |
|----------|------|---------------|
| **Arquitetura** | 7/10 | Cloudflare Tunnel + Docker + bind mounts é bom design. Faltam proxy reverso e monitoring. Subnet fixa (ADR-0002) contradiz regra de "nunca definir subnet fixa". |
| **Segurança** | 4/10 | Cloudflare Tunnel é ótimo, mas UFW desligado, SSH PasswordAuthentication possível, secrets hardcoded, sem read_only containers, Fail2Ban não verificado. |
| **Backup** | 2/10 | Pipeline quebrado (IP errado, Access Denied), secrets hardcoded, nunca testado, sem backup externo, sda3 não montado. |
| **Documentação** | 5/10 | PLANO_COMPLETO.md e ADRs são bons, mas desatualizados. setup.sh, restore docs, playbook de manutenção não existem. |
| **UX** | 5/10 | Homepage funcional, Cloudflare SSL, mas Immich/Paperless retornam 502, Syncthing restartando, sem mobile app. |
| **Deploy** | 3/10 | Setup manual, sem script reproduzível, repo e servidor dessincronizados (não é git). |
| **Observabilidade** | 1/10 | Apenas Uptime Kuma. Sem métricas, logs centralizados, alertas ou dashboards. |
| **Escalabilidade** | 3/10 | RAM e disco gargalos, sem multiusuário, sem segmentação de rede. |
| **Performance** | 3/10 | CPU load ~100%, swap ativo, HD 5400RPM, 3.3GB RAM para 12 containers. |
| **Multiusuário** | 1/10 | 1 admin, sem SSO, LDAP, MFA, compartilhamento. |
| **Facilidade de Manutenção** | 3/10 | Sem scripts, sem snapshots, sem rollback documentado. |
| **Automação** | 3/10 | Cron do backup.sh configurado mas quebrado. DDNS OK. Unattended upgrades OK. |

### Média Geral: **3.3/10**

---

## FASE 17 — CERTIFICAÇÃO

> ## 🟥 O projeto ainda NÃO está pronto para produção.

### Fatores Impeditivos (Críticos)

1. **🔴 Backup pipeline quebrado** — Restic repo inacessível, backup.sh referencia IP errado, secrets hardcoded. Perda total de dados em caso de falha.

2. **🔴 sda3 (530GB) não montado** — Storage dedicado não implementado. Dados na partição root podem causar falha do sistema se encher.

3. **🔴 RAM insuficiente** — 3.3 GB para 12 containers com swap ativo e CPU load ~100%. Serviços instáveis (Immich/Paperless 502, Syncthing restartando).

4. **🔴 UFW desativado (provável)** — docs confirmam "UFW NÃO ATIVO". Servidor potencialmente exposto.

5. **🔴 SSH PasswordAuthentication ativo** — Config padrão do Ubuntu permite login por senha.

6. **🔴 Sem testes de restore** — Ninguém sabe se o backup funciona ou como recuperar dados.

7. **🔴 Sem observabilidade** — Impossível detectar problemas proativamente.

### Status por Serviço

| Serviço | Ready? | Motivo |
|---------|--------|--------|
| **Cloudflare Tunnel** | ✅ Sim | Funcional, 4 conexões, SSL, saudável |
| **Homepage** | ✅ Sim | Dashboard funcional |
| **Nextcloud** | ✅ Sim | Rodando, acessível |
| **MinIO** | ✅ Sim | Rodando, bucket backups criado |
| **ntfy** | ✅ Sim | Rodando, mas não integrado |
| **Uptime Kuma** | ✅ Sim | Health checks funcionais |
| **Immich** | ❌ Não | 502 via Cloudflare. Precisa de mais RAM |
| **Paperless** | ❌ Não | 502 via Cloudflare. Sem Tika/Gotenberg |
| **Syncthing** | ❌ Não | Restartando. Não funcional |
| **Backup (Restic)** | ❌ Não | Pipeline quebrado, nunca testado |

### Plano de Ação Imediato

O próprio documento `IMPLEMENTATION_PLAN_FINAL.md` contém o plano detalhado na **FASE 14 — ROADMAP FINAL**. Resumo:

1. **Corrigir backup (2 dias)** — backup.sh, Restic repo, testar restore
2. **Montar sda3 (1 dia)** — fstab, migração de dados
3. **Hardening mínimo (1 dia)** — UFW, SSH, Fail2Ban
4. **Estabilizar serviços (2 dias)** — Debug Immich, Paperless, Syncthing
5. **Monitoramento (3 dias)** — Prometheus + Loki + Grafana

Após estas 5 tarefas (estimativa: 9 dias), o projeto atingiria ~7/10 e poderia ser considerado **estável para uso pessoal**.

---

*Documento gerado em 2026-07-13 via auditoria automatizada MCP*
*Ferramentas: SSH MCP, Docker, Filesystem, Sequential Thinking*
