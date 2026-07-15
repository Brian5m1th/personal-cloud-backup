#!/bin/bash
# generate-inventory.sh — Gera inventario do servidor
# Uso: ./generate-inventory.sh [output-dir]

OUTPUT_DIR="${1:-/srv/personal-cloud/inventory}"
mkdir -p "$OUTPUT_DIR"

echo "=== Gerando inventario em $OUTPUT_DIR ==="

# Hardware
{
  echo "# Hardware Inventory"
  echo "## CPU"
  lscpu | grep -E "Model name|Socket|Core|Thread|CPU MHz"
  echo "## RAM"
  free -h
  echo "## Disco"
  lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT | grep -v loop
} > "$OUTPUT_DIR/hardware.yaml"

# Docker
{
  echo "# Docker Inventory"
  docker info --format 'Version: {{.ServerVersion}}'
  docker ps -a --format json
} > "$OUTPUT_DIR/docker.yaml" 2>/dev/null

# Containers
docker ps --format '{{json .}}' > "$OUTPUT_DIR/containers.yaml" 2>/dev/null

# Networks
docker network ls --format '{{json .}}' > "$OUTPUT_DIR/networks.yaml" 2>/dev/null

# Volumes
docker volume ls --format '{{json .}}' > "$OUTPUT_DIR/volumes.yaml" 2>/dev/null

# Portas
ss -tlnp > "$OUTPUT_DIR/ports.yaml" 2>/dev/null

# Usuarios
cat /etc/passwd | grep -E "/home|/root" | cut -d: -f1,3,7 > "$OUTPUT_DIR/users.yaml" 2>/dev/null

echo "=== Inventario gerado ==="
ls -la "$OUTPUT_DIR/"
