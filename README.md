# Personal Cloud & Backup

> Infraestrutura pessoal de nuvem e backup para substituir Google Drive, iCloud, Google Fotos e serviços de nuvem comerciais.

**Domínio:** kaostech.com.br
**Repositório:** [github.com/Brian5m1th/personal-cloud-backup](https://github.com/Brian5m1th/personal-cloud-backup)
**Servidor:** Ubuntu 24.04 + Docker

---

## Por que criar sua própria nuvem?

### O problema dos serviços comerciais

| Serviço | Problema |
|---------|----------|
| Google Drive / iCloud | Seus arquivos são escaneados por IA, plano gratuito limitado, cancelamento = perda de acesso |
| Google Fotos | Compressão de fotos, privacidade zero, dependência de ecossistema |
| Dropbox / OneDrive | Caros para armazenamento grande, privacidade questionável |
| Qualquer nuvem pública | Você não controla os dados, pode ser descontinuado, preços sobem |

### O que esta solução oferece

| Benefício | Como |
|-----------|------|
| ✅ **Privacidade total** | Seus dados nunca saem do seu servidor |
| ✅ **Sem mensalidades** | Só o custo do servidor + domínio |
| ✅ **Controle total** | Você decide o que roda, quando atualiza, como backup |
| ✅ **Sem limite de espaço** | Só depende do HD que você colocar |
| ✅ **Offline-first** | Se sua internet cair, tudo continua funcionando em casa |
| ✅ **Sem publicidade** | Nenhum anúncio, nenhum perfil comercial seu |

---

## Serviços

### Por que cada um?

| Serviço | Substitui | Pra que serve |
|---------|-----------|---------------|
| **Nextcloud** | Google Drive, Dropbox, OneDrive | Armazenar e sincronizar arquivos entre dispositivos. Compartilhar links. Editar documentos online. Backup automático de fotos do celular. |
| **Immich** | Google Fotos, iCloud Fotos | Gerenciar fotos e vídeos com reconhecimento facial, álbuns, busca por metadados e linha do tempo. Alternativa auto-hospedada ao Google Fotos. |
| **Paperless-ngx** | — | Digitalizar e organizar documentos (contas, contratos, notas fiscais) com OCR, busca por texto, tags e categorias automáticas. |
| **MinIO** | Amazon S3, Backblaze B2 | Armazenamento de objetos compatível com S3. Usado internamente como destino dos backups Restic e para archives. |
| **Syncthing** | Dropbox, Resilio Sync | Sincronizar pastas entre dispositivos sem depender de servidor central. Ideal para sincronia em tempo real PC ↔ PC. |
| **Homepage** | — | Dashboard central com links para todos os serviços e status dos containers. Ponto de entrada único. |
| **ntfy** | Pushover, Telegram | Notificações push para o celular sobre backup, erros e eventos do servidor. |

### Diferenças para outras soluções

| Aspecto | CasaOS / Umbrel | TrueNAS Scale | Cloudron | **Este Projeto** |
|---------|----------------|---------------|----------|-----------------|
| **Foco** | Home lab fácil | Storage empresarial | App server | **Nuvem pessoal privada** |
| **App Store** | ✅ Sim | ✅ Sim (apps) | ✅ Curadoria | ❌ **Manual (Docker Compose)** |
| **Backup nativo** | ❌ Parcial | ✅ ZFS snapshots | ✅ Backup integrado | ✅ **Restic + MinIO + dumps** |
| **Privacidade** | 🟡 Média | 🟡 Média | 🟡 Média | ✅ **Total (Cloudflare Tunnel)** |
| **Zero Trust** | ❌ | ❌ | ❌ | ✅ **Nenhuma porta exposta** |
| **Custo** | Gratuito | Gratuito | Pago | **Gratuito (só o domínio)** |
| **Controle** | Alto | Alto | Médio | **Total (você configura tudo)** |
| **Complexidade** | Baixa | Média | Baixa | **Média (requer Linux/Docker)** |

**Este projeto não é um sistema operacional.** É uma coleção de stacks Docker orquestradas manualmente, documentadas e versionadas no Git. Você tem controle total sobre cada componente.

---

## Stack

```
Internet → Cloudflare (DNS + DDoS) → Cloudflare Tunnel → Docker
                                                              │
                         ┌────────────────────────────────────┤
                         │              │                     │
                    Homepage         Nextcloud            MinIO
                   (Dashboard)     (Arquivos)        (Object Store)
                         │              │                     │
                     ntfy           Immich              Restic
                 (Notificações)    (Fotos)            (Backups)
                         │              │
                    Uptime Kuma    Paperless-ngx
                  (Health checks)  (Documentos)
```

## Quick Start

```bash
# No servidor Ubuntu
git clone https://github.com/Brian5m1th/personal-cloud-backup.git
cd personal-cloud-backup/scripts
sudo ./setup.sh

# Subir servicos
cd ../docker/stacks/databases && docker compose up -d
cd ../foundation && docker compose up -d
cd ../nextcloud && docker compose up -d
```

## Documentação

| Documento | Conteúdo |
|-----------|----------|
| `docs/01-SETUP-MCP.md` | Configuração da MCP Platform |
| `docs/02-AUDITORIA-SERVIDOR.md` | Auditoria inicial do servidor |
| `docs/03-INVENTORY.md` | Inventário completo |
| `docs/04-NETWORK.md` | Arquitetura de rede |
| `docs/05-INFRA-DOCKER.md` | Infraestrutura Docker |
| `docs/08-CLOUDFLARE.md` | Cloudflare Tunnel + DNS |
| `docs/13-SYNCTHING.md` | Sincronia de dispositivos |
| `docs/22-OPERATIONS.md` | Operações diárias |
| `docs/23-DISASTER-RECOVERY.md` | Recuperação de desastres |
| `PLANO_COMPLETO.md` | Plano de implementação v3.0 |
| `ADR/` | Architecture Decision Records |
| `scripts/` | Scripts de automação |

## Licença

MIT — Livre para uso pessoal.
