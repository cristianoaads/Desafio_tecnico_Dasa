-- Staging: itens de procedimento deduplicados por id_item
CREATE OR REPLACE VIEW `__DATASET__.stg_procedimentos_itens` AS
WITH dedupe AS (
  SELECT
    *,
    ROW_NUMBER() OVER (PARTITION BY id_item ORDER BY id_atendimento) AS rn
  FROM `saude_raw.raw_procedimentos_itens`
  WHERE id_item IS NOT NULL
)
SELECT
  TRIM(id_item)                 AS id_item,
  TRIM(id_atendimento)          AS id_atendimento,
  TRIM(codigo_procedimento)     AS codigo_procedimento,
  TRIM(nome_procedimento)       AS nome_procedimento,
  TRIM(id_medico_executante)    AS id_medico_executante,
  CAST(valor_item AS NUMERIC)   AS valor_item
FROM dedupe
WHERE rn = 1;
