#!/bin/bash
# setup.sh — Personal Cloud & Backup (setup automatizado)
# Uso: sudo ./setup.sh
# ATENCAO: Executar em servidor Ubuntu 24.04+ LIMPO

set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
log() { echo -e "${GREEN}[+]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
err() { echo -e "${RED}[x]${NC} $1"; exit 1; }

echo "=== Personal Cloud & Backup — Setup ==="
echo ""

# Verificar root
[ "$EUID" -eq 0 ] || err "Execute como root: sudo ./setup.sh"

# Verificar Ubuntu
UBUNTU_VER=$(lsb_release -rs 2>/dev/null || echo "unknown")
[ "$UBUNTU_VER" = "24.04" ] || warn "Testado no Ubuntu 24.04 (atual: $UBUNTU_VER)"

# Pre-requisitos
log "Instalando dependencias..."
apt-get update -qq
apt-get install -y -qq docker.io docker-compose-v2 git restic smartmontools ufw fail2ban

log "Iniciando Docker..."
systemctl enable --now docker

# Clonar repositorio (se nao existir)
REPO_DIR="/root/personal-cloud-backup"
if [ ! -d "$REPO_DIR" ]; then
  log "Clonando repositorio..."
  git clone https://github.com/Brian5m1th/personal-cloud-backup.git "$REPO_DIR"
fi

# Storage
read -p "Criar estrutura de diretorios em /srv/personal-cloud? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  log "Criando diretorios..."
  mkdir -p /srv/personal-cloud/{apps/volumes,config,backups,media,documents,photos,logs,tmp}
fi

# Docker network
log "Criando rede Docker..."
docker network create --driver bridge --attachable personal-cloud 2>/dev/null || warn "Rede personal-cloud ja existe"

# UFW
log "Configurando UFW..."
ufw allow 22/tcp
ufw --force enable

# Fail2ban
log "Configurando Fail2Ban..."
systemctl enable --now fail2ban

echo ""
echo "=== Setup concluido ==="
echo "Proximos passos:"
echo "  1. cd $REPO_DIR/docker/stacks/databases && docker compose up -d"
echo "  2. cd $REPO_DIR/docker/stacks/foundation && docker compose up -d"
echo "  3. cd $REPO_DIR/docker/stacks/nextcloud && docker compose up -d"
echo "  4. Acessar https://cloud.kaostech.com.br"
