# Setup MCP — Personal Cloud & Backup

## Pre-requisitos

- Python 3.11+
- Node.js 18+
- Git
- Acesso ao servidor Ubuntu (SSH)

## Instalar MCP Platform

```powershell
cd C:\workspace\Extras\personal-mcp-platform
python -m pip install -e .
```

## Adicionar SSH MCP ao Registry

Adicionar ao `registry.yaml` a entrada para `mcp-server-ssh` (pacote: `mcp-server-ssh` por bacarrdy).

## Profile cloud-backup

Criar `profiles/cloud-backup.yaml` com: ssh, docker, filesystem, sequential-thinking, fetch, memory, cloudflare.

## Instalar e Vincular

```powershell
mcp profile set cloud-backup
mcp install ssh && mcp install docker && mcp install cloudflare
# Configurar secrets
$env:SSH_HOST = "ip-do-server"
$env:SSH_USER = "usuario"
# Vincular projeto
cd C:\workspace\Extras\personal-cloud-backup
mcp project add --agent opencode --profile cloud-backup
mcp generate opencode
mcp start
```

## Conectar ao Servidor

```powershell
ssh_connect(host: "ip", username: "dev", privateKeyPath: "~/.ssh/id_ed25519", passphrase: "...")
```
