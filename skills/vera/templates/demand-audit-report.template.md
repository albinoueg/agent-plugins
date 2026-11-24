# #{{DEMAND_ID}} — {{DEMAND_TITLE}}: lançamentos de {{ASSIGNEE_NAME}}

- **Link:** {{REDMINE_BASE_URL}}/issues/{{DEMAND_ID}} · **Pai:** #{{PARENT_ID}} · **Responsável das subtarefas:** {{ASSIGNEE_NAME}} ({{ASSIGNEE_ID}})
- **Avaliado em:** {{AUDIT_DATE}}. **Escopo:** Auditoria de cobrança VERA (item de catálogo, U.M., faixa, nota de evidência, título, módulo e horas).
- **Commits conferidos no GitLab:**
  - `{{REPO_1}}` `{{COMMIT_SHA_1}}` ({{COMMIT_DATE_1}}): {{COMMIT_SUMMARY_1}};
  - `{{REPO_2}}` `{{COMMIT_SHA_2}}` ({{COMMIT_DATE_2}}): {{COMMIT_SUMMARY_2}}.
- **Outras subtarefas da demanda (sem responsável ou de outros membros):** {{OTHER_SUBTASKS_SUMMARY}}.

## Resumo

| Atividade | Status | Lançado | Correto (VERA) | UST lançadas → corretas |
|---|---|---|---|---|
| [#{{SUBTASK_ID_1}}]({{REDMINE_BASE_URL}}/issues/{{SUBTASK_ID_1}}) {{SUBTASK_SHORT_NAME_1}} | {{STATUS_1}} | `{{TAG_LANCADA_1}}` {{UM_LANCADA_1}}, faixa "{{FAIXA_1}}" | **{{UM_CORRETA_1}}** ({{VEREDITO_CURTO_1}}) | {{UST_LANCADA_1}} → {{UST_CORRETA_1}} |
| **Total** | | | | **{{TOTAL_UST_LANCADAS}} → {{TOTAL_UST_CORRETAS}}** |

**UST por U.M. (`./catalogs/catalogo-atividades.yaml`):**
- `[backend]`: 4, ou 8 na faixa "4 ou mais".
- `[backend-alteracao]`: 2, ou 4 na faixa "4 ou mais".
- `[teste-unitario]`: 4 na faixa "3 ou menos" (ou 8 na faixa "4 ou mais").
- `[frontend]`: 4.
- `[frontend-alteracao]`: 1.

**Regra aplicada nos testes unitários:** **1 U.M. de teste por item cobrado que o teste cobre** ("funcionalidade coberta" do catálogo aplicada à mesma contagem das unidades elementares do código).

---

## {{MODULE_GROUP_TITLE}} (`{{REPO_PATHS}}`)

### #{{SUBTASK_ID_1}}: `{{TAG_LANCADA_1}}` × {{UM_LANCADA_1}} → **{{VEREDITO_TITULO_1}}**
Commit `{{COMMIT_SHA_1}}`. {{RESUMO_ENTREGA_SUBTAREFA_1}}:

| # | Método / Item | Conta | Por quê |
|---|---|---|---|
| 1 | `{{METODO_OU_COMPONENTE_1}}` | {{UM_ITEM_1}} | {{JUSTIFICATIVA_ITEM_1}} |
| — | `{{ITEM_DESCONSIDERADO_1}}` | 0 | {{MOTIVO_EXCLUSAO_1}} (`[desconsiderado]`) |
| | **Total** | **{{UM_CORRETA_1}}** | faixa "{{FAIXA_CORRETA_1}}" |

**Ajustes e observações de auditoria:**
- {{AJUSTE_MODULO_OU_TITULO}}
- {{AJUSTE_CAMINHOS_OU_LINKS_DE_COMMIT}}
- {{AJUSTE_RECORRENCIA_OU_SERVICO_SIMULADO}}

---

## O que fazer, por atividade

1. **#{{SUBTASK_ID_1}}** ({{STATUS_1}}): {{ACAO_RECOMENDADA_1}}.
2. **#{{SUBTASK_ID_2}}** ({{STATUS_2}}): {{ACAO_RECOMENDADA_2}}.
