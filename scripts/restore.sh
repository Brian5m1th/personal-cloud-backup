#!/bin/bash
# restore.sh — Restore de backup Restic
# Uso: ./restore.sh <tag> [snapshot-id]
# Exemplo: ./restore.sh nextcloud latest

ENV_FILE="$(cd "$(dirname "$0")" && pwd)/.env.backup"
[ -f "$ENV_FILE" ] || { echo "ERRO: .env.backup nao encontrado"; exit 1; }
set -a; source "$ENV_FILE"; set +a

MINIO_IP=$(docker inspect minio --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' 2>/dev/null)
[ -z "$MINIO_IP" ] && { echo "ERRO: Container minio nao encontrado"; exit 1; }

export RESTIC_REPOSITORY="s3:http://${MINIO_IP}:9000/backups"
TAG="${1:-nextcloud}"
SNAPSHOT="${2:-latest}"

echo "=== Restore Restic ==="
echo "Tag: $TAG"
echo "Snapshot: $SNAPSHOT"
echo ""

# Listar snapshots disponiveis
echo "Snapshots disponiveis para tag '$TAG':"
sudo env AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID" AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY" \
  RESTIC_REPOSITORY="$RESTIC_REPOSITORY" RESTIC_PASSWORD="$RESTIC_PASSWORD" \
  restic snapshots --tag "$TAG" 2>/dev/null

echo ""
read -p "Confirmar restore? (y/N) " -n 1 -r
echo
[[ $REPLY =~ ^[Yy]$ ]] || exit 0

# Executar restore
sudo env AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID" AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY" \
  RESTIC_REPOSITORY="$RESTIC_REPOSITORY" RESTIC_PASSWORD="$RESTIC_PASSWORD" \
  restic restore "$SNAPSHOT" --tag "$TAG" --target /tmp/restore-$(date +%Y%m%d) -v 2>&1

echo ""
echo "Restore concluido. Verificar em /tmp/restore-*/"
