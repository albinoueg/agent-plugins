---
name: vera
description: >-
  Auxilia na análise, rastreabilidade, validação e documentação de atividades de
  desenvolvimento de software. Utilize esta skill para solicitações relacionadas
  à validação de atividades registradas no Redmine, análise de evidências
  técnicas no GitLab ou em diffs locais do Git, rastreabilidade entre tarefas e
  commits, conferência de enquadramento no Catálogo de Atividades (Repertório de
  Estimativas / Economia / CAST) e geração de propostas e relatórios
  justificativos de UST (Unidades de Serviço Técnico).
---

# VERA — Validação de Evidências e Registros de Atividades

> **Estado Atual (`v0.5.0`):** O **Módulo de Catálogos**, as **Regras Acordadas Economia & CAST**, o **Padrão Enxuto de Notas de Evidência (Fiscal Sr. Edilson)**, o **Conector GitLab (`scripts/gitlab-connector.ps1` / `.sh`)**, o **Conector Redmine (`scripts/redmine-connector.ps1` / `.sh`)** e os **Templates de Relatórios e Notas (`templates/`)** estão implementados e ativos.

---

## 1. Objetivo e Hierarquia de Fontes de Verdade

A **VERA (Validação de Evidências e Registros de Atividades)** converte alterações reais e identificáveis de código e registros de atividades em uma **proposta técnica auditável em Markdown**, com enquadramento fundamentado no catálogo de UST e rastreabilidade ponta a ponta. **Nunca trate a saída da skill como faturamento automaticamente aprovado.**

### Ordem Estrita de Prioridade das Fontes de Verdade
1. **Catálogo contratual vigente (`./catalogs/catalogo-atividades.yaml`):** Unidade de medida, produto exigido, valores de UST e restrições formais.
2. **Entendimentos e regras acordadas entre Economia e CAST:** Definições para interpretação de unidades elementares CRUD, operações acessórias coesas, regra de `enum` (1 UM/commit), itens desconsiderados (`0 UM`), garantia e recorrência.
3. **Demanda/Issue e critérios de aceitação no Redmine:** Escopo solicitado, anexos e apontamentos registrados.
4. **Diff real do Git (API do GitLab ou repositório local) e arquivos de contexto:** Interfaces, DTOs, serviços, controladores, testes e descritores de configuração.
5. **Exemplos históricos aprovados:** Utilizados **apenas para estilo e formatação**, nunca para contrariar o catálogo ou as regras acordadas.

---

## 2. Portabilidade e Independência (`skills.sh` & GitHub Ready)

- **Zero Referências Locais:** Nunca utilize caminhos absolutos de sistema operacional ou identificadores fixos de máquina/usuário. Todos os recursos utilizam caminhos relativos (`./catalogs/...`, `./references/...`, `./scripts/...`, `./config/...`).
- **Recursos Autocontidos:** Todos os schemas, catálogos, scripts, templates e diretrizes residem dentro do diretório da skill.

---

## 3. Integração com GitLab e Redmine (Protocolo de Primeiro Uso / Onboarding)

As credenciais do GitLab e do Redmine ficam armazenadas exclusivamente nos arquivos locais não versionados `./config/gitlab.yaml` e `./config/redmine.yaml` (protegidos pelo `.gitignore`).

### 3.1. Onboarding do GitLab (`./config/gitlab.yaml`)
1. Verifique o status executando:
   `powershell -ExecutionPolicy Bypass -File ./scripts/gitlab-connector.ps1 -Action check-config`
2. Caso retorne `ONBOARDING_REQUIRED`, ofereça **duas opções** ao usuário:
   - **"Já possuo meu Personal Access Token (informar agora)"**
   - **"Não sei como obter o Personal Access Token no GitLab (ver passo a passo)"**
3. Se o usuário escolher ver o passo a passo, execute `-Action token-guide` (ou apresente as 7 etapas: *Avatar -> Edit profile -> Access Tokens -> Add new token -> marcar apenas `read_api` e `read_repository` -> Copiar token*).
4. Ao receber a URL e o Token, salve e teste com `-Action setup -BaseUrl "<URL>" -Token "<TOKEN>"` e `-Action test`.

### 3.2. Onboarding do Redmine (`./config/redmine.yaml`)
1. Verifique o status executando:
   `powershell -ExecutionPolicy Bypass -File ./scripts/redmine-connector.ps1 -Action check-config`
2. Caso retorne `ONBOARDING_REQUIRED`, ofereça **duas opções** ao usuário:
   - **"Já possuo minha Chave de Acesso API do Redmine (informar agora)"**
   - **"Não sei como obter a Chave de Acesso API no Redmine (ver passo a passo)"**
3. Se o usuário escolher ver o passo a passo, execute `-Action token-guide` (ou apresente as 5 etapas: *Login no Redmine -> clicar em 'Minha conta' no canto superior direito -> localizar 'Chave de acesso API' na lateral direita -> clicar em 'Mostrar' -> Copiar chave*).
4. Ao receber a URL e a Chave API, salve e teste com `-Action setup -BaseUrl "<URL>" -ApiKey "<CHAVE>"` e `-Action test`.

---

## 4. Regras Essenciais de Contagem e Validação (Acordo Economia & CAST)

Ao analisar alterações de código ou tarefas, aplique obrigatoriamente as seguintes regras (detalhadas em [`./references/billing-catalogs.md`](./references/billing-catalogs.md)):

1. **O que DEVE ser Contabilizado (`[backend]` / `[backend-alteracao]`):**
   - As Unidades Elementares CRUD principais entregues; e
   - Quaisquer outras **Operações / Ações / Unidades Elementares acessórias** que **agreguem valor ao negócio**, que **possuam coesão (responsabilidade única e bem definida)** e que **não sejam responsabilidade da Unidade Elementar CRUD principal** em questão.
   - **Cuidado Multi-Catálogo:** Se uma operação acessória pertencer a outro item de catálogo (ex.: `[frontend]`, `[Componente]`, `[Script]`), ela deve ser proposta em nova tarefa separada do Redmine com o item de catálogo correspondente.
2. **O que NÃO DEVE ser Contabilizado (`[desconsiderado] — 0 UM`):**
   - **Getters e Setters**;
   - **Métodos em diferentes camadas (`Controller`, `Service`, `DAO`) apenas com função de delegar a ação para outras camadas**;
   - **Criações de classes `.java` cujas operações/ações já sejam contabilizadas**;
   - **Criações de arquivos `.css` e `.xhtml`** (inclusos no catálogo de tela) e **arquivos `.js`** (inclusos no catálogo de Frontend);
   - **Formatação pura / reflow**, **logs puros** (`logger.*`, `console.*`), **checagens simples de `null`**, **troca simples de tipo de coleção local** e **funções mecânicas de limpeza/reset de estado ou UI** (`limpaCampos`, `reset`, `val('')`, `hide/show`, `clearInterval`).
3. **Regra de `ENUM` (`1 UM por Commit`):**
   - Para um **mesmo commit**, se houver a criação (`[backend]` / `[frontend]`) ou alteração (`[backend-alteracao]` / `[frontend-alteracao]`) de **um ou mais `enums`**, deve ser contabilizada **somente 1 UM por commit** (na respectiva categoria). Se houver **1 ou 10 `enums`** no mesmo commit, sempre será contabilizado **somente 1 UM**.
4. **Faixas de Complexidade do Catálogo Cast 13/2024 (`3 ou menos` vs. `4 ou mais unidades`):**
   - **`- 3 ou menos unidades` (`Complexidade Altíssima = Não`):** aplica o valor base de UST por U.M. (`[backend]` = 4, `[backend-alteracao]` = 2, `[teste-unitario]` = 4, `[teste-unitario-alteracao]` = 2, `[frontend]` = 4, `[frontend-alteracao]` = 1).
   - **`- 4 ou mais unidades` (`Complexidade Altíssima = Sim`):** dobra o multiplicador de UST por U.M. (`2x base`, ex.: `[backend]` passa para **8 UST/UM**, totalizando 32 UST para 4 UMs).
5. **Regra de `[teste-unitario]` (`1 UM de teste por item cobrado coberto`):**
   - Contabiliza-se **1 UM de teste por item/unidade elementar cobrada que o teste cobre** ("funcionalidade coberta" do catálogo aplicada à mesma contagem do código).
   - É **vedado contar por classe de teste ou separar por camada arquitetural** (ex.: `ControllerTest`, `ServiceTest` e `RepositoryTest` da mesma operação contam juntos **1 UM**). Ajustes em *fixtures*/apoio de teste não contam à parte.
6. **Vedação de Alteração Dupla na Mesma Entrega e Mistura de Catálogos:**
   - **Alteração na mesma entrega (`0 UM` / cancelar):** O que se altera antes da entrega/validação da funcionalidade original (ex.: paginar ou ajustar DTO de rotas recém-criadas dias antes na mesma demanda-mãe ainda não validada, ou quando os métodos surgem como novos no `common`, ou com horas lançadas na data da criação) faz parte da criação. Recomendar zerar a tarefa de alteração (`Resolvida`, `Catálogo vazio`, `UM = 0`) e consolidar horas e commits na tarefa de criação.
   - **Proibição de misturar criação e alteração na mesma subtarefa:** Uma subtarefa não pode misturar `[frontend]` e `[frontend-alteracao]` (nem `[backend]` e `[backend-alteracao]`). Manter a categoria principal na tarefa atual e recomendar abrir uma **subtarefa irmã** (mesmo pai) para a outra categoria, dividindo as horas.
7. **Auditoria Fina de Nota, Caminhos, Mocks e Metadados do Redmine:**
   - **Caminhos no diff:** Conferir se todos os caminhos de arquivo citados na nota batem literalmente com o `new_path` do `git diff` (sem omitir pastas intermediárias como `responder_formulario_module/` e usando `/` em vez de `\`).
   - **1 seção por UM:** A nota deve ter uma seção `"Unidade elementar N"` para cada UM lançada no campo `Unid. Medida (Cast)`, com método, linhas e links de todos os commits envolvidos (ex.: `service` + `common`).
   - **Serviço Simulado / Mock:** Se a tela ou serviço injetar implementação simulada (`*Simulado`, `*Mock`) em vez do serviço REST real, alertar para manter a atividade **`Em andamento`** até o commit que conecta o serviço real.
   - **Metadados:** Validar se `Sistema (Módulo)` condiz com o repositório (`(Serviços)` para `*-service`/`*-common`; `(Mobile)` para `*-mobile`) e se a tag do título (`[Backend]`, `[Backend-Alteração]`, etc.) coincide com o campo `Catálogo`.
8. **Padrão Enxuto de Notas de Evidência no Redmine (Orientação Fiscal Sr. Edilson):**
   - Em alinhamento com os fiscais de contrato que validam as atividades (orientação do fiscal Sr. Edilson), as informações das tarefas no Redmine devem ser **o mais enxutas possível**:
     - **Para atividades de inclusão:** Inserir o commit, o caminho do arquivo (que já identifica a classe) e o método.
     - **Para atividades de alteração:** Adicionar obrigatoriamente o **número da linha** (`*Linhas*: X a Y`).
     - **Separador:** Utilizar `---` entre as unidades elementares.
     - **Estrutura padrão (`./templates/redmine-task-note.template.md`):**
       ```text
       *Commit*: https://gitlab.economia.go.gov.br/...

       *Unidade elementar 1*
       *Comportamento entregue*: Descrição sucinta do comportamento/valor de negócio.
       *Arquivo*: caminho/do/Arquivo.java
       *Método*: nomeDoMetodo
       *Linhas*: 57 a 81   <-- [Obrigatório apenas para atividades de alteração]
       ---
       *Unidade elementar 2*
       ...
       ```
9. **Regras de `[Componente]` e `[Suporte]`:**
   - **`[Componente]` (2 UST por U.M.):** `1 UM` por arquivo `.properties`, descritor (`pom.xml`, `weblogic.xml`, `web.xml`, `log4j2.xml`) ou componente configurado/alterado.
   - **`[Suporte]` (1 UST por chamado único):** `1 UM` por atendimento/chamado único comprovado por anexo, com deduplicação obrigatória.
10. **Critério Triplo de Tarefa 100% Cobrada e Confronto `Categoria + UM`:**
   - Exige cumulativamente no Redmine: (1) Status Fechado/Validação + (2) Evidência/Commit vinculado + (3) Horas lançadas (`spent_hours > 0`, senão sinalizar `⚠️ PENDENTE DE HORAS`).
11. **Padrão Obrigatório de Atividade em Lançamentos de Horas (`Desenvolvimento`):**
   - Sempre que for solicitado qualquer lançamento de horas/tempo gasto (`time entry`) em tarefas ou atividades do Redmine, preencher **obrigatoriamente** o campo **`Atividade`** com o valor **`Desenvolvimento`** (`id: 9`).
   - Nas solicitações em que o usuário omitir a atividade, assumir **`Desenvolvimento`** como padrão definitivo e automático.
12. **Padrão de Criação de Tarefas de [Script] no Redmine:**
   - Ao receber comando para criação de tarefa de script (ex.: *"crie uma nova tarefa de elaboração de script na demanda ####, use o script a seguir..."*):
     - **Vínculo:** Subtarefa da demanda-mãe (`parent_issue_id: ####`).
     - **Herança:** Herdar `project_id` e `Sistema (Módulo)` (`custom_field_id: 63`) da demanda-mãe.
     - **Tipo:** `Implementação` (`tracker_id: 21`).
     - **Título:** Prefixo obrigatório `[Script] - <título contextual elaborado ou validado com o usuário>`.
     - **Catálogo:** `DESENVOLVIMENTO E IMPLANTAÇÃO [script]` (`custom_field_id: 102`).
     - **Unid. Medida (Cast):** `1` (`custom_field_id: 29`) (1 a cada 4 tabelas manipuladas, mínimo 1).
     - **Complexidade Altíssima:** `Não` (`custom_field_id: 104`).
     - **Situação:** `Em andamento` (`status_id: 2`).
     - **Atribuição:** Usuário autenticado (`Albino Moreira dos Santos`, `id: 185`).
     - **Descrição da tarefa:** Deixar vazia.
     - **Nota da tarefa (`notes`):** Resumo do comportamento/operação + código SQL formatado com `<pre><code class="sql">...</code></pre>` conforme [`./templates/redmine-script-note.template.md`](./templates/redmine-script-note.template.md).
     - **Horas (quando solicitadas):** Tempo solicitado com atividade padrão `Desenvolvimento` (`id: 9`).
13. **Padrão de Lançamento em Tarefas de [Deploy] no Redmine:**
   - Em tarefas periódicas de deploy (`DESENVOLVIMENTO E IMPLANTAÇÃO [deploy] - atendimento comum`):
     - **Conferência:** Checar paridade entre a quantidade atual de deploys registrados e o valor de `Unid. Medida (Cast)` (`id: 29`).
     - **Incremento:** Atualizar `Unid. Medida (Cast)` para `UM_atual + 1`.
     - **Nota e Anexo:** Inserir o cabeçalho `*1 Unidade: Merge + Deploy*`, links do commit de merge e do pipeline no GitLab, upload do print do pipeline e inclusão inline `!<arquivo>!` conforme [`./templates/redmine-deploy-note.template.md`](./templates/redmine-deploy-note.template.md).
     - **Horas:** Lançar `0.5h` sob a atividade padrão `Desenvolvimento` (`id: 9`).

---

## 5. Como Usar a VERA (Comandos e Referências de Uso)

O usuário pode acionar a VERA diretamente no chat usando comandos em linguagem natural. Principais fluxos suportados:

1. **Gerar Relatório de Auditoria de Demanda (Demanda-Mãe + Subtarefas + GitLab):**
   - **Comando:** `"Gerar relatório da demanda [123456]"` (ex.: `"Gerar relatório da demanda 194956"` ou `"Gerar relatório da demanda 194956 para os lançamentos do Albino"`).
   - **Procedimento da VERA:**
     1. Executa `powershell -ExecutionPolicy Bypass -File ./scripts/redmine-connector.ps1 -Action demand -IssueId <ID> -NonInteractive` (adicionando `-Assignee "<Nome>"` se especificado).
     2. Para cada commit citado nas notas das subtarefas (ou localizado via busca no GitLab com `-Action search-task` / `-Action my-commits`), executa `./scripts/gitlab-connector.ps1 -Action commit -Project "<projeto>" -Sha "<hash>" -NonInteractive`.
     3. Audita cada subtarefa confrontando o código real (`git diff`), a nota de evidência e os campos do Redmine contra as regras da Seção 4.
     4. Gera o relatório estruturado seguindo o template [`./templates/demand-audit-report.template.md`](./templates/demand-audit-report.template.md) (contendo tabela de Resumo `Lançado vs. Correto` e `UST lançadas -> corretas`, análise detalhada por subtarefa e checklist `"O que fazer, por atividade"`).
2. **Auditar uma Subtarefa / Issue Específica do Redmine:**
   - **Comando:** `"Auditar a tarefa [123456] com a VERA"` ou `"Validar a atividade [123456] no Redmine"`.
3. **Analisar um Commit no GitLab e Gerar Nota/Proposta de Cobrança:**
   - **Comando:** `"Analisar o commit [hash] do projeto [grupo/repo] com a VERA"` ou `"Gerar proposta de cobrança para o commit [hash]"`.
   - Utiliza o template [`./templates/ust-validation-report.template.md`](./templates/ust-validation-report.template.md).
4. **Auditar Meus Commits e Lançamentos por Período:**
   - **Comando:** `"Verificar meus commits e tarefas desde [DD/MM/AAAA] com a VERA"`.
5. **Configurar ou Testar Conexão com GitLab / Redmine:**
   - **Comando:** `"Quero configurar ou testar minha conexão com o GitLab usando a VERA"` ou `"Quero configurar ou testar minha conexão com o Redmine usando a VERA"`.
6. **Consultar Dúvidas do Catálogo e Regras Economia/CAST:**
   - **Comando:** `"Segundo a VERA, como devo enquadrar [descrição da atividade]?"`.
7. **Gerar Nota Enxuta de Lançamento de Evidência para o Redmine (Padrão Fiscal Sr. Edilson):**
   - **Comando:** `"Gerar nota enxuta de lançamento para o commit [hash] da tarefa [id]"` ou `"Montar nota para o Redmine do commit [hash]"`.
   - Procedimento: Analisa o diff do commit no GitLab, extrai as unidades elementares elegíveis e gera a nota padronizada e enxuta pronta para colar no Redmine, distinguindo inclusão (sem linhas obrigatórias) e alteração (com número de linhas).

8. **Criar Tarefa de Elaboração de Script no Redmine:**
   - **Comando:** `"Crie uma nova tarefa de elaboração de script na demanda [id], use o script a seguir: [sql]"` (com ou sem apontamento de horas).
   - **Procedimento:** Executa a criação da subtarefa com o prefixo `[Script] - `, configura catálogo `DESENVOLVIMENTO E IMPLANTAÇÃO [script]`, registra a nota com a descrição da operação e o script SQL em bloco `<pre><code class="sql">...</code></pre>` conforme [`./templates/redmine-script-note.template.md`](./templates/redmine-script-note.template.md) e, se solicitado, realiza o lançamento de horas com atividade padrão `Desenvolvimento` (`id: 9`).
9. **Lançar Deploy em Tarefa Periódica no Redmine:**
   - **Comando:** `"Lançar deploy na atividade [id], [links/print]"` ou fornecendo print e pipeline do GitLab.
   - **Procedimento:** Confere a consistência da quantidade de lançamentos prévios com a `Unid. Medida (Cast)`, incrementa o campo em `+1`, resolve o commit associado ao pipeline, faz upload da evidência, anexa inline e registra 0.5h sob `Desenvolvimento` (`id: 9`) conforme [`./templates/redmine-deploy-note.template.md`](./templates/redmine-deploy-note.template.md).

---

## 6. Organização dos Arquivos da Skill

- [`./catalogs/catalogo-atividades.yaml`](./catalogs/catalogo-atividades.yaml): Catálogo completo (31 atividades, 4 sessões) + regras Economia/CAST, faixas Cast 13/2024 e regra de `enum`.
- [`./catalogs/catalog.schema.json`](./catalogs/catalog.schema.json): JSON Schema (Draft 2020-12) para validação estrutural.
- [`./scripts/gitlab-connector.ps1`](./scripts/gitlab-connector.ps1) e [`./scripts/gitlab-connector.sh`](./scripts/gitlab-connector.sh): Conectores somente leitura do GitLab.
- [`./scripts/redmine-connector.ps1`](./scripts/redmine-connector.ps1) e [`./scripts/redmine-connector.sh`](./scripts/redmine-connector.sh): Conectores somente leitura do Redmine (incluindo `-Action demand` para auditoria completa de demanda-mãe).
- [`./templates/demand-audit-report.template.md`](./templates/demand-audit-report.template.md): Template oficial de Relatório Consolidado de Auditoria por Demanda.
- [`./templates/ust-validation-report.template.md`](./templates/ust-validation-report.template.md): Template oficial de relatório individual e proposta auditável de UST.
- [`./templates/redmine-task-note.template.md`](./templates/redmine-task-note.template.md): Template oficial da nota enxuta de lançamento de evidência no Redmine (orientação Fiscal Sr. Edilson).
- [`./templates/redmine-script-note.template.md`](./templates/redmine-script-note.template.md): Template oficial da nota de tarefa de script no Redmine (descrição operacional + bloco SQL).
- [`./templates/redmine-deploy-note.template.md`](./templates/redmine-deploy-note.template.md): Template oficial da nota de lançamento de deploy no Redmine (links + print inline).
- [`./references/billing-catalogs.md`](./references/billing-catalogs.md): Guia de interpretação do catálogo, acordo Economia/CAST sobre CRUD, faixas Cast 13/2024, testes unitários, regra de `enum`, `[Suporte]` e `[Componente]`.
- [`./references/gitlab.md`](./references/gitlab.md): Especificação da integração GitLab via PAT em `./config/gitlab.yaml`.
- [`./references/redmine.md`](./references/redmine.md): Especificação da integração Redmine via API Key em `./config/redmine.yaml`, auditoria de demanda, critério triplo e confronto `Categoria + UM`.
- [`./references/architecture.md`](./references/architecture.md): Arquitetura modular, contratos conceituais e fluxo de dados.
- [`./config/`](./config/): Contém `vera.yaml` (configuração geral versionada da skill) e os modelos `gitlab.example.yaml` e `redmine.example.yaml` sem credenciais reais.
