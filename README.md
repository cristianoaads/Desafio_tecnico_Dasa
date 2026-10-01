# Desafio Técnico — Analytics Engineering

Modelagem dimensional (Kimball), pipelines SQL para BigQuery, qualidade de dados, FinOps e CI/CD para uma rede de saúde e medicina diagnóstica.

## Stack
- **DW**: Google BigQuery (SQL puro — DDL/DML/CTEs, sem framework de transformação)
- **CI/CD**: GitHub Actions (Slim CI com dataset isolado por PR)
- **Lint**: SQLFluff (dialeto bigquery)

## Arquitetura de camadas

RAW (CSVs) → STAGING (views de limpeza/tipagem) → DIMENSIONAL (Data Mart Kimball)

## Modelo (resumo)

| Tabela | Tipo | Granularidade |
|---|---|---|
| FATO_ATENDIMENTO_ITEM | Fato principal | 1 linha por item de procedimento |
| FATO_ATENDIMENTO | Fato de cabeçalho | 1 linha por atendimento |
| DIM_PACIENTE | Dimensão SCD Tipo 2 | 1 linha por versão cadastral |
| DIM_PROCEDIMENTO / DIM_MEDICO / DIM_UNIDADE | Dimensões conformadas | 1 linha por entidade |
| DIM_TEMPO | Dimensão estática | 1 linha por dia (sk_data = YYYYMMDD) |

Decisões-chave (detalhes em docs/):
- **SCD Tipo 2** em DIM_PACIENTE com point-in-time join: o atendimento histórico mantém o plano de saúde vigente na data do procedimento.
- **Rateio proporcional de desconto** por item, com correção de resíduo de arredondamento no último item — SUM(desconto_rateado) = desconto exato.
- **Surrogate Keys determinísticas** via TO_HEX(MD5(...)) — pipeline idempotente.
- **Partição diária + clustering** nas fatos (ver docs/02) para reduzir bytes escaneados.

## Como executar

```bash
# 1. Autenticação e projeto
gcloud auth application-default login
export GCP_PROJECT_ID=seu-projeto

# 2. Carga da camada raw (cria dataset saude_raw e carrega os CSVs de data/)
./scripts/load_raw.sh

# 3. Build do pipeline dimensional (dataset padrão: saude_analytics)
./scripts/run_pipeline.sh saude_analytics

# 4. Testes de qualidade (falha se qualquer teste retornar violações)
./scripts/run_tests.sh saude_analytics
```

## Estrutura

- sql/01_staging/ — views de limpeza, tipagem e deduplicação
- sql/02_dims/ — dimensões (SCD2 + conformadas + tempo)
- sql/03_facts/ — fatos com rateio e point-in-time join
- sql/04_tests/ — testes de qualidade (cada um retorna violações, se existirem)
- scripts/ — carga, build e testes via bq CLI
- docs/ — justificativas técnicas (modelagem, FinOps, CI/CD)

## CI/CD

A cada PR: lint SQLFluff + build completo em dataset isolado ci_pr_<nº> + execução dos 7 testes. Merge na main faz deploy em produção. Detalhes: docs/03_cicd_governanca.md e .github/workflows/ci.yml.

## Glossário de negócio

- **Atendimento concluído**: atendimento com status 'Concluído' — entra nas métricas de faturamento.
- **Desconto**: valor abatido do valor_bruto no cabeçalho do atendimento; rateado proporcionalmente entre os itens.
- **Valor líquido**: valor_bruto - desconto.

## Glossário técnico

- **SCD Tipo 2**: técnica de versionamento de dimensão que preserva o histórico de mudanças de atributos (ex.: troca de plano de saúde) via vigências.
- **Point-in-time join**: junção da fato com a versão da dimensão vigente na data do evento.
- **Surrogate Key (SK)**: chave artificial gerada no DW, desacoplada das chaves dos sistemas de origem.
- **Slim CI**: estratégia de CI que constrói e testa apenas modelos alterados e seus dependentes, em ambiente isolado por PR.
