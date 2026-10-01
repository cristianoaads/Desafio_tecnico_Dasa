CREATE OR REPLACE TABLE `__DATASET__.dim_unidade` CLUSTER BY id_unidade AS
SELECT
  TO_HEX(MD5(id_unidade)) AS sk_unidade,
  id_unidade
FROM (
  SELECT DISTINCT id_unidade
  FROM `__DATASET__.stg_atendimentos`
  WHERE id_unidade IS NOT NULL
);
