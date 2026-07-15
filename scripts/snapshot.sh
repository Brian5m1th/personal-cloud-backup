#!/bin/bash
# snapshot.sh — Snapshot pre-upgrade via Restic
# Uso: ./snapshot.sh <servico>
# Exemplo: ./snapshot.sh nextcloud

ENV_FILE="$(cd "$(dirname "$0")" && pwd)/.env.backup"
[ -f "$ENV_FILE" ] || { echo "ERRO: .env.backup nao encontrado"; exit 1; }
set -a; source "$ENV_FILE"; set +a

SERVICE="${1:-all}"
DATE=$(date +%Y%m%d-%H%M)
MINIO_IP=$(docker inspect minio --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' 2>/dev/null)

export RESTIC_REPOSITORY="s3:http://${MINIO_IP}:9000/backups"
RESTIC_CMD="sudo env AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY RESTIC_REPOSITORY=$RESTIC_REPOSITORY RESTIC_PASSWORD=$RESTIC_PASSWORD restic"

echo "[$DATE] Snapshot pre-upgrade: $SERVICE"

if [ "$SERVICE" = "all" ] || [ "$SERVICE" = "nextcloud" ]; then
  eval "$RESTIC_CMD" backup --tag "pre-upgrade-nextcloud-$DATE" /srv/personal-cloud/apps/volumes/nextcloud
fi

if [ "$SERVICE" = "all" ] || [ "$SERVICE" = "postgres" ]; then
  docker exec postgres-nextcloud pg_dump -U nextcloud -Fc nextcloud > /tmp/pre-upgrade-nextcloud-$DATE.dump
  docker exec postgres-immich pg_dump -U immich -Fc immich > /tmp/pre-upgrade-immich-$DATE.dump
  eval "$RESTIC_CMD" backup --tag "pre-upgrade-postgres-$DATE" /tmp/pre-upgrade-*.dump
fi

echo "[$DATE] Snapshot concluido"
