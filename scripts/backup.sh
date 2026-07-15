#!/bin/bash
# backup.sh — Personal Cloud & Backup
# Reproduzivel: copie .env.backup.example para .env.backup e configure
# Notificacoes: integrado com notify.sh + ntfy

NOTIFY_SCRIPT="$(cd "$(dirname "$0")" && pwd)/notify.sh"
notify() { [ -x "$NOTIFY_SCRIPT" ] && "$NOTIFY_SCRIPT" "$1" "$2"; }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env.backup"

if [ -f "$ENV_FILE" ]; then
  set -a
  source "$ENV_FILE"
  set +a
else
  echo "ERRO: .env.backup nao encontrado"
  echo "Copie .env.backup.example para .env.backup e configure"
  exit 1
fi

MINIO_IP=$(docker inspect minio --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' 2>/dev/null)
[ -z "$MINIO_IP" ] && echo "ERRO: Container minio nao encontrado" && exit 1

export RESTIC_REPOSITORY="s3:http://${MINIO_IP}:9000/backups"
export DATE=$(date +%Y%m%d-%H%M)
LOG_DIR="/srv/personal-cloud/logs"
mkdir -p "$LOG_DIR"

run_restic() {
  sudo env \
    AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID" \
    AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY" \
    RESTIC_REPOSITORY="$RESTIC_REPOSITORY" \
    RESTIC_PASSWORD="$RESTIC_PASSWORD" \
    restic "$@"
}

echo "[$DATE] Iniciando backup (MinIO: $MINIO_IP)" | tee -a "$LOG_DIR/backup.log"

echo "[$DATE] Dump PostgreSQL..." | tee -a "$LOG_DIR/backup.log"
docker exec postgres-nextcloud pg_dump -U nextcloud -Fc nextcloud > /tmp/nextcloud-$DATE.dump 2>>"$LOG_DIR/backup.log"
docker exec postgres-immich pg_dump -U immich -Fc immich > /tmp/immich-$DATE.dump 2>>"$LOG_DIR/backup.log"

run_restic backup --tag "nextcloud-$DATE" /srv/personal-cloud/apps/volumes/nextcloud 2>&1 | tee -a "$LOG_DIR/backup.log"
run_restic backup --tag "postgres-$DATE" /tmp/nextcloud-$DATE.dump /tmp/immich-$DATE.dump 2>&1 | tee -a "$LOG_DIR/backup.log"
run_restic backup --tag "system-$DATE" /etc/fstab /etc/docker/ /home/dev/personal-cloud-docker/ /srv/personal-cloud/config/ 2>&1 | tee -a "$LOG_DIR/backup.log"
run_restic forget --keep-daily 7 --keep-weekly 4 --keep-monthly 6 --prune 2>&1 | tee -a "$LOG_DIR/backup.log"
run_restic check --no-lock 2>&1 | tee -a "$LOG_DIR/backup.log"

find /tmp -name "*.dump" -mtime +7 -delete
notify success "Backup concluido (${DATE})"
echo "[$(date +%Y%m%d-%H%M)] Backup concluido" | tee -a "$LOG_DIR/backup.log"
