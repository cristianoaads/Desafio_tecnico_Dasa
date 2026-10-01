#!/usr/bin/env bash
# Uso: ./run_tests.sh <dataset>   (padrão: saude_analytics)
# Cada teste retorna violações; qualquer linha retornada = falha.
set -euo pipefail
DATASET="${1:-saude_analytics}"
fail=0

for f in sql/04_tests/*.sql; do
  rows=$(sed "s/__DATASET__/$DATASET/g" "$f" \
    | bq query --use_legacy_sql=false --format=csv --max_rows=1 \
    | tail -n +2 | wc -l)
  if [ "$rows" -gt 0 ]; then
    echo "❌ FALHOU: $f ($rows violação(ões))"
    fail=1
  else
    echo "✅ OK: $f"
  fi
done

exit $fail
