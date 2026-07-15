# Immich — Fotos e Videos

## Status

🟡 Instavel (limitacao de RAM — 3.3 GB total)

## Acesso

- **URL:** https://photos.kaostech.com.br
- **Versao:** v1.130.3

## Stack

| Componente | Imagem | Funcao |
|-----------|--------|--------|
| immich-server | ghcr.io/immich-app/immich-server:v1.130.3 | API + microservicos |
| postgres-immich | postgres:17.5 | Banco de dados |
| redis-immich | redis:7.4.2 | Cache |

## Problema Atual

O container immich-server está restartando constantemente (123+ restarts) por falta de RAM.
O machine learning está desabilitado para economizar recursos.

## Requisitos Minimos

- RAM: 4 GB + (recomendado 8 GB)
- CPU: 2+ cores

## Solucao

Adicionar 1 pente DDR3 SODIMM 4GB 1600MHz no slot vazio do servidor.
Apos upgrade, Immich funciona estavelmente.
