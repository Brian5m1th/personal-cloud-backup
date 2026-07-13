# Power Plan — Personal Cloud & Backup

## Comportamento pós-queda de energia

| Componente | Ação | Configuração |
|-----------|------|-------------|
| Ubuntu | Auto-start (se BIOS/hardware permitir) | BIOS → Power Management |
| Docker | Inicia automaticamente | `systemctl enable docker` |
| Containers | Reiniciam automaticamente | `restart: unless-stopped` |
| PostgreSQL | Recovery via WAL | Automático |
| Restic | Próximo cron retoma | Nenhuma ação |
| Cloudflare Tunnel | Reconecta automaticamente | `restart: unless-stopped` |

## Checklist pós-energia

```bash
# 1. Docker está rodando?
systemctl status docker

# 2. Containers subiram?
docker ps --format "table {{.Names}}\t{{.Status}}"

# 3. Stacks saudáveis?
cd /srv/personal-cloud/docker/stacks
for d in */; do
  echo "=== $d ==="
  docker compose -f "$d/docker-compose.yml" ps
done

# 4. Serviços acessíveis via Cloudflare?
curl -I https://drive.kaostech.com.br
curl -I https://photos.kaostech.com.br
curl -I https://cloud.kaostech.com.br

# 5. Repositório Restic íntegro?
restic check

# 6. Logs de erro?
journalctl -xe | grep -i error | tail -20
```

## Recomendação: Nobreak (UPS)

Modelo sugerido: Nobreak com comunicação USB/serial + `apcupsd` ou `nut`.

### Configuração futura com NUT:

```bash
# Instalar NUT
sudo apt install nut

# Configurar shutdown automático quando bateria < 5%
# Notificar Telegram antes de desligar
```

### Com NUT + notificação:

```
Energia caiu → notificação Telegram → 5 min → bateria crítica
→ shutdown graceful do servidor → energia volta → auto-start
→ notificação "Servidor online novamente"
```
