# Syncthing — Sincronia de Dispositivos

## Status

✅ Funcional (desde 2026-07-14)

## Acesso

- **GUI:** API interna na rede Docker (porta 8384)
- **Sincronia:** Portas 22000 (TCP/UDP) + 21027 (UDP)
- **Protocolo:** LAN + descoberta global

## Configuração

### Adicionar dispositivo

1. No servidor, obter o Device ID:
   ```bash
   docker exec syncthing grep device /var/syncthing/config/config.xml | head -1
   ```
   Atual: `7YL6ACB-XY2PIGC-VHLB6HV-UAGJ364-4Q66XQZ-2AJMANX-LYK6T44-MVTSZQM`

2. No cliente (PC/celular), adicionar dispositivo remoto com este ID.

3. Compartilhar pastas desejadas.

### Pastas compartilhadas no servidor

| Pasta | Caminho no servidor | Modo |
|-------|--------------------|------|
| Default Folder | `/srv/personal-cloud/apps/volumes/syncthing/data` | sendreceive |

## Docker

```yaml
# docker/stacks/syncthing/docker-compose.yml
services:
  syncthing:
    image: syncthing/syncthing:1.28.1
    container_name: syncthing
    restart: unless-stopped
    user: "1000:1000"
    volumes:
      - /srv/personal-cloud/apps/volumes/syncthing/config:/var/syncthing/config
      - /srv/personal-cloud/apps/volumes/syncthing/data:/var/syncthing/data
```

## Troubleshooting

### "permission denied" no cert.pem

O container Syncthing roda como UID 1000. Corrigir:
```bash
sudo chown -R 1000:1000 /srv/personal-cloud/apps/volumes/syncthing/
docker restart syncthing
```

### "4 restarts in 4 seconds"

Mesmo problema de permissão acima.

## Clientes

- **Windows/Linux/macOS:** https://syncthing.net
- **Android:** Play Store → "Syncthing" (ícone laranja)
- **iOS:** Syncthing não disponível oficialmente. Alternativa: Möbius Sync
