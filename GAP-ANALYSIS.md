# Gap Analysis — Repo vs Servidor vs Plano

> Gerado em: 2026-07-13

---

## 1. Repositório Git (36 arquivos versionados)

| Categoria | Arquivos no Repo | Status |
|-----------|-----------------|--------|
| Docs raiz | README, ARCHITECTURE, ROADMAP, CHANGELOG, EXPANSION, POWER, PLANO_COMPLETO | ✅ 7 docs |
| ADR | 0001 a 0006 + README + TEMPLATE | ✅ 6/10 ADRs |
| Docker stacks | 8 stacks (cloudflared, databases, foundation, immich, minio, nextcloud, paperless, syncthing) | ✅ 8/8 |
| Docs técnicos | docs/02-AUDITORIA, docs/03-INVENTORY | ✅ 2/2 |
| Config | .editorconfig, .gitignore, .opencode/opencode.json | ✅ |
| Inventory | inventory/README.md | ✅ (template vazio) |
| Docker shared | docker/shared/README.md | ✅ (mínimo) |

## 2. O que PLANO_COMPLETO.md PROMETE mas NÃO existe

| Item | Prometido em | Realidade |
|------|-------------|-----------|
| `scripts/setup.sh` | Estrutura do repositório | 🔴 Não existe |
| `scripts/audit.sh` | Estrutura do repositório | 🔴 Não existe |
| `scripts/backup.sh` | Estrutura do repositório | 🔴 Existe apenas no servidor |
| `scripts/restore.sh` | Estrutura do repositório | 🔴 Não existe |
| `scripts/health-check.sh` | Estrutura do repositório | 🔴 Não existe |
| `scripts/cleanup.sh` | Estrutura do repositório | 🔴 Não existe |
| `scripts/notify.sh` | Notification Layer | 🔴 Não existe |
| `scripts/benchmark.sh` | Benchmark | 🔴 Não existe |
| `scripts/generate-inventory.sh` | Inventory | 🔴 Não existe |
| `scripts/update-containers.sh` | Update Policy | 🔴 Não existe |
| `scripts/snapshot.sh` | Snapshot Policy | 🔴 Não existe |
| `tests/` diretório | Testes | 🔴 Não existe |
| `notification/` diretório | Notification Layer | 🔴 Não existe |
| `configs/nginx/` | Configs de proxy | 🔴 Não existe |
| `configs/fail2ban/` | Configs de segurança | 🔴 Não existe |
| `configs/ufw/` | Configs de firewall | 🔴 Não existe |
| `configs/sshd/` | Configs de SSH | 🔴 Não existe |
| `configs/cloudflared/` | Configs do tunnel | 🔴 Não existe |
| `benchmarks/` | Resultados de benchmark | 🔴 Vazio |
| `docs/00-PRE-REQUISITOS.md` | Pré-requisitos | 🔴 Não existe |
| `docs/01-SETUP-MCP.md` | Setup MCP | 🔴 Não existe |
| `docs/04-NETWORK.md` | Arquitetura de rede | 🔴 Não existe |
| `docs/05-INFRA-DOCKER.md` | Infra Docker | 🔴 Não existe |
| `docs/06-VOLUMES.md` | Volumes padronizados | 🔴 Não existe |
| `docs/07-DASHBOARD.md` | Dashboard | 🔴 Não existe |
| `docs/08-CLOUDFLARE.md` | Cloudflare | 🔴 Não existe |
| `docs/09-NEXTCLOUD.md` | Nextcloud deploy | 🔴 Não existe |
| `docs/10-IMMICH.md` | Immich deploy | 🔴 Não existe |
| `docs/11-PAPERLESS.md` | Paperless deploy | 🔴 Não existe |
| `docs/12-MINIO.md` | MinIO deploy | 🔴 Não existe |
| `docs/13-SYNCTHING.md` | Syncthing deploy | 🔴 Não existe |
| `docs/14-RESTIC.md` | Restic backup | 🔴 Não existe |
| `docs/15-BACKUP-BANCOS.md` | Backup de bancos | 🔴 Não existe |
| `docs/16-MONITORAMENTO.md` | Monitoramento | 🔴 Não existe |
| `docs/17-NOTIFICACOES.md` | Notificações | 🔴 Não existe |
| `docs/18-SEGURANCA.md` | Segurança | 🔴 Não existe |
| `docs/19-TESTES.md` | Testes | 🔴 Não existe |
| `docs/20-BENCHMARK.md` | Benchmark | 🔴 Não existe |
| `docs/21-UPDATE-POLICY.md` | Update policy | 🔴 Não existe |
| `docs/22-DISASTER-RECOVERY.md` | Disaster recovery | 🔴 Não existe |
| `docs/23-OPERATIONS.md` | Operações | 🔴 Não existe |
| `docs/24-MANUTENCAO.md` | Manutenção | 🔴 Não existe |

## 3. Servidor vs Repo — Docker Stacks

| Stack | Repo .env.example | Servidor .env | Servidor docker-compose | Match? |
|-------|-------------------|---------------|----------------------|--------|
| cloudflared-personal | ✅ .env.example | ✅ .env com token | ✅ | ✅ |
| databases | ✅ .env.example | ✅ .env com senhas | ✅ | ✅ |
| foundation | ❌ Sem .env.example | ✅ Sem .env | ✅ | ⚠️ Falta .env.example |
| nextcloud | ✅ .env.example | ✅ .env com senhas | ✅ | ✅ |
| immich | ✅ .env.example | ✅ .env | ✅ | ✅ |
| minio | ✅ .env.example | ✅ .env | ✅ | ✅ |
| paperless | ✅ .env.example | ✅ .env | ✅ | ✅ |
| syncthing | ✅ Sem .env.example | ✅ Sem .env | ✅ | ✅ |

## 4. Status dos scripts (Repositorio vs Servidor)

| Script | No Repo? | No Servidor? | Funcional? |
|--------|----------|-------------|------------|
| backup.sh | 🔴 | ✅ /home/dev/... | 🟡 (roda mas lento) |
| .env.backup | 🔴 | ✅ /home/dev/... | ✅ |

## 5. Resumo

| Métrica | Valor |
|---------|-------|
| Arquivos no repo | 36 |
| Docker compose no repo | 8/8 stacks |
| .env.example no repo | 7/8 stacks |
| Scripts no repo | 0/11 planejados |
| Scripts no servidor | 2 (backup.sh + .env.backup) |
| Docs no repo | 3 (plano, auditoria, inventory) |
| Docs planejados no repo | 24 docs → 3 existentes = **21 faltando** |
| ADRs no repo | 6/10 |
| Configs no repo | 0/5 pastas |
| Testes no repo | 0 |

**Conclusão:** O repositório contém os docker-compose essenciais e documentação básica, mas **faltam 21 documentos de documentação, 11 scripts, 5 pastas de configs, e todo o sistema de testes.**

Quer que eu comece a gerar os arquivos faltantes?
