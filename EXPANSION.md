# Expansion Plan — Personal Cloud & Backup

## Cenários de Crescimento

### Disco cheio (1 TB)

Adicionar segundo HDD, montar em `/srv/personal-cloud` ou expandir partição existente.

### SSD para banco de dados

Migrar volumes PostgreSQL e Redis para SSD:
1. Parar containers
2. Copiar dados para SSD
3. Montar SSD em `apps/volumes/postgres-*/`
4. Iniciar containers

### Adicionar NAS

Montar NFS em `/srv/personal-cloud/archive/` para dados frios.

### RAID

- `mdadm` RAID 1 (espelhamento)
- Ou ZFS mirror para dados críticos

### Migrar servidor

1. Instalar Ubuntu + Docker no novo servidor
2. Clonar este repositório
3. Rodar `setup.sh`
4. Rsync dos volumes
5. Atualizar DNS

### Backup externo

- HD USB conectado periodicamente
- Backblaze B2 via Restic
- Wasabi (S3 compatível)
- Servidor secundário (rsync)
