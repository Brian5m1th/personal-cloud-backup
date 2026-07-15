# ADR-0007: Backup Strategy (Refinado)

## Contexto
backup.sh precisa rodar com sudo para acessar volumes do Nextcloud/Immich.

## Decisao
- backup.sh usa `sudo env ... restic` para preservar credenciais
- Dev user no grupo www-data para acesso de leitura
- Sudoers configurado para NOPASSWD em restic e env

## Consequencias
Positivas: backup funcional, credenciais isoladas em .env
Negativas: depende de sudo, duas camadas de configuracao
