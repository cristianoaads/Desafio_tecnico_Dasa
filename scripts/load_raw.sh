#!/usr/bin/env bash
set -euo pipefail
PROJECT_ID="${GCP_PROJECT_ID:?Defina GCP_PROJECT_ID}"
RAW="saude_raw"

bq --project_id="$PROJECT_ID" mk --dataset --location=US "$RAW" 2>/dev/null || true

bq load --source_format=CSV --skip_leading_rows=1 --autodetect \
  "${PROJECT_ID}:${RAW}.raw_atendimentos" data/raw_atendimentos.csv

bq load --source_format=CSV --skip_leading_rows=1 --autodetect \
  "${PROJECT_ID}:${RAW}.raw_procedimentos_itens" data/raw_procedimentos_itens.csv

bq load --source_format=CSV --skip_leading_rows=1 --autodetect \
  "${PROJECT_ID}:${RAW}.raw_cadastro_pacientes" data/raw_cadastro_pacientes.csv

echo "✅ Camada raw carregada em ${RAW}"
