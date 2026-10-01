-- Staging: tipagem, trim e deduplicação dos atendimentos
CREATE OR REPLACE VIEW `__DATASET__.stg_atendimentos` AS
WITH dedupe AS (
  SELECT
    *,
    ROW_NUMBER() OVER (PARTITION BY id_atendimento ORDER BY data_hora_atendimento DESC) AS rn
  FROM `saude_raw.raw_atendimentos`
  WHERE id_atendimento IS NOT NULL
)
SELECT
  TRIM(id_atendimento)                          AS id_atendimento,
  TRIM(id_paciente)                             AS id_paciente,
  PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', data_hora_atendimento) AS data_hora_atendimento,
  TRIM(tipo_atendimento)                        AS tipo_atendimento,
  TRIM(id_unidade)                              AS id_unidade,
  TRIM(status)                                  AS status,
  CAST(valor_bruto   AS NUMERIC)                AS valor_bruto,
  CAST(desconto      AS NUMERIC)                AS desconto,
  CAST(valor_liquido AS NUMERIC)                AS valor_liquido
FROM dedupe
WHERE rn = 1;
