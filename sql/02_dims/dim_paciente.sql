-- SCD Tipo 2: cada mudança cadastral gera nova versão com vigência.
CREATE OR REPLACE TABLE `__DATASET__.dim_paciente`
PARTITION BY DATE(data_inicio_vigencia) CLUSTER BY id_paciente AS
WITH vigencia AS (
  SELECT
    id_paciente, nome, plano_saude, cidade, data_atualizacao,
    LEAD(data_atualizacao) OVER (
      PARTITION BY id_paciente ORDER BY data_atualizacao
    ) AS proxima_atualizacao
  FROM `__DATASET__.stg_cadastro_pacientes`
  QUALIFY ROW_NUMBER() OVER (
    PARTITION BY id_paciente, data_atualizacao ORDER BY nome
  ) = 1  -- deduplica registros com mesmo timestamp
)
SELECT
  TO_HEX(MD5(CONCAT(id_paciente, '|', CAST(data_atualizacao AS STRING)))) AS sk_paciente,
  id_paciente,
  nome,
  plano_saude,
  cidade,
  data_atualizacao                          AS data_inicio_vigencia,
  COALESCE(proxima_atualizacao, TIMESTAMP '9999-12-31 00:00:00') AS data_fim_vigencia,
  proxima_atualizacao IS NULL               AS is_vigente
FROM vigencia;
