#!/usr/bin/env bash
# Food Store · respaldo programado PostgreSQL
# Requisitos: pg_dump, permisos de conexión y credenciales mediante .pgpass/PGPASSFILE.
# Uso: DB_NAME=food_store BACKUP_DIR="$HOME/respaldos" ./u6_backup_programado.sh
set -Eeuo pipefail

DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"
DB_USER="${DB_USER:-postgres}"
DB_NAME="${DB_NAME:-food_store}"
BACKUP_DIR="${BACKUP_DIR:-./respaldos}"
RETENCION_DIAS="${RETENCION_DIAS:-7}"

if ! command -v pg_dump >/dev/null 2>&1; then
  echo "ERROR: pg_dump no está en PATH." >&2
  exit 127
fi
if ! [[ "$RETENCION_DIAS" =~ ^[0-9]+$ ]] || (( RETENCION_DIAS < 1 )); then
  echo "ERROR: RETENCION_DIAS debe ser un entero mayor que cero." >&2
  exit 2
fi
mkdir -p "$BACKUP_DIR"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
ARCHIVO_BACKUP="$BACKUP_DIR/${DB_NAME}_${TIMESTAMP}.backup"
ARCHIVO_TEMP="${ARCHIVO_BACKUP}.tmp"
ARCHIVO_LOG="$BACKUP_DIR/backup_${TIMESTAMP}.log"
trap 'rm -f "$ARCHIVO_TEMP"' ERR

{
  echo "=== Inicio de respaldo: $(date) ==="
  echo "Base: $DB_NAME | Host: $DB_HOST:$DB_PORT | Usuario: $DB_USER"
  pg_dump --host="$DB_HOST" --port="$DB_PORT" --username="$DB_USER" \
    --dbname="$DB_NAME" --format=custom --blobs --verbose --file="$ARCHIVO_TEMP"
  test -s "$ARCHIVO_TEMP"
  mv "$ARCHIVO_TEMP" "$ARCHIVO_BACKUP"
  echo "Respaldo completado: $ARCHIVO_BACKUP"
  echo "=== Limpieza de archivos con más de $RETENCION_DIAS días ==="
  find "$BACKUP_DIR" -type f -name "${DB_NAME}_*.backup" -mtime "+$RETENCION_DIAS" -print -delete
  find "$BACKUP_DIR" -type f -name "backup_*.log" -mtime "+$RETENCION_DIAS" -print -delete
  echo "=== Fin: $(date) ==="
} 2>&1 | tee "$ARCHIVO_LOG"
