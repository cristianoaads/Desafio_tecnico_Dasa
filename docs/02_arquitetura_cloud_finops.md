# Performance, Arquitetura Cloud & FinOps

## BigQuery — particionamento e clustering

| Tabela | Partição | Clustering |
|---|---|---|
| fato_atendimento_item | DATE(data_hora_atendimento) | sk_paciente, sk_procedimento |
| fato_atendimento | DATE(data_hora_atendimento) | sk_paciente |
| dim_paciente | DATE(data_inicio_vigencia) | id_paciente |

Justificativa: o BigQuery cobra por **bytes escaneados**. As consultas típicas do BI filtram por período → partição diária faz partition pruning e reduz custo direto. require_partition_filter = true nas fatos impede varreduras completas acidentais. Clustering ordena blocos por sk_paciente/sk_procedimento (filtros e joins mais comuns), cortando blocos inteiros da leitura. Complementos de governança de custo: maximum_bytes_billed em ad-hoc, views materializadas para agregados de dashboard e monitoramento via INFORMATION_SCHEMA.JOBS.

## Snowflake — Virtual Warehouses

Lá o custo é **tempo de warehouse ligado** → isolamento de workloads:

- **WH_TRANSFORM** (Large, auto-suspend 60s): ELT pesado.
- **WH_BI** (Medium, auto-suspend 30s, multi-cluster 1–3, policy STANDARD): dashboards.
- **WH_ADHOC** (X-Small, auto-suspend 60s, statement timeout 300s): diretoria.

Resource monitors por warehouse = teto de gasto por carga.
