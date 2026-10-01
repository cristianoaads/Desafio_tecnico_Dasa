-- Grão: 1 linha por atendimento (cabeçalho financeiro).
CREATE OR REPLACE TABLE `__DATASET__.fato_atendimento`
PARTITION BY DATE(data_hora_atendimento)
CLUSTER BY sk_paciente AS
SELECT
  TO_HEX(MD5(a.id_atendimento))                                  AS sk_atendimento,
  a.id_atendimento,
  p.sk_paciente,
  u.sk_unidade,
  CAST(FORMAT_DATE('%Y%m%d', DATE(a.data_hora_atendimento)) AS INT64) AS sk_data,
  a.data_hora_atendimento,
  a.tipo_atendimento,
  a.status,
  a.valor_bruto,
  a.desconto,
  a.valor_liquido,
  COUNT(i.id_item)                                               AS qtd_itens
FROM `__DATASET__.stg_atendimentos` a
JOIN `__DATASET__.dim_paciente` p
  ON  a.id_paciente = p.id_paciente
  AND a.data_hora_atendimento >= p.data_inicio_vigencia
  AND a.data_hora_atendimento <  p.data_fim_vigencia
JOIN `__DATASET__.dim_unidade` u ON a.id_unidade = u.id_unidade
LEFT JOIN `__DATASET__.stg_procedimentos_itens` i
  ON i.id_atendimento = a.id_atendimento
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11;
