# Docker — Recursos Compartilhados

## shared/networks/

Definição da rede `personal-cloud`. Usar subnet dinâmica.

## shared/volumes/

Mapa de volumes padronizados (todos em `/srv/personal-cloud/apps/volumes/`).

## Regras

- Toda imagem com versão fixa (nunca `:latest`)
- Nenhum IP fixo — usar DNS interno do Docker
- Container names em `kebab-case`
