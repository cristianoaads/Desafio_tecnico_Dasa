-- sk_data = YYYYMMDD (inteiro compacto e legível)
CREATE OR REPLACE TABLE `__DATASET__.dim_tempo` CLUSTER BY sk_data AS
WITH datas AS (
  SELECT dia
  FROM UNNEST(GENERATE_DATE_ARRAY(
    DATE '2023-01-01',
    DATE '2025-12-31',
    INTERVAL 1 DAY
  )) AS dia
)
SELECT
  CAST(FORMAT_DATE('%Y%m%d', dia) AS INT64) AS sk_data,
  dia                                        AS data_completa,
  EXTRACT(YEAR      FROM dia)                AS ano,
  EXTRACT(QUARTER   FROM dia)                AS trimestre,
  EXTRACT(MONTH     FROM dia)                AS mes,
  FORMAT_DATE('%B', dia)                     AS nome_mes,
  EXTRACT(WEEK      FROM dia)                AS semana_ano,
  FORMAT_DATE('%A', dia)                     AS dia_semana,
  EXTRACT(DAYOFWEEK FROM dia) IN (1, 7)      AS is_fim_de_semana
FROM datas;
