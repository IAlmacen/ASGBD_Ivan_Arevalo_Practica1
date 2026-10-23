#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

echo "=== Arrancant els contenidors amb Docker Compose ==="
docker compose up -d --wait

echo "=== Esperant que el servei estiga operatiu ==="
sleep 5

echo "=== Executant scripts d'inicialització SQL ==="
docker exec -i postgres_db psql -U ${POSTGRES_USER:-admin_ivan} -d ${POSTGRES_DB:-postgres} < sql/01-tablespaces.sql
docker exec -i postgres_db psql -U ${POSTGRES_USER:-admin_ivan} -d ${POSTGRES_DB:-postgres} < sql/02-usuaris-rols.sql
docker exec -i postgres_db psql -U ${POSTGRES_USER:-admin_ivan} -d ${POSTGRES_DB:-postgres} < sql/03-dades-prova.sql

echo "=== Desplegament completat amb èxit! ==="