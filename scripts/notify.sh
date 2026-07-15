#!/bin/bash
# notify.sh — Central de notificacoes
# Uso: ./notify.sh <tipo> <mensagem>
# Tipo: success, warning, error, info

TYPE="${1:-info}"
MESSAGE="${2:-Notificacao sem mensagem}"
NTFY_TOPIC="personal-cloud"
NTFY_URL="http://ntfy:80"

# Cores e emojis
case "$TYPE" in
  success) TAG="✅"; PRIORITY=4 ;;
  warning) TAG="⚠️"; PRIORITY=3 ;;
  error)   TAG="❌"; PRIORITY=5 ;;
  info)    TAG="ℹ️"; PRIORITY=2 ;;
  *)       TAG="📢"; PRIORITY=2 ;;
esac

# Enviar para ntfy (se disponivel)
curl -s -o /dev/null -H "Title: Personal Cloud" \
  -H "Priority: $PRIORITY" \
  -H "Tags: $TAG" \
  -d "$MESSAGE" \
  "$NTFY_URL/$NTFY_TOPIC" 2>/dev/null && echo "ntfy: OK" || echo "ntfy: FAIL"

# Log local
echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$TYPE] $MESSAGE" >> /srv/personal-cloud/logs/notifications.log
