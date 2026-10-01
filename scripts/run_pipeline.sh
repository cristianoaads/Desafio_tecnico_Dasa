#!/usr/bin/env bash
# Uso: ./run_pipeline.sh <dataset>   (padrão: saude_analytics)
set -euo pipefail
DATASET="${1:-saude_analytics}"

run_sql() {
  echo "▶ Executando: $1"
  sed "s/__DATASET__/$DATASET/g" "$1" | bq query --use_legacy_sql=false
}

for f in sql/01_staging/*.sql sql/02_dims/*.sql sql/03_facts/*.sql; do
  run_sql "$f"
done

echo "✅ Pipeline dimensional construído em ${DATASET}"
