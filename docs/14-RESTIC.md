# Restic — Backup Versionado

## Status

✅ Funcional (5 snapshots ativos)

## Arquitetura

```
PostgreSQL → pg_dump → /tmp/*.dump → Restic → MinIO (bucket: backups)
Volumes (nextcloud, configs) → Restic → MinIO
```

## Comandos

### Backup manual

```bash
cd /home/dev/personal-cloud-docker
./backup.sh
```

### Listar snapshots

```bash
sudo env AWS_ACCESS_KEY_ID=<key> AWS_SECRET_ACCESS_KEY=<secret> \
  RESTIC_REPOSITORY=s3:http://<minio-ip>:9000/backups \
  RESTIC_PASSWORD=<password> restic snapshots
```

### Restaurar arquivo

```bash
sudo env ... restic restore <snapshot-id> --target /tmp/restore --path /srv/personal-cloud/apps/volumes/nextcloud
```

### Verificar integridade

```bash
sudo env ... restic check
```

## Automacao

- **Cron:** Diario as 02:00 (crontab do usuario dev)
- **Retencao:** 7 daily, 4 weekly, 6 monthly
- **Script:** `/home/dev/personal-cloud-docker/backup.sh`
- **Notificacao:** ntfy (quando concluido)

## Snapshots Atuais

```
5 snapshots:
- nextcloud (2x): dados do Nextcloud
- postgres (1x): dumps dos bancos
- system (1x): configs do sistema
- test (1x): teste manual
```
