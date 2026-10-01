-- Integridade referencial: item sem atendimento pai
SELECT i.id_item
FROM `__DATASET__.stg_procedimentos_itens` i
LEFT JOIN `__DATASET__.stg_atendimentos` a USING (id_atendimento)
WHERE a.id_atendimento IS NULL;
