# Diretório de Templates de Relatórios (`templates/`)

> **Status (`v0.2.0`):** Template oficial de Proposta e Auditoria de UST ([`ust-validation-report.template.md`](./ust-validation-report.template.md)) disponível para uso imediato por qualquer LLM; geração automatizada via scripts prevista para a `v0.6.0` conforme o [`ROADMAP.md`](../ROADMAP.md).

---

## 1. Arquivos Disponíveis

| Arquivo | Descrição |
| :--- | :--- |
| [`demand-audit-report.template.md`](./demand-audit-report.template.md) | **Template oficial de Relatório Consolidado de Auditoria por Demanda-Mãe.** Utilizado no comando `"Gerar relatório da demanda [123456]"`. Apresenta resumo da demanda, quadro comparativo de todas as subtarefas (`Lançado vs. Correto` e `UST lançadas -> corretas`), análise individualizada por subtarefa/repositório e lista objetiva `"O que fazer, por atividade"`. |
| [`ust-validation-report.template.md`](./ust-validation-report.template.md) | **Template padrão de relatório individual de validação e proposta de UST.** Estrutura a saída com resumo funcional, quadro de enquadramento, detalhamento por Unidade Elementar, seção explícita de itens desconsiderados (`[desconsiderado] — 0 UM`), confronto `Categoria + UM` (Previsto vs. Real), questões para revisão humana e checklist de publicação. |
| [`redmine-task-note.template.md`](./redmine-task-note.template.md) | **Template oficial de Nota de Lançamento de Evidência no Redmine (Padrão Enxuto — Fiscal Sr. Edilson).** Formato ultra-enxuto para apontamento de tarefas no Redmine: commit no topo, blocos de unidade elementar separados por `---`, comportamento entregue conciso, caminho do arquivo/classe, método e linhas (obrigatório para atividades de alteração). |
| [`redmine-script-note.template.md`](./redmine-script-note.template.md) | **Template oficial de Nota de Tarefa de Script no Redmine.** Formato padrão para tarefas de elaboração/execução de scripts SQL: breve descrição da operação, tabelas afetadas e código SQL formatado com `<pre><code class="sql">...</code></pre>`. |
| [`redmine-deploy-note.template.md`](./redmine-deploy-note.template.md) | **Template oficial de Nota de Lançamento de Deploy no Redmine.** Formato padrão para registro cumulativo de deploy: cabeçalho `*1 Unidade: Merge + Deploy*`, links do commit de merge e do pipeline no GitLab, e print do pipeline incorporado inline. |

---

## 2. Diretrizes de Preenchimento do Relatório pela LLM

1. **Nunca tratar a saída como faturamento aprovado:** Todo relatório gerado deve manter o status `PROPOSTA TÉCNICA — AGUARDANDO REVISÃO HUMANA` até validação formal.
2. **Transparência sobre Exclusões (`[desconsiderado] — 0 UM`):** Métodos ou arquivos ignorados no diff (getters/setters, delegação entre camadas, formatação, logs puros, funções mecânicas de reset/UI ou 2º+ enum no mesmo commit) devem ser listados na Seção 5 do relatório para demonstrar que foram auditados e conscientemente excluídos da cobrança.
3. **Estilo Técnico e Verificável:** Utilizar verbos objetivos (*implementado*, *alterado*, *criado*) apenas quando demonstrados pelo *diff* ou artefato anexo. Nunca afirmar que testes foram executados ou que uma atividade teve autorização prévia sem evidência explícita.
4. **Proteção de Dados (LGPD e Segredos):** Mascarar qualquer CPF, CNPJ, credencial, token ou dado pessoal antes de produzir o documento Markdown.
