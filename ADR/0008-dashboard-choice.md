# ADR-0008: Dashboard Choice

## Contexto
Escolha do dashboard principal para a landing page (cloud.kaostech.com.br).

## Decisao
Homepage (ghcr.io/gethomepage/homepage:v1.2.0)
- Leve (Node.js), Docker socket integration nativa
- Config via YAML, facil manutencao
- Tema escuro, icones via Simple Icons

## Consequencias
Positivas: leve, facil configuracao, status dos containers via Docker socket
Negativas: sem PWA, sem autenticacao nativa, sem search bar

## Alternativas Rejeitadas
- Homarr: mais pesado, muitas features nao utilizadas
- Heimdall: menos flexivel que Homepage
