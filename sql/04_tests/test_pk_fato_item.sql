-- Unicidade da PK da fato de itens
SELECT sk_item, COUNT(*) AS ocorrencias
FROM `__DATASET__.fato_atendimento_item`
GROUP BY sk_item HAVING COUNT(*) > 1;
