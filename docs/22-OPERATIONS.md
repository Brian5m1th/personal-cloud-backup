# Operations — Personal Cloud & Backup

## Servicos

### Iniciar/Parar servicos

```bash
# Todos os servicos
cd /home/dev/personal-cloud-docker/<stack>
docker compose up -d
docker compose down

# Servico especifico
docker start/stop <container-name>
```

### Ver logs

```bash
docker logs <container-name> --tail 50
docker logs -f <container-name>  # seguir em tempo real
```

### Atualizar container

```bash
cd /home/dev/personal-cloud-docker/<stack>
docker compose pull
docker compose up -d
```

## Backup

### Backup manual

```bash
cd /home/dev/personal-cloud-docker
./backup.sh
```

### Verificar snapshots

```bash
sudo env AWS_ACCESS_KEY_ID=<key> AWS_SECRET_ACCESS_KEY=<secret> \
  RESTIC_REPOSITORY=s3:http://<minio-ip>:9000/backups \
  RESTIC_PASSWORD=<password> restic snapshots
```

### Restaurar arquivo

```bash
sudo env ... restic restore <snapshot-id> --target /tmp/restore
```

## Health Check

```bash
# Verificar status de todos os servicos
docker ps

# Verificar recursos
htop ou free -h
df -h
uptime
```

## Credenciais

Todas as senhas estao em /srv/personal-cloud/CREDENCIAIS.txt
