# Changelog

Todas as mudanças notáveis neste projeto serão documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/),
e este projeto adere ao [Versionamento Semântico](https://semver.org/lang/pt-BR/spec/v2.0.0.html).

---

## [0.5.0] - 2026-11-19

### Adicionado

- **Padrão Enxuto de Notas de Evidência no Redmine (Orientação Fiscal Sr. Edilson):**
  - Formalização da diretriz do fiscal de contrato Sr. Edilson para manter os apontamentos de tarefas o mais enxutos possível.
  - Regra para atividades de **inclusão**: link do commit, caminho do arquivo (com classe) e método.
  - Regra para atividades de **alteração**: obrigatoriedade da especificação do intervalo de linhas (`*Linhas*: X a Y`).
  - Criação do template oficial [`templates/redmine-task-note.template.md`](templates/redmine-task-note.template.md).
  - Atualização do catálogo [`catalogs/catalogo-atividades.yaml`](catalogs/catalogo-atividades.yaml) com a regra `lean_task_note_format_rule`.
  - Atualização de `SKILL.md`, `README.md`, `references/billing-catalogs.md` e `references/redmine.md`.
- **Padronização da Atividade em Lançamentos de Horas (`Desenvolvimento`):**
  - Fixação da atividade padrão **`Desenvolvimento`** (`id: 9`) para todo apontamento de horas (`time entry`) no Redmine, mesmo quando o usuário omitir essa especificação no comando.
  - Registrado em `AGENTS.md`, `vera/SKILL.md`, `vera/config/redmine.yaml`, `vera/config/vera.yaml` e `vera/references/redmine.md`.
- **Modelo de Criação de Tarefas de [Script] no Redmine:**
  - Padronização do fluxo para criação autônoma de tarefas de elaboração/execução de scripts vinculadas à demanda-mãe.
  - Regras: herança de projeto/módulo, tracker `Implementação`, prefixo `[Script] - `, catálogo `DESENVOLVIMENTO E IMPLANTAÇÃO [script]`, U.M. `1`, descrição vazia e notas formatadas com resumo da finalidade e script SQL em bloco `<pre><code class="sql">`.
  - Criação do template oficial [`templates/redmine-script-note.template.md`](templates/redmine-script-note.template.md) e registro em `AGENTS.md`, `SKILL.md` (Comando #8), `templates/README.md`, `config/vera.yaml` e `references/redmine.md`.
- **Modelo de Lançamento de [Deploy] em Atividades Mensais/Periódicas:**
  - Conferência automática de paridade entre a contagem de lançamentos e o campo `Unid. Medida (Cast)` (`id: 29`).
  - Atualização com incremento `+1` na unidade de medida a cada deploy.
  - Anexo do print do pipeline do GitLab via API e incorporação inline na nota com links do commit de merge e do pipeline.
  - Apontamento proporcional de horas (`0.5h` sob a atividade padrão `Desenvolvimento`, `id: 9`).
  - Criação do template oficial [`templates/redmine-deploy-note.template.md`](templates/redmine-deploy-note.template.md) e registro em `AGENTS.md`, `SKILL.md` (Comando #9), `templates/README.md`, `config/vera.yaml` e `references/redmine.md`.

---

## [0.4.0] - 2026-10-29

### Adicionado

- **Conector Somente Leitura do Redmine (`scripts/redmine-connector.ps1` e `scripts/redmine-connector.sh`):**
  - Integração com a API REST do Redmine via **Chave de Acesso API (`X-Redmine-API-Key`)** armazenada no arquivo local não versionado `./config/redmine.yaml` (protegido pelo `.gitignore`).
  - **Fluxo Interativo de Primeiro Uso (*Onboarding*):** Verifica automaticamente se `./config/redmine.yaml` existe e possui `api_key` cadastrada; caso contrário, solicita a chave ao usuário oferecendo a opção *"Não sei como obter a Chave de Acesso API no Redmine (ver passo a passo)"*.
  - **Guia Passo a Passo Integrado (`token-guide`):** Instruções resumidas em 5 passos (*Login -> Minha conta -> Chave de acesso API -> Mostrar -> Copiar*).
  - **Operações Suportadas (`read_only`):** `check-config`, `token-guide`, `setup`, `test` (`GET /users/current.json`), `issue` (consulta completa da tarefa incluindo subtarefas, anexos, journals, apontamentos de horas e avaliação automática do critério triplo `100_PORCENTO_COBRADO_OU_REGULAR` vs `PENDENTE_DE_HORAS`), `demand` (coleta consolidada da demanda-mãe e de todas as suas subtarefas filhas, campos do Catálogo Cast 13/2024, horas e links de commits nas notas), `my-issues` e `time-entries`.
- **Regras Avançadas de Auditoria por Demanda e Template Consolidado (`templates/demand-audit-report.template.md`):**
  - Suporte às faixas de complexidade do **Catálogo Cast 13/2024** (`- 3 ou menos unidades` vs. `- 4 ou mais unidades` dobrando a UST unitária).
  - Regra de contagem de `[teste-unitario]`: **1 U.M. de teste por item cobrado que o teste cobre** (vedada a contagem por classe ou camada Controller/Service/Repository).
  - Regra de vedação de **alteração dupla na mesma entrega** (alterações antes da validação da tarefa original fazem parte da criação) e vedação de misturar criação e alteração na mesma subtarefa.
  - Auditoria cruzada de caminhos de arquivos na nota vs. `git diff`, detecção de serviços simulados/mocks (`*Simulado`) e validação de metadados (`Sistema (Módulo)` vs. repositório e tag do título vs. catálogo).
  - Adição do Guia Rápido de Comandos (ex.: `"Gerar relatório da demanda [123456]"`) em `SKILL.md` e `README.md`.
- **Atualização da Documentação (`SKILL.md`, `README.md`, `ROADMAP.md`, `references/redmine.md`, `scripts/README.md`, `config/redmine.example.yaml` e `config/vera.yaml`):**
  - Remoção do arquivo redundante `config/vera.example.yaml`, mantendo `config/vera.yaml` versionado diretamente no Git (pois não contém credenciais) e protegendo apenas `config/gitlab.yaml` e `config/redmine.yaml` no `.gitignore`.

---

## [0.3.0] - 2026-10-29

### Adicionado

- **Conector Somente Leitura do GitLab (`scripts/gitlab-connector.ps1` e `scripts/gitlab-connector.sh`):**
  - Integração com a API REST v4 do GitLab via **Personal Access Token (PAT)** armazenado em `./config/gitlab.yaml` (protegido pelo `.gitignore`), com onboarding interativo e guia passo a passo (`token-guide`).

---

## [0.2.0] - 2026-10-29

### Adicionado

- **Catálogo Estruturado de Atividades (`catalogs/catalogo-atividades.yaml`) e Schema (`catalogs/catalog.schema.json`):**
  - Conversão das 4 sessões e 31 atividades do *Anexo I*, incorporação do **Entendimento Acordado Economia & CAST** sobre CRUD/Unidades Elementares, **Regra de `ENUM`** (`1 UM por commit`), atualização de `[Suporte]` e `[Componente]`, e criação do template `templates/ust-validation-report.template.md`.

---

## [0.1.0] - 2026-10-29

### Adicionado

- **Estrutura Inicial da Skill (`vera/`):** Criação da árvore de diretórios modular, `SKILL.md`, `README.md`, `ROADMAP.md`, exemplos de configuração (`config/*.example.yaml`) e `.gitignore`.
