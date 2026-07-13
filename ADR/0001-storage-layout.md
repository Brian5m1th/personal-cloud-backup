# ADR-0001: Storage Layout

## Contexto
Necessidade de armazenamento dedicado para dados da nuvem pessoal, separado do sistema Ubuntu e do Docker do KAOS.

## Decisão
Criar partição `/dev/sda3` com 530 GB (espaço não alocado), formatada como ext4, montada em `/srv/personal-cloud`.

## Consequências
Positivas: backup simples, restore direto, isolamento do sistema.
Negativas: tamanho fixo (não expansível sem ferramentas como LVM).

## Alternativas Consideradas
- LVM: rejeitado (complexidade desnecessária para uso pessoal)
- Btrfs: rejeitado (incompatibilidade com algumas ferramentas)
- ZFS: rejeitado (requer muita RAM)
