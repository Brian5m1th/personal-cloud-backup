# Disaster Recovery — Personal Cloud & Backup

## Pre-requisitos para restore

- Ubuntu 24.04+ instalado
- Docker + Docker Compose
- Acesso ao repositorio Restic (MinIO local)
- Este repositorio git

## Restore completo (servidor do zero)

```bash
# 1. Instalar dependencias
sudo apt install docker.io docker-compose-v2 git restic

# 2. Clonar repositorio
git clone https://github.com/Brian5m1th/personal-cloud-backup.git
cd personal-cloud-backup

# 3. Criar estrutura de diretorios
sudo mkdir -p /srv/personal-cloud/apps/volumes
sudo chown -R dev:dev /srv/personal-cloud

# 4. Restaurar volumes do Restic
sudo env AWS_ACCESS_KEY_ID=<key> AWS_SECRET_ACCESS_KEY=<secret> \
  RESTIC_REPOSITORY=s3:http://<minio-ip>:9000/backups \
  RESTIC_PASSWORD=<senha> restic restore latest --target /

# 5. Subir servicos
cd docker/stacks/databases && docker compose up -d
cd ../nextcloud && docker compose up -d
# ... demais stacks
```

## Restore parcial (apenas um servico)

```bash
# Listar snapshots
restic snapshots --tag nextcloud

# Restaurar snapshot especifico
restic restore <snapshot-id> --target /tmp/restore
cp -r /tmp/restore/srv/personal-cloud/apps/volumes/nextcloud/* /srv/personal-cloud/apps/volumes/nextcloud/
```

## Pos-restore

- Verificar health de todos os containers
- Testar login nos servicos
- Verificar integridade dos dados
- Reconfigurar Cloudflare Tunnel se necessario
