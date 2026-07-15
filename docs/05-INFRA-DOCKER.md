# Docker Infrastructure — Personal Cloud & Backup

## Network

Rede unica `personal-cloud` (bridge, subnet detectada na criacao).
Todos os containers compartilham esta rede.
Comunicacao via DNS interno do Docker (service discovery).

## Volumes

Bind mounts em `/srv/personal-cloud/apps/volumes/<servico>/`.
Nenhum container monta fora deste diretorio.

## Política de Imagens

- **Nunca usar `:latest`** — versao fixa sempre
- Verificar release notes antes de atualizar
- Usar `docker compose pull` para atualizar

## Logging

```yaml
logging:
  driver: json-file
  options:
    max-size: 10m
    max-file: "3"
```

## Restart Policy

`restart: unless-stopped` em todos os containers.

## Estrutura de Stacks

```
/home/dev/personal-cloud-docker/<stack>/
├── docker-compose.yml
└── .env (gitignored)
```

## Deploy

```bash
cd /home/dev/personal-cloud-docker/<stack>
docker compose up -d
```
