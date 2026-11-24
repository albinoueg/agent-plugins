# VERA — Validação de Evidências e Registros de Atividades

![Versão](https://img.shields.io/badge/versão-0.4.0-blue)
![Status](https://img.shields.io/badge/status-catálogo_gitlab_e_redmine_ativos-success)
![Especificação](https://img.shields.io/badge/Agent_Skills-SKILL.md-success)
![Portabilidade](https://img.shields.io/badge/skills.sh-compatible-purple)

## 1. Apresentação

A **VERA (Validação de Evidências e Registros de Atividades)** é uma *Agent Skill* independente e portável, projetada para auxiliar equipes de engenharia de software, analistas de qualidade, gestores técnicos e fiscais de contratos na **rastreabilidade, auditoria técnica e documentação de atividades de desenvolvimento de software**.

Construída sob princípios de arquitetura modular, baixo acoplamento e total independência de ambiente, a VERA correlaciona tarefas registradas em sistemas de gestão (**Redmine**), evidências técnicas de implementação (**GitLab** ou repositório Git local) e regras contratuais de mensuração em **Unidades de Serviço Técnico (UST)** baseadas no **Catálogo de Atividades (Repertório de Estimativas)** e nos **Entendimentos Acordados entre Economia e CAST**.

---

## 2. Portabilidade, GitHub e `skills.sh`

A VERA foi arquitetada para ser **100% autocontida e agnóstica de máquina ou LLM**:

- **Sem Dependências Locais Fixas:** Nenhum arquivo da skill referencia caminhos absolutos de sistema operacional, IDs fixos de usuários ou configurações específicas de máquina. Todos os recursos internos utilizam caminhos relativos (`./catalogs/...`, `./references/...`, `./scripts/...`, `./templates/...`).
- **Compatível com Qualquer LLM:** O catálogo de atividades em YAML (`./catalogs/catalogo-atividades.yaml`), seu JSON Schema (`./catalogs/catalog.schema.json`), os conectores GitLab e Redmine (`./scripts/`) e o template de saída (`./templates/ust-validation-report.template.md`) foram estruturados para uso determinístico por qualquer modelo de linguagem.
- **Pronta para Versionamento no GitHub e `skills.sh`:** Os arquivos locais de credenciais `./config/gitlab.yaml` e `./config/redmine.yaml` são automaticamente protegidos pelo [`.gitignore`](./.gitignore), permitindo versionar e publicar a skill com total segurança.

### 2.1. Como Instalar via `skills.sh` (`npx skills add`)

A VERA pode ser instalada diretamente em qualquer agente de IA compatível (OpenCode, Claude Code, Cursor, Windsurf, Antigravity, etc.) através da CLI oficial do [skills.sh](https://skills.sh):

#### No projeto atual (local):
```bash
# Se o repositório contiver a pasta da skill (subpasta --skill vera):
npx skills add https://github.com/<SEU_USUARIO>/<SEU_REPOSITORIO> --skill vera

# Ou se o repositório for dedicado exclusivamente à VERA (SKILL.md na raiz):
npx skills add https://github.com/<SEU_USUARIO>/<SEU_REPOSITORIO>
```

#### Para todos os projetos da máquina (global):
```bash
npx skills add https://github.com/<SEU_USUARIO>/<SEU_REPOSITORIO> --skill vera --global
```

> **Dica:** O comando acima baixa a skill e a registra na pasta de skills do seu agente favorito (como `.agents/skills/vera/`, `.claude/skills/vera/`, etc.). Para atualizar a qualquer momento para a versão mais recente do GitHub, basta rodar `npx skills update`.

---

## 3. Integrações Somente Leitura: GitLab (`v0.3.0`) e Redmine (`v0.4.0`)

Ambas as integrações operam em modo **estritamente somente leitura (`read_only`)** e contam com **Fluxo Inteligente de Primeiro Uso (*Onboarding*)**:

1. **GitLab (`./config/gitlab.yaml` — Personal Access Token):**
   - Verifica automaticamente se `./config/gitlab.yaml` existe e possui token.
   - Caso não exista, pergunta se o usuário já possui o token ou se deseja ver o **passo a passo resumido** de como gerá-lo no GitLab (escopos `read_api` e `read_repository`).
2. **Redmine (`./config/redmine.yaml` — Chave de Acesso API):**
   - Verifica automaticamente se `./config/redmine.yaml` existe e possui a `api_key`.
   - Caso não exista, pergunta se o usuário já possui a chave ou se deseja ver o **passo a passo resumido** de como obtê-la no Redmine (*Minha conta -> Chave de acesso API -> Mostrar*).
   - Consulta issues, subtarefas, anexos, histórico de comentários e apontamentos de horas (`spent_hours`), avaliando automaticamente o **Critério Triplo de Tarefa 100% Cobrada**.

---

## 4. Regras de Ouro de Auditoria e Contagem

1. **Entendimento Acordado Economia & CAST sobre CRUD e Unidades Elementares (`[backend]` / `[backend-alteracao]`):**
   - **Devem ser contabilizados:** Unidades Elementares CRUD principais + Operações/Ações acessórias coesas (responsabilidade única e bem definida) que agreguem valor ao negócio (alertando quando pertencerem a outro item de catálogo para abertura de tarefa própria).
   - **Não devem ser contabilizados (`[desconsiderado] — 0 UM`):** Getters, Setters, métodos que apenas delegam chamadas entre camadas (`Controller`, `Service`, `DAO`), criação de classes `.java` cujas ações já foram contadas, criação de `.css`/`.xhtml`/`.js` (já cobertos nos catálogos de tela/frontend), fragmentação interna de métodos, formatação/reflow, logs puros e funções mecânicas de limpeza/reset de estado ou UI.
2. **Regra de `ENUM` (`1 UM por Commit`):**
   - Em um mesmo commit, a criação (`[backend]`) ou alteração (`[backend-alteracao]`) de **1 ou 10 `enums`** contabiliza **somente 1 UM por commit** (por categoria).
3. **Faixas de Complexidade do Catálogo Cast 13/2024 (`3 ou menos` vs. `4 ou mais unidades`):**
   - Na faixa `- 3 ou menos unidades` (`Complexidade Altíssima = Não`), aplica-se o valor base (`[backend]` = 4 UST, `[backend-alteracao]` = 2 UST, `[teste-unitario]` = 4 UST, `[frontend]` = 4 UST, `[frontend-alteracao]` = 1 UST).
   - Na faixa `- 4 ou mais unidades` (`Complexidade Altíssima = Sim`), o multiplicador de UST por U.M. dobra (`2x base`, ex.: `[backend]` passa para **8 UST/UM**, gerando 32 UST para 4 UMs).
4. **Regra de `[teste-unitario]` (`1 UM de teste por item cobrado coberto`):**
   - Contabiliza-se **1 UM de teste por item/unidade elementar cobrada que o teste cobre** ("funcionalidade coberta" aplicada à mesma contagem do código). É vedado contar por classe de teste ou dividir testes da mesma operação por camada (`ControllerTest`, `ServiceTest` e `RepositoryTest` da mesma consulta contam juntos `1 UM`).
5. **Vedação de Alteração Dupla na Mesma Entrega e Mistura de Catálogos:**
   - Alterações sobre rotas/métodos recém-criados dias antes na mesma demanda-mãe ainda não validada fazem parte da criação (`[backend]` / `[frontend]`) e não podem ser cobradas como `[*-alteracao]`.
   - É vedado misturar criação (`[frontend]` / `[backend]`) e alteração (`[frontend-alteracao]` / `[backend-alteracao]`) na mesma subtarefa (devendo-se abrir uma subtarefa irmã na mesma demanda-mãe).
6. **Auditoria Fina de Nota, Caminhos, Mocks e Metadados do Redmine:**
   - Verifica se os caminhos citados na nota batem literalmente com o `new_path` do `git diff` (sem omitir pastas intermediárias e usando `/`), se há 1 seção `"Unidade elementar N"` por UM cobrada, se existem serviços simulados/mocks (`*Simulado`, `*Mock`) impedindo a conclusão da tarefa, e se os campos `Sistema (Módulo)` e a tag do título batem com o repositório e o catálogo.
7. **Padrão Enxuto de Notas de Evidência no Redmine (Orientação Fiscal Sr. Edilson):**
   - Conforme alinhamento com a fiscalização de contratos da Economia-GO (Sr. Edilson), as notas de lançamento devem ser o mais enxutas possível:
     - **Inclusão:** `*Commit*: <url>`, `*Unidade elementar N*`, `*Comportamento entregue*: <resumo>`, `*Arquivo*: <caminho/Classe>` e `*Método*: <metodo>` (linhas são opcionais para novos arquivos/métodos).
     - **Alteração:** Obrigatório adicionar o intervalo de linhas (`*Linhas*: X a Y`).
     - **Separador:** Cada unidade elementar separada por `---`.
8. **Parâmetros Operacionais de `[Componente]` e `[Suporte]`:**
   - **`[Componente]`:** `2 UST por U.M.` (`1 UM` por arquivo `.properties`, descritor `pom.xml`/`weblogic.xml`/`web.xml`/`log4j2.xml` ou componente configurado/alterado).
   - **`[Suporte]`:** `1 UST por chamado único` (`1 UM` por atendimento/chamado SS/OS/GLPI único comprovado por anexo, com deduplicação obrigatória de múltiplos prints do mesmo chamado).
9. **Critério Triplo de Tarefa 100% Cobrada e Confronto `Categoria + UM`:**
   - Verifica se tarefas concluídas possuem Status Fechado/Validação + Evidência/Commit + Horas lançadas (`> 0h`), e confronta o previsto vs. realizado estritamente por `Categoria + Quantidade de UMs`.

---

## 5. Como Usar a VERA (Guia Rápido de Comandos no Chat)

Você pode interagir com a VERA diretamente pelo chat utilizando comandos em linguagem natural. Veja os principais exemplos de utilização:

### 5.1. Relatório Consolidado de Auditoria por Demanda-Mãe
Inspeciona a demanda-mãe no Redmine, percorre todas as subtarefas filhas, busca os commits e *diffs* no GitLab e gera um relatório completo comparando `Lançado vs. Correto (UST)` e listando `"O que fazer, por atividade"`:
- `"Gerar relatório da demanda 194956"`
- `"Gerar relatório da demanda 194956 para os lançamentos do Albino"`
- `"Auditar a demanda 194956 e suas subtarefas com a VERA"`

### 5.2. Auditoria de Subtarefa Individual no Redmine
Valida uma única subtarefa ou atividade específica verificando status, horas (`spent_hours`), campos do Catálogo Cast 13/2024, texto da nota e commit vinculado:
- `"Auditar a tarefa 197685 no Redmine com a VERA"`
- `"Verificar se a atividade 194944 está de acordo com as regras da VERA"`

### 5.3. Análise de Commit no GitLab e Geração de Nota de Cobrança (Antes de Fechar a Tarefa)
Lê o `git diff` real de um ou mais commits no GitLab, separa o que conta UM do que é `[desconsiderado] (0 UM)` e gera a tabela/nota pronta para colar no Redmine:
- `"Analisar o commit 559da18 do projeto fis/vit/infotransito-vit-service com a VERA"`
- `"Gerar proposta de cobrança de UST para o commit 1c68d3e no projeto fis/infotransito/fis-infotransito-mobile"`

### 5.4. Auditoria de Commits e Tarefas do Desenvolvedor por Período
Lista seus commits recentes no GitLab e suas tarefas/horas no Redmine para identificar entregas pendentes de cobrança ou tarefas fechadas sem horas lançadas:
- `"Verificar meus commits e tarefas desde 01/10/2026 com a VERA"`
- `"Listar minhas tarefas e horas lançadas no Redmine neste mês usando a VERA"`

### 5.5. Consulta de Regras do Catálogo e Acordo Economia & CAST
Tira dúvidas rápidas sobre enquadramento, faixas de complexidade e contagem de unidades elementares:
- `"Segundo a VERA, como devo contabilizar testes unitários e enums?"`
- `"Qual a diferença entre [frontend] e [frontend-alteracao] na VERA?"`

### 5.6. Configuração e Teste de Conectividade (GitLab e Redmine)
Inicia o fluxo de configuração guiada (*Onboarding*) ou testa se os tokens locais estão funcionando:
- `"Quero configurar ou testar minha conexão com o GitLab usando a VERA"`
- `"Quero configurar ou testar minha conexão com o Redmine usando a VERA"`

---

## 6. Estrutura de Diretórios e Responsabilidades

```text
vera/
├── SKILL.md                                    # Manifesto principal da Agent Skill (especificação SKILL.md)
├── README.md                                   # Documentação geral do projeto e guia de comandos
├── CHANGELOG.md                                # Histórico de alterações por versão
├── ROADMAP.md                                  # Planejamento evolutivo das versões (v0.1.0 até v1.0.0)
├── .gitignore                                  # Protege config/gitlab.yaml, config/redmine.yaml e segredos
│
├── config/                                     # Configurações e modelos de conectores
│   ├── redmine.example.yaml                    # Modelo do arquivo redmine.yaml (API Key)
│   ├── gitlab.example.yaml                     # Modelo do arquivo gitlab.yaml (Personal Access Token)
│   └── vera.yaml                               # Configuração geral ativa e versionada da skill (sem segredos)
│
├── catalogs/                                   # Catálogos estruturados e schemas (Implementado v0.2.0)
│   ├── README.md                               # Índice rápido das 31 atividades e regras principais
│   ├── catalog.schema.json                     # JSON Schema (Draft 2020-12) para validação formal
│   └── catalogo-atividades.yaml                # Catálogo completo + Acordo Economia/CAST, faixas e Enum
│
├── references/                                 # Documentação técnica detalhada de referência
│   ├── architecture.md                         # Arquitetura modular, princípios e fluxo de dados
│   ├── redmine.md                              # Integração API Key, auditoria de demanda e critério triplo
│   ├── gitlab.md                               # Integração PAT, onboarding, passo a passo e coleta de diffs
│   └── billing-catalogs.md                     # Acordo Economia/CAST sobre CRUD, faixas, testes e Enum
│
├── templates/                                  # Modelos padronizados de relatórios Markdown
│   ├── README.md                               # Diretrizes de preenchimento e revisão humana
│   ├── demand-audit-report.template.md         # Template oficial de Relatório de Auditoria por Demanda
│   ├── ust-validation-report.template.md       # Template oficial de proposta individual de UST
│   └── redmine-task-note.template.md           # Template oficial de nota enxuta para o Redmine (Fiscal Sr. Edilson)
│
├── scripts/                                    # Conectores Read-Only de coleta automatizada (v0.3.0 / v0.4.0)
│   ├── README.md                               # Guia de uso dos scripts conectores
│   ├── gitlab-connector.ps1                    # Conector GitLab Read-Only (PowerShell)
│   ├── gitlab-connector.sh                     # Conector GitLab Read-Only (Bash)
│   ├── redmine-connector.ps1                   # Conector Redmine Read-Only (PowerShell - inclui -Action demand)
│   └── redmine-connector.sh                    # Conector Redmine Read-Only (Bash)
│
└── examples/                                   # Exemplos de entrada/saída e casos de estudo fictícios
    └── README.md                               # Organização dos exemplos de uso e validação
```

---

## 7. Roadmap Resumido

| Versão | Marco Principal | Status | Foco da Entrega |
| :---: | :--- | :---: | :--- |
| **`v0.1.0`** | **Fundação** | Concluído | Estrutura inicial de diretórios, `SKILL.md`, documentação e configs de exemplo. |
| **`v0.2.0`** | **Catálogos e Regras** | Concluído | `catalogo-atividades.yaml` (31 atividades), Acordo Economia/CAST, regra de `enum`, filtros `0 UM` e template de relatório. |
| **`v0.3.0`** | **GitLab** | Concluído | Conector somente leitura via Personal Access Token (`gitlab.yaml`), onboarding interativo e extração de commits/diffs. |
| **`v0.4.0`** | **Redmine** | Concluído | Conector somente leitura via Chave de Acesso API (`redmine.yaml`), onboarding interativo e consulta a tarefas, anexos, journals e horas. |
| **`v0.5.0`** | **Padrão Enxuto Fiscal Edilson** *(Atual)* | **Concluído** | Padrão oficial de notas enxutas no Redmine para inclusão e alteração, novo template de nota e formalização nos catálogos. |
| **`v0.5.0`** | **Validação** | Planejado | Automação em lote do motor de cruzamento `Categoria + UM` e detecção de inconsistências. |
| **`v0.6.0`** | **Relatórios** | Planejado | Renderização automatizada em lote de relatórios Markdown e painéis de auditoria. |
| **`v1.0.0`** | **Operacional** | Planejado | Fluxo integrado ponta a ponta, suíte de testes, tratamento robusto de erros e publicação no `skills.sh`. |

Consulte o detalhamento completo em [`ROADMAP.md`](./ROADMAP.md) e o histórico em [`CHANGELOG.md`](./CHANGELOG.md).
