-- Dimensão conformada (Type 1)
CREATE OR REPLACE TABLE `__DATASET__.dim_procedimento` CLUSTER BY codigo_procedimento AS
SELECT
  TO_HEX(MD5(codigo_procedimento)) AS sk_procedimento,
  codigo_procedimento,
  nome_procedimento
FROM (
  SELECT DISTINCT codigo_procedimento, nome_procedimento
  FROM `__DATASET__.stg_procedimentos_itens`
  QUALIFY ROW_NUMBER() OVER (
    PARTITION BY codigo_procedimento ORDER BY nome_procedimento
  ) = 1
);
