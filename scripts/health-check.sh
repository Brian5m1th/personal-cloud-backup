#!/bin/bash
# health-check.sh — Verifica saude de todos os servicos

echo "=== Health Check — Personal Cloud ==="
echo ""

ERRORS=0

# Containers essenciais
for svc in cloudflared nextcloud postgres-nextcloud redis-nextcloud minio ntfy homepage uptime-kuma; do
  status=$(docker inspect $svc --format '{{.State.Status}}' 2>/dev/null)
  if [ "$status" = "running" ]; then
    echo "✅ $svc: running"
  else
    echo "❌ $svc: $status"
    ERRORS=$((ERRORS+1))
  fi
done

echo ""
echo "=== Recursos ==="
echo "CPU Load: $(uptime | grep -oP 'load average:.*' | cut -d: -f2 | xargs)"
free -h | grep Mem | awk '{print "RAM: " $3 " usado / " $2}'
df -h /srv/personal-cloud | tail -1 | awk '{print "Disco: " $5 " usado (" $4 " livre)"}'

echo ""
echo "=== Restic ==="
RESTIC_CMD="sudo env RESTIC_REPOSITORY=s3:http://$(docker inspect minio --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' 2>/dev/null):9000/backups restic snapshots"
LAST=$(eval "$RESTIC_CMD" 2>/dev/null | grep -c "^[a-f0-9]\{8\}")
echo "Snapshots: $LAST"

if [ $ERRORS -gt 0 ]; then
  echo ""
  echo "⚠️  $ERRORS servico(s) com problemas"
  exit 1
else
  echo ""
  echo "✅ Todos os servicos saudaveis"
fi
