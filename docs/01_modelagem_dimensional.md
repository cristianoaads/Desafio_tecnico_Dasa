# Modelagem Dimensional (Kimball)

## Fatos

- **FATO_ATENDIMENTO_ITEM** (principal): grão = 1 item de procedimento executado. Medidas: valor_item, desconto_rateado_final, valor_liquido_item.
- **FATO_ATENDIMENTO**: grão = 1 atendimento. Medidas financeiras do cabeçalho + qtd_itens. Permite conciliação direta com o faturamento.

## Dimensões

- **DIM_PACIENTE — SCD Tipo 2**: cada alteração cadastral (plano/cidade) cria nova versão com data_inicio_vigencia, data_fim_vigencia e is_vigente. A fato usa **point-in-time join** (vigência contém data_hora_atendimento), garantindo que o histórico mantém o plano vigente na data do procedimento.
- **DIM_PROCEDIMENTO, DIM_MEDICO, DIM_UNIDADE** — conformadas (Type 1).
- **DIM_TEMPO** — estática, sk_data = YYYYMMDD.
- **tipo_atendimento e status** — dimensões degeneradas na fato (baixa cardinalidade; evita joins sem ganho analítico).

## Surrogate Keys

Geradas via TO_HEX(MD5(chave_natural + atributos de vigência)): determinísticas, idempotentes e desacopladas dos sistemas de origem. sk_data = inteiro YYYYMMDD.

## Rateio de desconto

desconto_rateado = desconto_do_atendimento × (valor_item / Σ valor_itens), com resíduo de arredondamento atribuído ao último item — a soma fecha exato com o cabeçalho (testado por test_rateio_soma_exata.sql).
