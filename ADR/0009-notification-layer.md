# ADR-0009: Notification Layer

## Contexto
Servicos precisam notificar usuarios sobre eventos (backup, erros, saude).

## Decisao
ntfy (self-hosted) como canal primario de notificacao.
Futuro: Telegram + SMTP como canais adicionais.
Todos eventos passam por notify.sh (central).

## Status Atual
ntfy deployado em https://notify.kaostech.com.br
Script notify.sh nao implementado ainda.
Nenhum servico integrado ao ntfy.

## Proximos Passos
1. Criar notify.sh
2. Integrar backup.sh com notify.sh
3. Adicionar Telegram Bot
