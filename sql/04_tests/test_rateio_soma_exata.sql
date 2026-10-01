-- Rateio fecha exatamente com o desconto do cabeçalho
SELECT f.id_atendimento,
       SUM(f.desconto_rateado_final) AS desconto_rateado_total,
       a.desconto AS desconto_cabecalho
FROM `__DATASET__.fato_atendimento_item` f
JOIN `__DATASET__.stg_atendimentos` a USING (id_atendimento)
GROUP BY 1, 3
HAVING ABS(SUM(f.desconto_rateado_final) - a.desconto) > 0.01;
