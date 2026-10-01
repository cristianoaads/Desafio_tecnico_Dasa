-- Vigências SCD2 não podem se sobrepor
SELECT a.id_paciente, a.data_inicio_vigencia, b.data_inicio_vigencia AS inicio_conflitante
FROM `__DATASET__.dim_paciente` a
JOIN `__DATASET__.dim_paciente` b
  ON a.id_paciente = b.id_paciente
 AND a.sk_paciente < b.sk_paciente
 AND a.data_inicio_vigencia < b.data_fim_vigencia
 AND b.data_inicio_vigencia < a.data_fim_vigencia;
