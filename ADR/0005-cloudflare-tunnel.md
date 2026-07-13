# ADR-0005: Cloudflare Tunnel

## Contexto
Serviços precisam ser expostos na internet de forma segura sem abrir portas no firewall.

## Decisão
Usar Cloudflare Tunnel dedicado (`cloud`, ID: `ea6f317b-b425-4fb6-9eb2-a8520de2f5b9`) em container separado do túnel do KAOS.

## Consequências
Positivas: sem porta 80/443 aberta, SSL automático, isolamento do KAOS.
Negativas: dependência de Cloudflare, latência adicional.

## Regras
- Container exclusivo para personal-cloud
- Token próprio (nunca reutilizar)
- `restart: unless-stopped`
