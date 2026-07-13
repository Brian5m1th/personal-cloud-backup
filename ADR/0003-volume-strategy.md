# ADR-0003: Volume Strategy

## Contexto
Containers precisam de armazenamento persistente. Docker volumes nomeados vs bind mounts.

## Decisão
Usar bind mounts em `/srv/personal-cloud/apps/volumes/`. Todos os containers montam apenas daí.

## Consequências
Positivas: backup via Restic direto, restore simples cp/rsync, visibilidade clara.
Negativas: permissões precisam ser gerenciadas manualmente.

## Regra
Nenhum container monta fora de `/srv/personal-cloud/apps/volumes/`.
