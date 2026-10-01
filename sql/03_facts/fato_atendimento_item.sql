-- Grão: 1 linha por item de procedimento.
-- Rateio proporcional do desconto + correção de resíduo no último item.
-- Point-in-time join com DIM_PACIENTE (SCD2).
CREATE OR REPLACE TABLE `__DATASET__.fato_atendimento_item`
PARTITION BY DATE(data_hora_atendimento)
CLUSTER BY sk_paciente, sk_procedimento AS
WITH base_itens AS (
  SELECT
    i.id_item,
    i.id_atendimento,
    i.codigo_procedimento,
    i.id_medico_executante,
    i.valor_item,
    a.id_paciente,
    a.data_hora_atendimento,
    a.tipo_atendimento,
    a.status,
    a.id_unidade,
    a.desconto,
    SUM(i.valor_item) OVER (PARTITION BY i.id_atendimento) AS soma_itens
  FROM `__DATASET__.stg_procedimentos_itens` i
  JOIN `__DATASET__.stg_atendimentos` a
    ON i.id_atendimento = a.id_atendimento
),
rateio AS (
  SELECT
    *,
    CASE
      WHEN soma_itens > 0 THEN ROUND(desconto * valor_item / soma_itens, 2)
      ELSE 0
    END AS desconto_rateado
  FROM base_itens
),
correcao_residuo AS (
  SELECT
    *,
    desconto - SUM(desconto_rateado) OVER (PARTITION BY id_atendimento) AS residuo,
    ROW_NUMBER() OVER (
      PARTITION BY id_atendimento ORDER BY id_item DESC
    ) AS rn_ultimo
  FROM rateio
)
SELECT
  TO_HEX(MD5(it.id_item))                                        AS sk_item,
  it.id_item,
  it.id_atendimento,
  p.sk_paciente,          -- versão SCD2 vigente NA DATA do atendimento
  pr.sk_procedimento,
  m.sk_medico,
  u.sk_unidade,
  CAST(FORMAT_DATE('%Y%m%d', DATE(it.data_hora_atendimento)) AS INT64) AS sk_data,
  it.data_hora_atendimento,
  it.tipo_atendimento,    -- dimensão degenerada
  it.status,              -- dimensão degenerada
  it.valor_item,
  it.desconto_rateado + CASE WHEN rn_ultimo = 1 THEN residuo ELSE 0 END AS desconto_rateado_final,
  it.valor_item - (it.desconto_rateado + CASE WHEN rn_ultimo = 1 THEN residuo ELSE 0 END) AS valor_liquido_item
FROM correcao_residuo it
JOIN `__DATASET__.dim_paciente` p
  ON  it.id_paciente = p.id_paciente
  AND it.data_hora_atendimento >= p.data_inicio_vigencia
  AND it.data_hora_atendimento <  p.data_fim_vigencia
JOIN `__DATASET__.dim_procedimento` pr ON it.codigo_procedimento = pr.codigo_procedimento
JOIN `__DATASET__.dim_medico`        m  ON it.id_medico_executante = m.id_medico
JOIN `__DATASET__.dim_unidade`       u  ON it.id_unidade = u.id_unidade;
