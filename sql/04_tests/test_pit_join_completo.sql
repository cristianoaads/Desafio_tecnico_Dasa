-- Todo atendimento deve ter encontrado uma versão SCD2 vigente
SELECT a.id_atendimento
FROM `__DATASET__.stg_atendimentos` a
LEFT JOIN `__DATASET__.fato_atendimento` f USING (id_atendimento)
WHERE f.sk_atendimento IS NULL;
