# ADR-0006: Backup Strategy

## Contexto
Dados críticos precisam de backup automático com versões e possibilidade de restore.

## Decisão
Usar Restic com repositório no MinIO (mesmo servidor). Backup diário via cron às 02:00. Dumps PostgreSQL antes do Restic.

## Pipeline
```
PostgreSQL → pg_dump → compressão → checksum → Restic → MinIO

Retention: 7 daily, 4 weekly, 6 monthly
```

## Consequências
Positivas: backup versionado, deduplicação, criptografia, restore rápido.
Negativas: MinIO está no mesmo servidor — não protege contra desastre físico.

## Próximo passo
Adicionar backup externo (HD USB / Backblaze / Wasabi).
