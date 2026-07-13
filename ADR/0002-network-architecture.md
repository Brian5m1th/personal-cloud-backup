# ADR-0002: Network Architecture

## Contexto
KAOS já utiliza 172.28.0.0/16. Personal Cloud precisa de rede Docker isolada.

## Decisão
Usar `personal-cloud` como bridge Docker com subnet 172.31.0.0/24, verificada como livre através de `docker network inspect` e `ip route`.

## Consequências
Positivas: sem conflito com KAOS ou WireGuard.
Negativas: subnet fixa precisa ser verificada em novos servidores.

## Regra
Nunca definir subnet fixa no código. Sempre detectar range livre no momento da criação.
