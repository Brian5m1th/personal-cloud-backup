# Nextcloud — Cloud Pessoal

## Status

✅ Funcional (desde 2026-07-12)

## Acesso

- **URL:** https://drive.kaostech.com.br
- **Admin:** admin / CloudBackup2026!
- **Versao:** 30.0.6

## Stack

| Componente | Imagem | Funcao |
|-----------|--------|--------|
| nextcloud | nextcloud:30.0.6 | Apache + PHP + Nextcloud |
| postgres-nextcloud | postgres:17.5 | Banco de dados |
| redis-nextcloud | redis:7.4.2 | Cache |

## Volumes

```
/srv/personal-cloud/apps/volumes/nextcloud/
├── files/      → /var/www/html (codigo + data)
├── config/     → /var/www/html/config
├── apps/       → /var/www/html/apps
└── themes/     → /var/www/html/themes
```

## Uso

- Upload/download de arquivos via web
- Sincronia com celular (app Nextcloud)
- Compartilhamento de links
- Backup automatico de fotos (app)

## Credenciais

Ver `/srv/personal-cloud/CREDENCIAIS.txt` no servidor.
