# Syncthing — Sincronia de Dispositivos

## Status

✅ Funcional (desde 2026-07-14)

## Acesso

- **Sincronia:** Porta 22000 TCP/UDP (exposta no host + UFW)
- **Descoberta:** Porta 21027 UDP
- **GUI:** API interna na rede Docker (porta 8384)

## Configuração

### Device ID do Servidor

```
7YL6ACB-XY2PIGC-VHLB6HV-UAGJ364-4Q66XQZ-2AJMANX-LYK6T44-MVTSZQM
```

### Adicionar dispositivo no servidor (via terminal)

```bash
PC_ID="ID-DO-DEVICE-PC"
docker stop syncthing
CONFIG="/srv/personal-cloud/apps/volumes/syncthing/config/config.xml"
sudo sed -i "s|</configuration>|<device id=\"$PC_ID\" compression=\"metadata\" introducer=\"false\" skipIntroductionRemovals=\"false\" name=\"PC-Nome\"><address>dynamic</address></device>\n</configuration>|" "$CONFIG"
docker start syncthing
```

### Adicionar servidor no cliente (PC)

1. Abrir Syncthing
2. **Add Remote Device** → colar ID do servidor
3. Em **Addresses**, adicionar: `tcp://<ip-do-servidor>:22000`
4. Salvar

### Verificar conexão

```bash
docker logs syncthing 2>&1 | grep "Established secure connection"
```

Exemplo de saída bem-sucedida:
```
Established secure connection to 4VVDHDB at 172.31.0.6:22000-192.168.100.27:22000/tcp-client/TLS1.3-...
```

## Pastas

As pastas compartilhadas são configuradas pelo cliente. O servidor aceita automaticamente se `Aceitar automaticamente` estiver ativo.

## Docker

```yaml
services:
  syncthing:
    image: syncthing/syncthing:1.28.1
    container_name: syncthing
    restart: unless-stopped
    user: "1000:1000"
    ports:
      - 22000:22000/tcp
      - 22000:22000/udp
      - 21027:21027/udp
    volumes:
      - /srv/personal-cloud/apps/volumes/syncthing/config:/var/syncthing/config
      - /srv/personal-cloud/apps/volumes/syncthing/data:/var/syncthing/data
```

## Troubleshooting

### "permission denied" — cert.pem

```bash
sudo chown -R 1000:1000 /srv/personal-cloud/apps/volumes/syncthing/
docker restart syncthing
```

### "connection refused" no cliente

Verificar:
```bash
# Porta esta escutando?
ss -tlnp | grep 22000

# UFW liberado?
sudo ufw status | grep 22000

# IP correto?
hostname -I
```

## Clientes

- **Windows/Linux/macOS:** https://syncthing.net
- **Android:** Play Store → "Syncthing" (ícone laranja)
- **iOS:** Alternativa: Möbius Sync
