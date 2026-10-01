-- Campos críticos não podem ser nulos
SELECT id_atendimento, 'valor_liquido' AS campo
FROM `__DATASET__.stg_atendimentos` WHERE valor_liquido IS NULL
UNION ALL
SELECT id_item, 'valor_item'
FROM `__DATASET__.stg_procedimentos_itens` WHERE valor_item IS NULL;
