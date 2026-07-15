# Paperless-ngx — Gerenciamento de Documentos

## Status

🟡 Instavel (limitacao de RAM)

## Acesso

- **URL:** https://docs.kaostech.com.br
- **Versao:** 2.15.1

## Stack

| Componente | Imagem | Funcao |
|-----------|--------|--------|
| paperless | ghcr.io/paperless-ngx/paperless-ngx:2.15.1 | Web + consumidor |
| postgres-nextcloud | postgres:17.5 | Banco (compartilhado) |
| redis-nextcloud | redis:7.4.2 | Cache (compartilhado) |

## Observacao

**Tika + Gotenberg nao implantados** — OCR de documentos nao funciona.
Servicos necessarios para OCR completo:
- ghcr.io/paperless-ngx/tika (extrair texto)
- gotenberg/gotenberg (conversao PDF)

Adicionar ao `docker-compose.yml` quando houver RAM disponivel.

## Uso

- Upload de PDFs/ imagens
- OCR automatico (quando Tika+Gotenberg ativos)
- Tags e categorizacao
- Busca por texto completo
