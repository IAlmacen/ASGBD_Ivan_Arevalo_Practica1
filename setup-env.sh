#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

echo "=== Arrancant els contenidors amb Docker Compose ==="
docker compose up -d
sleep 10

echo "=== Assegurant permisos als directoris de tablespaces ==="
docker exec -u root postgres_db mkdir -p /mnt/tablespaces/erp /mnt/tablespaces/rrhh
docker exec -u root postgres_db chown -R postgres:postgres /mnt/tablespaces


echo "=== Executant scripts d'inicialització SQL ==="
docker exec -i postgres_db psql -U ${POSTGRES_USER:-admin_ivan} -d ${POSTGRES_DB:-postgres} < sql/01-tablespaces.sql
docker exec -i postgres_db psql -U ${POSTGRES_USER:-admin_ivan} -d ${POSTGRES_DB:-postgres} < sql/02-usuaris-rols.sql
docker exec -i postgres_db psql -U ${POSTGRES_USER:-admin_ivan} -d ${POSTGRES_DB:-postgres} < sql/03-dades-prova.sql

echo "=== Desplegament completat amb èxit! ==="