# [{{TAG_CATALOGO}}] {{TITULO_OBJETIVO_ATIVIDADE}}

**Demanda Redmine:** {{ID_DEMANDA_OU_PENDENTE}}
**Repositório / Branch:** {{REPOSITORIO_E_BRANCH}}
**Commit(s):** {{HASH_E_URL_OU_PENDENTE_PRE_COMMIT}}
**Escopo de Comparação:** {{ESCOPO_DIFF_EX_WORKING_TREE_OU_COMMITS}}
**Status de Auditoria Redmine:** {{STATUS_COBRANCA_EX_PROPOSTA_OU_100_COBRADO_OU_PENDENTE_HORAS}}
**Situação do Documento:** PROPOSTA TÉCNICA — AGUARDANDO REVISÃO HUMANA

---

## 1. Resumo Funcional
{{DESCRICAO_CONCISA_DO_PROBLEMA_E_RESULTADO_OBSERVAVEL_SEM_AFIRMAR_TESTES_NAO_COMPROVADOS}}

---

## 2. Enquadramento e Contagem Proposta

| Tag do Catálogo | Descrição Resumida | Unidade de Medida (Catálogo) | Qtde Elegível (UM) | UST / UM | Subtotal (UST) | Classificação da Evidência | Observações / Complexidade |
| :--- | :--- | :--- | :---: | :---: | :---: | :---: | :--- |
| `{{TAG}}` | {{TITULO_ITEM}} | {{UNIDADE_MEDIDA}} | {{QTD_UM}} | {{UST_UNIT}} | **{{SUBTOTAL_UST}}** | `{{EVIDENCIA_VERIFICADA_OU_INFERENCIA_OU_AUSENTE}}` | {{OBS_COMPLEXIDADE_OU_GARANTIA}} |

**Total Proposto:** **{{TOTAL_UST}} UST** *(sujeito à validação humana — memória de cálculo: `{{MEMORIA_CALCULO}}`)*

---

## 3. Unidades Elementares / Entregas Verificáveis

### Unidade 1 — {{TITULO_VERIFICAVEL_DA_UNIDADE}}
- **Comportamento Entregue / Valor de Negócio:** {{COMPORTAMENTO_OBSERVAVEL}}
- **Atividade do Catálogo:** `{{TAG_CATALOGO}}` — {{TITULO_CATALOGO}}
- **Classificação Epistemológica:** `EVIDENCIA_VERIFICADA` | `INFERENCIA_TECNICA` | `INFORMACAO_AUSENTE`
- **Evidências Técnicas:**
  - `{{CAMINHO_ARQUIVO}}`: `{{CLASSE_OU_COMPONENTE}}.{{METODO_OU_ELEMENTO}}` — linhas {{LINHA_INICIO}}–{{LINHA_FIM}} *(ou anexo/registro Redmine)*
- **Validação / Testes:** {{TESTES_COMPROVADOS_OU_NAO_INFORMADO}}
- **Contagem / Justificativa (Acordo Economia/CAST):** {{JUSTIFICATIVA_COESAO_VALOR_NEGOCIO_OU_REGRA_ENUM}}
- **Recorrência na Mesma Demanda:** {{NAO_RECORRENTE_OU_JUSTIFICATIVA_NOVA_ALTERACAO}}
- **Grau de Confiança:** `Alta` | `Média` | `Baixa`
- **Pendências:** {{PENDENCIAS_OU_NENHUMA}}

---

## 4. Evidências dos Commits e Artefatos
- {{LISTA_DE_URLS_DE_COMMITS_ANEXOS_OU_PENDENTE}}

---

## 5. Itens Desconsiderados (`[desconsiderado] — 0 UM`) e Prevenção de Duplicidade
*(Listagem explícita dos artefatos analisados no diff que não foram contabilizados conforme o acordo Economia/CAST)*
- `{{ARQUIVO_OU_METODO_DESCONSIDERADO}}`: `[desconsiderado] — 0 UM` — **Motivo:** {{EX_GETTER_SETTER_DELEGACAO_CAMADA_FORMATACAO_LOG_PURO_OU_METODO_ACESSORIO_UI}}

---

## 6. Confronto Previsto vs. Real no Redmine *(Quando Aplicável)*

| Categoria (`Tag`) | UMs Apuradas (Git/Evidências) | UMs Registradas (Redmine) | Horas Lançadas (`spent_hours`) | Diagnóstico |
| :--- | :---: | :---: | :---: | :--- |
| `{{TAG}}` | {{UM_PREVISTA}} | {{UM_REAL}} | {{HORAS}}h | `{{CONFORME_OU_DISPARIDADE_OU_PENDENTE_DE_HORAS}}` |

---

## 7. Questões para Revisão Humana
- {{PERGUNTAS_SOBRE_RECORRENCIA_GARANTIA_AUTORIZACAO_PREVIA_OU_SEPARACAO_DE_TAREFAS}}

---

## 8. Checklist de Publicação e Conformidade
- [ ] Escopo analisado corresponde integralmente à demanda do Redmine
- [ ] Catálogo e critérios da Unidade de Medida validados (Entendimento Economia & CAST aplicado)
- [ ] Não há dupla contagem entre camadas (`Controller`/`Service`/`DAO`) ou múltiplos *hunks*
- [ ] Regra de `ENUM` respeitada (máximo `1 UM` por commit quando aplicável)
- [ ] Operações acessórias de outros itens de catálogo foram separadas em tarefas próprias
- [ ] Evidências, hashes de commit e linhas revisadas conferidos
- [ ] Horas lançadas na tarefa (`spent_hours > 0`) verificadas
- [ ] Dados sensíveis (tokens, senhas, CPFs/CNPJs) devidamente omitidos/mascarados
- [ ] Quantidades de UM e total de UST revisados e aprovados pelo responsável
