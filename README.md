# Personal Cloud & Backup

Infraestrutura completa de nuvem pessoal e backup para Ubuntu Server.

> **Domínio:** kaostech.com.br
> **Repositório:** github.com/Brian5m1th/personal-cloud-backup

## Stack

| Serviço | Função | Acesso |
|---------|--------|--------|
| Homepage | Dashboard central | cloud.kaostech.com.br |
| Nextcloud | Cloud pessoal | drive.kaostech.com.br |
| Immich | Gerenciamento de fotos | photos.kaostech.com.br |
| Paperless-ngx | Documentos + OCR | docs.kaostech.com.br |
| MinIO | Object storage (S3) | storage.kaostech.com.br |
| Syncthing | Sincronia de dispositivos | LAN |
| Restic | Backup versionado | Automático |
| Grafana | Monitoramento | grafana.kaostech.com.br |
| Uptime Kuma | Health checks | status.kaostech.com.br |
| ntfy | Notificações push | notify.kaostech.com.br |

## Quick Start

```bash
# No servidor Ubuntu
git clone https://github.com/Brian5m1th/personal-cloud-backup.git
cd personal-cloud-backup

# Revisar inventário
cp inventory/*.yaml.example inventory/
nano inventory/server.yaml

# Executar setup
sudo ./scripts/setup.sh
```

## Documentação

Cada etapa em `docs/` contém comandos, validação e rollback.

## Reprodução

Este repositório é auto-contido. Qualquer pessoa com um servidor Ubuntu pode recriar toda a infraestrutura seguindo os documentos em `docs/`.
