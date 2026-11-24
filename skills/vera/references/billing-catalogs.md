# Especificação e Regras de Enquadramento — Catálogos de Faturamento

> **Status (`v0.2.0`):** Catálogo de Atividades e Entendimentos Acordados Economia & CAST estruturados em [`../catalogs/catalogo-atividades.yaml`](../catalogs/catalogo-atividades.yaml) com schema formal em [`../catalogs/catalog.schema.json`](../catalogs/catalog.schema.json).

---

## 1. Hierarquia de Fontes de Verdade e Prioridade

Qualquer validação conduzida pela skill **VERA** deve obedecer rigorosamente à seguinte ordem de prioridade:

1. **Catálogo contratual de atividades/UST vigente (`catalogo-atividades.yaml`):** Unidade de medida, produto exigido, valores de UST e restrições formais.
2. **Entendimentos e regras específicas comprovadas entre Economia e CAST:** Definições acordadas para interpretação de unidades elementares CRUD, operações acessórias coesas, regra de `enum`, garantia, reuso e aceitação.
3. **Demanda/Issue e critérios de aceitação no Redmine:** Escopo solicitado, anexos e apontamentos registrados.
4. **Diff real do Git e arquivos relevantes de contexto:** Alterações materiais de código (interfaces, DTOs, implementações, testes, controladores e configurações).
5. **Exemplos históricos aprovados:** Utilizados **apenas para estilo e formatação de evidências**, nunca para contrariar o catálogo ou as regras acordadas.

> **Regra de Ouro:** A saída da VERA é sempre uma **proposta técnica auditável** e nunca deve ser tratada como faturamento automaticamente aprovado. Se faltar fonte comprobatória, classificar como `INFORMACAO_AUSENTE` / `PENDENTE DE VALIDAÇÃO`.

---

## 2. Entendimento Acordado Economia & CAST sobre CRUD e Unidades Elementares (`[backend]` e `[backend-alteracao]`)

### 2.1. DEVEM SER CONTABILIZADOS
Além das Unidades Elementares CRUD principais, **devem ser contabilizadas**:
- Quaisquer outras **Operações / Ações / Unidades Elementares acessórias** que **agreguem valor ao negócio**, que **possuam coesão (responsabilidade única e bem definida)** e que **não sejam responsabilidade da Unidade Elementar CRUD principal** em questão.

> **CUIDADO (Atenção Multi-Catálogo):** Essas operações acessórias podem não pertencer ao mesmo item de catálogo. Nestes casos, novas tarefas do Redmine devem ser criadas (ou propostas no relatório) e classificadas com o item de catálogo correspondente.

### 2.2. NÃO DEVEM SER CONTABILIZADOS (`[desconsiderado] — 0 UM`)
**Não devem ser contabilizados** métodos auxiliares que **não agreguem valor ao negócio**, que correspondam apenas a **fragmentações da implementação** (quebra de um método coeso em partes, a critério do desenvolvedor) de uma única funcionalidade/unidade elementar, ou que se constituam apenas em **elementos de código/arquiteturais obrigatórios** para o correto funcionamento da operação/ação que está sendo entregue:

- **Getters** (`get*`, `is*` sem regra de negócio);
- **Setters** (`set*`);
- **Métodos em diferentes camadas apenas com função de delegar a ação para outras camadas** (`Controller`, `Service`, `DAO`/`Repository`);
- **Criações de classes `.java` cujas operações/ações já sejam contabilizadas**;
- **Criações de arquivos `.css` e `.xhtml`** (estrutura inicial da tela – incluso no catálogo tela / `[frontend]`);
- **Criações de arquivos `.js`** (inclusos no catálogo do Frontend — `[frontend]` / `[frontend-alteracao]`).

### 2.3. Taxonomia Complementar de Código Desconsiderado (`[desconsiderado] — 0 UM`)
1. **Formatação e Reflow Puro:** Alterações restritas a espaços em branco, indentação, quebras de linha (*reflow* de assinaturas ou instruções), concatenação de literais quebrados em linhas, linhas em branco, `imports` ou comentários.
2. **Boilerplate de Linguagem:** `toString`, `equals`, `hashCode`, `compareTo`, `canEqual`, `clone`, `valueOf`, `values`, construtores simples de atribuição/injeção, DTOs/Projections puros e constantes simples em classes não-enum.
3. **Limpeza, Reset ou Inicialização Mecânica de Estado/UI:** Métodos/funções (ex.: `limpaCampos()`, `pararHeartbeat()`, `reset()`, `init*`, `clear*`) cujo corpo realiza exclusivamente atribuição de valores vazios/escalares (`null`, `0`, `""`, `false`, `[]`, `{}`), limpeza de timers (`clearInterval`, `clearTimeout`) ou manipulação visual básica (`val('')`, `hide()`, `show()`, `empty()`, `prop('disabled', ...)`) sem cálculo de negócio, sem chamada HTTP/AJAX e sem persistência.
4. **Extração Interna ("Trocar Seis por Meia-Dúzia") e Null-Check Simples:** Transformar parte das linhas já existentes de um método em outro método privado/sobrecarga ou adicionar exclusivamente guarda simples de nulidade (`if (x != null)`) sem alterar a lógica de negócio.
5. **Diagnóstico e Log Puro:** Métodos ou alterações restritas exclusivamente a instruções de log (`logger.*`, `console.*`, `System.out.*`).
6. **Troca Exclusiva de Tipo de Coleção/Instanciação Local:** Substituição unicamente da classe de coleção/objeto instanciada em variável local (ex.: `LinkedList<>` $\rightarrow$ `ConcurrentLinkedQueue<>`) mantendo a mesma variável, argumentos e fluxo.

---

## 3. Regra de Contagem para `ENUM` (`[backend]` e `[backend-alteracao]`)

- **Escopo:** Aplica-se às categorias **`[backend]`** (criação de `enum`) e **`[backend-alteracao]`** (alteração de `enum` existente).
- **Teto de 1 U.M. por Commit:**
  - Para um **mesmo commit**, se houver a criação ou alteração de **um ou mais `enums`**, deve ser contabilizada **1 UM por commit** (na respectiva categoria).
  - Se houver **1 ou 10 `enums`** criados ou alterados no mesmo commit, **sempre será contabilizado somente 1 UM**.
  - Caso `enums` sejam criados ou alterados em **commits diferentes**, cada commit que contiver criação/alteração de `enum` contabilizará `1 UM` na respectiva categoria.

---

## 4. Regras Específicas de `[Componente]` e `[Suporte]`

### 4.1. `[Componente]` — Configuração ou Execução de Componente (`2 UST por U.M.`)
- **Unidade de Medida (UM):** Quantidade de arquivos de propriedades, descritores ou componentes configurados/alterados (**1 UM por arquivo/componente**).
- **Valor UST:** **2 UST por U.M.** ($\text{Total UST} = 2 \times \text{Qtd U.M.}$).
- **Escopo Técnico Enquadrável:**
  - Instalação, execução, atualização ou configuração de bibliotecas, rotinas, frameworks (ex.: classes `@Configuration`) ou extensões acopladas ao sistema;
  - Descritores de implantação/container (`pom.xml`, `weblogic.xml`, `weblogic-application.xml`, `web.xml`, `log4j2.xml`);
  - Arquivos `.properties` (`messages.properties`, `jasperreports.properties`, etc.);
  - Parametrizações de anotações de classe (`@ComponentScan`, `@PropertySource`) e alterações em métodos Java restritas exclusivamente à parametrização de agendamento/anotação (ex.: `@Scheduled(cron = ...)` acompanhada ou não de ajustes em mensagens de `logger`/Javadoc, sem mudança na lógica de negócio).
- **Deduplicação por Arquivo:** Múltiplas alterações (vários *hunks*) dentro do mesmo arquivo `.properties` ou `pom.xml` contam como **1 única UM**.

### 4.2. `[Suporte]` — Suporte Operacional (`1 UST por Chamado Único`)
- **Unidade de Medida (UM):** **1 UM por Atendimento / Chamado (SS / OS / GLPI / Suporte) único comprovado por anexo**.
- **Valor UST:** **1 UST por chamado / UM** ($\text{Total UST} = 1 \times \text{Qtd de Chamados Únicos}$).
- **Deduplicação Obrigatória de Evidências:** Se houver múltiplos arquivos de prints ou PDFs para o mesmo número de chamado (ex.: `SS1082160_1.png` e `SS1082160_2.png`, ou `2608100096.pdf` e `2 608 100 096.PNG`), contabilizar apenas **1 UM** para aquele chamado.

---

## 5. Regras Críticas de Auditoria Transversal

### 5.1. Recorrência de Cobrança na Mesma Demanda
Sempre que a mesma operação, funcionalidade ou método aparecer sendo cobrado mais de uma vez em commits distintos dentro da **mesma demanda do Redmine**:
1. **Perguntar obrigatoriamente ao usuário** se a recorrência será considerada e cobrada novamente (`1 UM`) ou desconsiderada (`[desconsiderado] — 0 UM`).
2. **Sugerir uma justificativa técnica concisa** extraída da análise do `git diff` explicando por que a nova alteração foi necessária.
3. **Caso aprovada a nova cobrança**, incluir obrigatoriamente a justificativa resumida na descrição do item:
   `Alteração em <item> (Justificativa: <motivo resumido da nova alteração>)`.

### 5.2. Regra de Garantia Custo Zero (`[problema]` e Correções)
- Se durante a verificação (`[problema]`) for detectado que o erro decorre de **garantia contratual**, tanto a tarefa de verificação quanto **todas as tarefas relacionadas à sua correção** devem ser tratadas como garantia, com **0 UST**.

### 5.3. Exigência de Autorização Prévia
- As atividades **`[avaliacao-squad]`** (36 UST), **`[Documento]`** (1 UST/h) e **`[Parecer-técnico]`** (1 UST/h) exigem comprovação explícita de autorização prévia (`requires_prior_authorization: true`). Na ausência de comprovação, classificar como **`INFORMACAO_AUSENTE`**.

### 5.4. Alteração Incremental em `[user-story]`
- A unidade de medida permanece **Por critério de aceitação** (**2 UST por critério de aceitação**, complexidade `Altíssima` acima de 20 critérios).
- Quando se tratar de **alteração em História de Usuário existente**, contabilizar **apenas os critérios de aceitação efetivamente adicionados ou alterados** (e não a história inteira novamente).

---

## 6. Padrão Enxuto de Notas de Evidência no Redmine (Orientação Fiscal Sr. Edilson)

Alinhamento formal com a equipe de fiscalização de contratos da Economia-GO (fiscal de contrato Sr. Edilson): as notas de tarefas de implementação/desenvolvimento devem manter o registro das evidências o **mais enxuto possível**, garantindo rastreabilidade rápida e sem dispersão textual.

### 6.1. Diretrizes por Tipo de Atividade
1. **Atividades de Inclusão (`[backend]`, `[frontend]`):**
   - Informar:
     - **URL do Commit** (`*Commit*: <url>`);
     - **Bloco da Unidade Elementar** (`*Unidade elementar N*`);
     - **Comportamento entregue** (`*Comportamento entregue*: <resumo funcional enxuto de 1 linha>`);
     - **Caminho do arquivo** (`*Arquivo*: <caminho relativo completo com o nome da classe>`);
     - **Nome do método** (`*Método*: <nomeDoMetodo>`);
   - O número de linhas é opcional/dispensável quando se tratar de novos arquivos/métodos criados na íntegra.
2. **Atividades de Alteração (`[backend-alteracao]`, `[frontend-alteracao]`):**
   - Além do commit, comportamento entregue, caminho do arquivo e método, **adicionar obrigatoriamente o intervalo de linhas afetadas**:
     - `*Linhas*: <inicio> a <fim>` (ou linhas pontuais alteradas).
3. **Divisão de Unidades Elementares:**
   - Separar cada bloco de unidade elementar com um traço triplo (`---`).

### 6.2. Exemplo Oficial Homologado
```text
*Commit*: https://gitlab.economia.go.gov.br/fis/fis-service/-/commit/1422aa2cc48855845cb8689ddfaade2841fccf07

*Unidade elementar 1*
*Comportamento entregue*: Novo endpoint para receber logs do modulo FIS dentro do aplicativo INFOTRANSITO.
*Arquivo*: fis-service-rest/src/main/java/br/gov/go/sefaz/fis/service/rest/controller/operations/v1/LogsAplicativoMobileRestController.java
*Método*: accessLogInfotransito
*Linhas*: 57 a 81
---
*Unidade elementar 2*
*Comportamento entregue*: Documentação do novo endpoint.
*Arquivo*: fis-service-rest/src/main/java/br/gov/go/sefaz/fis/service/rest/controller/docs/v1/LogsAplicativoMobileDocumentable.java
*Método*: accessLogInfotransito
*Linhas*: 25 a 30
```
