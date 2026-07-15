# MinIO — Object Storage (S3)

## Status

✅ Funcional (desde 2026-07-12)

## Acesso

- **API S3:** http://minio:9000 (rede interna Docker)
- **Console:** https://storage.kaostech.com.br (via Cloudflare Tunnel)
- **Login:** Ver CREDENCIAIS.txt

## Stack

| Componente | Imagem | Funcao |
|-----------|--------|--------|
| minio | minio/minio:RELEASE.2025-09-07 | Object storage S3 |

## Buckets

| Bucket | Uso |
|--------|-----|
| `backups` | Repositorio Restic (backup dos servicos) |

## Volumes

```
/srv/personal-cloud/apps/volumes/minio/data/  →  /data
```

## Credenciais

```bash
# No arquivo .env.backup:
AWS_ACCESS_KEY_ID=<seu-access-key>
AWS_SECRET_ACCESS_KEY=<seu-secret-key>
```

## Importante

MinIO esta no **mesmo servidor**. Protege contra erro humano, mas nao contra desastre fisico.
Para protecao real, adicionar backup externo (Backblaze B2 / Wasabi / HD USB).
