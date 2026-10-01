# DevOps, CI/CD & Governança

## Slim CI (GitHub Actions)

- A cada PR: lint (SQLFluff) → build completo em dataset isolado ci_pr_<nº> → execução dos 7 testes de qualidade. Qualquer violação bloqueia o merge.
- O placeholder __DATASET__ nos SQLs permite reusar o mesmo código no schema isolado e em produção — sem branches de ambiente.
- Merge na main → deploy em saude_analytics + testes em produção.

## Versionamento e branches

Trunk-based: main sempre deployável, branches curtas de feature, PR com 1 review. Ambientes são datasets/targets, não branches — evita drift de código.

## Catálogo de dados

- README + docs/ como catálogo versionado junto do código (nunca defasado).
- Contrato de dados nas views de staging (colunas, tipos, semântica).
- Glossário de negócio no README — resolve divergências de definição ("atendimento concluído", o que entra no desconto), que são a causa raiz das divergências de relatórios citadas no contexto do desafio.
