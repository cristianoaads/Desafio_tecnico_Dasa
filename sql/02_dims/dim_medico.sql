CREATE OR REPLACE TABLE `__DATASET__.dim_medico` CLUSTER BY id_medico AS
SELECT
  TO_HEX(MD5(id_medico_executante)) AS sk_medico,
  id_medico_executante              AS id_medico
FROM (
  SELECT DISTINCT id_medico_executante
  FROM `__DATASET__.stg_procedimentos_itens`
  WHERE id_medico_executante IS NOT NULL
);
