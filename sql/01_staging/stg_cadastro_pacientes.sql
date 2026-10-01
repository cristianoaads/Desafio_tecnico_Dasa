-- Staging: log cadastral de pacientes
CREATE OR REPLACE VIEW `__DATASET__.stg_cadastro_pacientes` AS
SELECT
  TRIM(id_paciente)        AS id_paciente,
  TRIM(nome)               AS nome,
  TRIM(plano_saude)        AS plano_saude,
  TRIM(cidade)             AS cidade,
  PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', data_atualizacao) AS data_atualizacao
FROM `saude_raw.raw_cadastro_pacientes`
WHERE id_paciente IS NOT NULL
  AND data_atualizacao IS NOT NULL;
