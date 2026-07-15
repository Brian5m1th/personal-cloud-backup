# Cloudflare — Personal Cloud & Backup

## Dominio

kaostech.com.br (Zone ID: c446a158f37b10a28d0ada843ffb3be6)

## Tunnel Dedicado

Nome: cloud
ID: ea6f317b-b425-4fb6-9eb2-a8520de2f5b9
Account ID: a37f39e8319b86a41a2a8402b24321c0

Tunnel separado do KAOS. Container exclusivo.

## Subdominios

| Subdominio | Servico | Porta |
|-----------|---------|-------|
| cloud.kaostech.com.br | Homepage | 3000 |
| drive.kaostech.com.br | Nextcloud | 80 |
| photos.kaostech.com.br | Immich | 3001 |
| docs.kaostech.com.br | Paperless | 8000 |
| notify.kaostech.com.br | ntfy | 80 |
| status.kaostech.com.br | Uptime Kuma | 3001 |
| storage.kaostech.com.br | MinIO Console | 9001 |

## API Token

```bash
TOKEN="cfut_..."  # Cloudflare API token com permissoes: Tunnel:Edit, DNS:Edit
```

## Comandos Uteis

```bash
# Verificar status do tunnel
docker logs personal-cloud-cloudflared --tail 20

# Verificar conexoes
docker logs personal-cloud-cloudflared 2>&1 | grep -c "Registered tunnel"

# Atualizar config do tunnel (via API)
curl -s -X PUT "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT/cfd_tunnel/$TUNNEL/configurations" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  --data '{"config":{"ingress":[...]}}'
```
