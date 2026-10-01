-- Consistência monetária: valor_bruto - desconto = valor_liquido
SELECT id_atendimento, valor_bruto, desconto, valor_liquido
FROM `__DATASET__.stg_atendimentos`
WHERE ABS(valor_bruto - desconto - valor_liquido) > 0.01;
