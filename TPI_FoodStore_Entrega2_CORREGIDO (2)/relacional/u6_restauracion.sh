#!/usr/bin/env bash
# Food Store · restauración segura a una base NUEVA (no sobrescribe bases existentes).
# Uso: ./u6_restauracion.sh archivo.backup [nombre_base_destino]
# Credenciales: .pgpass o PGPASSFILE; nunca se guardan contraseñas en el script.
set -Eeuo pipefail

if (( $# < 1 || $# > 2 )); then
  echo "Uso: $0 <archivo_backup> [nombre_base_destino]" >&2
  exit 2
fi
ARCHIVO_BACKUP="$1"
DB_DESTINO="${2:-food_store_restaurada}"
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"
DB_USER="${DB_USER:-postgres}"

for herramienta in pg_restore createdb psql; do
  command -v "$herramienta" >/dev/null 2>&1 || { echo "ERROR: falta $herramienta en PATH." >&2; exit 127; }
done
[[ -f "$ARCHIVO_BACKUP" && -s "$ARCHIVO_BACKUP" ]] || { echo "ERROR: respaldo inexistente o vacío: $ARCHIVO_BACKUP" >&2; exit 1; }
# Validar que el archivo sea legible antes de crear la base.
pg_restore --list "$ARCHIVO_BACKUP" >/dev/null
# No se usa '|| true': nunca se restaura accidentalmente sobre una base existente.
if psql --host="$DB_HOST" --port="$DB_PORT" --username="$DB_USER" --dbname=postgres \
  --tuples-only --no-align --set=dbdest="$DB_DESTINO" --command="SELECT 1 FROM pg_database WHERE datname = :'dbdest'" | grep -q 1; then
  echo "ERROR: la base '$DB_DESTINO' ya existe. Elegí otro nombre; no se modificó." >&2
  exit 1
fi

INICIO="$(date +%s)"
echo "Creando base de destino: $DB_DESTINO"
createdb --host="$DB_HOST" --port="$DB_PORT" --username="$DB_USER" "$DB_DESTINO"
echo "Restaurando respaldo..."
pg_restore --exit-on-error --verbose --host="$DB_HOST" --port="$DB_PORT" \
  --username="$DB_USER" --dbname="$DB_DESTINO" "$ARCHIVO_BACKUP"
# Verificación genérica: comprueba conexión y que PostgreSQL pueda enumerar tablas.
psql --host="$DB_HOST" --port="$DB_PORT" --username="$DB_USER" --dbname="$DB_DESTINO" \
  --set=ON_ERROR_STOP=1 --command="SELECT current_database() AS base_restaurada, count(*) AS tablas_usuario FROM information_schema.tables WHERE table_schema NOT IN ('pg_catalog','information_schema') AND table_type='BASE TABLE';"
FIN="$(date +%s)"
echo "Restauración finalizada. Duración aproximada: $((FIN-INICIO)) segundos."
echo "La base original no fue modificada. Validá conteos y reglas de negocio antes de habilitar el servicio."
