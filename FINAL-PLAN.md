# Final Implementation Plan — Personal Cloud & Backup

> Gerado: 2026-07-14
> Status: Projeto funcional, com pendências classificadas abaixo

---

## Status Geral

| Métrica | Antes (gap analysis) | Agora |
|---------|---------------------|-------|
| Docker stacks | 8/8 | 8/8 ✅ |
| Scripts | 0/11 | 9/11 ✅ |
| Docs | 3/24 | 14/24 ✅ |
| ADRs | 6/10 | 9/9 ✅ |
| Configs | 0/5 | 4/5 🟡 |
| Testes | 0 | 0 🔴 |
| Serviços funcionais | 5/12 | 7/12 ✅ |

---

## 🔴 Crítico (fazer antes de qualquer outra coisa)

| # | Item | Motivo | Como fazer |
|---|------|--------|------------|
| 1 | **Testar restore real** | Backup sem teste não é backup | `restic restore <snapshot> --target /tmp/test` e verificar arquivos |
| 2 | **Adicionar Tika + Gotenberg ao Paperless** | OCR não funciona sem eles | Adicionar serviços no docker-compose do paperless |
| 3 | **scripts/update-containers.sh** | Sem script de update seguro | Criar script com snapshot pré-upgrade |

## 🟡 Importante (próximos dias)

| # | Item | Estimativa |
|---|------|-----------|
| 4 | **Atualizar GAP-ANALYSIS.md** — reflete dados antigos | 10 min |
| 5 | **Atualizar ADR/README.md** — lista ADRs como pendentes | 5 min |
| 6 | **docs/16-MONITORAMENTO.md** — documentar Uptime Kuma + ntfy | 15 min |
| 7 | **docs/18-SEGURANCA.md** — documentar UFW, Fail2Ban, SSH | 15 min |
| 8 | **docs/21-UPDATE-POLICY.md** — como atualizar containers | 15 min |
| 9 | **configs/cloudflared/** — config do tunnel | 10 min |
| 10 | **Immich: testar estabilidade** — verificar se mantém up | 10 min |

## 🔵 Desejável (quando houver tempo)

| # | Item | Estimativa |
|---|------|-----------|
| 11 | docs/00-PRE-REQUISITOS.md | 20 min |
| 12 | docs/06-VOLUMES.md | 15 min |
| 13 | docs/07-DASHBOARD.md | 10 min |
| 14 | docs/15-BACKUP-BANCOS.md | 15 min |
| 15 | docs/17-NOTIFICACOES.md | 15 min |
| 16 | docs/19-TESTES.md | 15 min |
| 17 | docs/20-BENCHMARK.md | 10 min |
| 18 | docs/24-MANUTENCAO.md | 15 min |
| 19 | scripts/benchmark.sh | 20 min |
| 20 | scripts/audit.sh | 20 min |
| 21 | tests/ (estrutura inicial) | 30 min |
| 22 | **Criar .gitkeep para diretórios vazios** | ✅ Feito |
| 23 | **Preencher notification/ com scripts** | 20 min |
| 24 | **Preencher tests/ com testes reais** | 60 min |
| 25 | **Criar stack dashboard/ (docker-compose)** | 15 min |
| 26 | **Criar stack proxy/ (quando escolher NPM/Traefik)** | 30 min |

## ⚪ Opcional (depende de upgrade RAM)

| # | Item | Dependência |
|---|------|-------------|
| 22 | Immich estável | +4GB DDR3 SODIMM |
| 23 | Paperless + OCR estável | +4GB DDR3 SODIMM |
| 24 | Backup externo (Backblaze B2) | Conta Backblaze |
| 25 | Nobreak / UPS | NUT + apcupsd |

## 📋 Checklist pós-servidor ligar

Quando o servidor voltar do BIOS:

```bash
# 1. Verificar se tudo subiu
ssh dev@192.168.100.31
docker ps

# 2. Verificar sda3 montada
df -h /srv/personal-cloud

# 3. Verificar Cloudflare Tunnel
docker logs personal-cloud-cloudflared --tail 5

# 4. Verificar Syncthing
docker logs syncthing 2>&1 | grep "Established"

# 5. Verificar backup
sudo env ... restic snapshots

# 6. Testar restore
sudo env ... restic restore latest --path /srv/personal-cloud/apps/volumes/nextcloud --target /tmp/test-restore
```

---

**Total de tarefas pendentes:** 26 (3 críticas, 6 importantes, 15 desejáveis/opcionais)
**Tempo estimado para itens críticos:** ~2 horas
**Tempo estimado total:** ~10 horas (incluindo docs, testes e scripts)

## 📂 Diretórios com .gitkeep adicionados

| Diretório | Função | Status |
|-----------|--------|--------|
| `tests/backup/` | Testes de restore | ✅ .gitkeep |
| `tests/network/` | Testes de rede | ✅ .gitkeep |
| `tests/security/` | Testes de hardening | ✅ .gitkeep |
| `tests/performance/` | Testes de benchmark | ✅ .gitkeep |
| `notification/` | Layer de notificação | ✅ .gitkeep |
| `configs/cloudflared/` | Config do tunnel | ✅ .gitkeep |
| `benchmarks/` | Resultados de benchmark | ✅ .gitkeep |
