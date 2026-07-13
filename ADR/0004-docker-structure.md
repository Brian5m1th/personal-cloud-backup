# ADR-0004: Docker Structure

## Contexto
Múltiplos serviços precisam ser organizados de forma reproduzível.

## Decisão
Usar stacks Docker Compose separadas por serviço em `/home/dev/personal-cloud-docker/<stack>/`. Cada stack com seu `docker-compose.yml` e `.env`.

## Consequências
Positivas: isolamento entre serviços, deploy independente, fácil manutenção.
Negativas: depende de rede Docker compartilhada para comunicação entre stacks.

## Rede Compartilhada
Todos os serviços conectam-se à rede `personal-cloud` (external: true).
