#!/bin/bash
# cleanup.sh — Limpeza de logs e recursos nao utilizados

LOG_DIR="/srv/personal-cloud/logs"
echo "[$(date)] Iniciando cleanup..."

# Limpar logs antigos (>30 dias)
find "$LOG_DIR" -name "*.log" -mtime +30 -delete 2>/dev/null

# Limpar dumps antigos (>7 dias)
find /tmp -name "*.dump" -mtime +7 -delete 2>/dev/null

# Limpar imagens Docker nao utilizadas (apenas se espaco critico)
# docker image prune -f --filter "until=24h" 2>/dev/null

echo "[$(date)] Cleanup concluido"
