# Inventory

Gerado automaticamente pelo script `scripts/generate-inventory.sh`.

## Arquivos

| Arquivo | Fonte | Geração |
|---------|-------|---------|
| `hardware.yaml` | `lscpu, free -h, lsblk` | Automática |
| `docker.yaml` | `docker info, docker version` | Automática |
| `containers.yaml` | `docker ps -a --format json` | Automática |
| `networks.yaml` | `docker network ls, ip a` | Automática |
| `ports.yaml` | `ss -tlnp` | Automática |
| `volumes.yaml` | `docker volume ls, df -h` | Automática |
| `users.yaml` | `cat /etc/passwd, groups` | Automática |
| `cloudflare.yaml` | Tunnel config + DNS | Manual |

## Uso

```bash
scripts/generate-inventory.sh
```

Os arquivos `.yaml` são gitignored. Templates `.example` estão versionados.
