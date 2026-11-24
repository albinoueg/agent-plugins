# Diretório de Scripts (`scripts/`)

> **Status (`v0.4.0`):** Conectores somente leitura do **GitLab** e do **Redmine** implementados em PowerShell (`.ps1`) e Bash (`.sh`), 100% portáveis, sem dependências externas e com onboarding interativo.

---

## 1. Scripts Disponíveis

| Script | Ambiente | Responsabilidade |
| :--- | :--- | :--- |
| [`gitlab-connector.ps1`](./gitlab-connector.ps1) | Windows PowerShell 5.1+ / PowerShell 7+ | Gerencia o Personal Access Token em `./config/gitlab.yaml`, exibe guia passo a passo, testa autenticação e consulta commits, branches e diffs no GitLab. |
| [`gitlab-connector.sh`](./gitlab-connector.sh) | Linux / macOS / Git Bash (`bash` + `curl`) | Equivalente em Shell Script para o conector do GitLab. |
| [`redmine-connector.ps1`](./redmine-connector.ps1) | Windows PowerShell 5.1+ / PowerShell 7+ | Gerencia a Chave de Acesso API em `./config/redmine.yaml`, exibe guia passo a passo, testa autenticação e consulta tarefas, subtarefas, anexos, journals e horas no Redmine. |
| [`redmine-connector.sh`](./redmine-connector.sh) | Linux / macOS / Git Bash (`bash` + `curl`) | Equivalente em Shell Script para o conector do Redmine. |

---

## 2. Como Utilizar o Conector Redmine (`redmine-connector.ps1`)

1. **Verificar Status da Configuração (`check-config`):**
   ```powershell
   powershell -ExecutionPolicy Bypass -File ./scripts/redmine-connector.ps1 -Action check-config
   ```
2. **Exibir Guia Passo a Passo para Obter a Chave API (`token-guide`):**
   ```powershell
   powershell -ExecutionPolicy Bypass -File ./scripts/redmine-connector.ps1 -Action token-guide
   ```
3. **Configurar Interativamente ou via Parâmetros (`setup`):**
   ```powershell
   # Modo Interativo (oferece opção de informar a chave ou ver o passo a passo):
   powershell -ExecutionPolicy Bypass -File ./scripts/redmine-connector.ps1 -Action setup

   # Modo Direto (gravando em ./config/redmine.yaml):
   powershell -ExecutionPolicy Bypass -File ./scripts/redmine-connector.ps1 -Action setup -BaseUrl "https://gestaoprojetosti.economia.go.gov.br" -ApiKey "SUA_API_KEY"
   ```
4. **Testar Conexão e Autenticação (`test`):**
   ```powershell
   powershell -ExecutionPolicy Bypass -File ./scripts/redmine-connector.ps1 -Action test
   ```
5. **Consultar Tarefa Completa, Anexos, Notas e Horas (`issue`):**
   ```powershell
   powershell -ExecutionPolicy Bypass -File ./scripts/redmine-connector.ps1 -Action issue -IssueId "193554"
   ```
6. **Auditar Demanda-Mãe Completa e Todas as Subtarefas Filhas (`demand`):**
   ```powershell
   # Todas as subtarefas da demanda #194956:
   powershell -ExecutionPolicy Bypass -File ./scripts/redmine-connector.ps1 -Action demand -IssueId "194956" -NonInteractive

   # Filtrando subtarefas por responsável (ex.: Albino):
   powershell -ExecutionPolicy Bypass -File ./scripts/redmine-connector.ps1 -Action demand -IssueId "194956" -Assignee "Albino" -NonInteractive
   ```
7. **Listar Minhas Tarefas (`my-issues`) e Horas (`time-entries`):**
   ```powershell
   powershell -ExecutionPolicy Bypass -File ./scripts/redmine-connector.ps1 -Action my-issues
   powershell -ExecutionPolicy Bypass -File ./scripts/redmine-connector.ps1 -Action time-entries -IssueId "193554"
   ```

---

## 3. Como Utilizar o Conector GitLab (`gitlab-connector.ps1`)

1. **Verificar Status / Guia / Setup / Teste:**
   ```powershell
   powershell -ExecutionPolicy Bypass -File ./scripts/gitlab-connector.ps1 -Action check-config
   powershell -ExecutionPolicy Bypass -File ./scripts/gitlab-connector.ps1 -Action token-guide
   powershell -ExecutionPolicy Bypass -File ./scripts/gitlab-connector.ps1 -Action test
   ```
2. **Consultar Commit + Diff (`commit`) e Buscar por Tarefa (`search-task`):**
   ```powershell
   powershell -ExecutionPolicy Bypass -File ./scripts/gitlab-connector.ps1 -Action commit -Project "grupo/projeto" -Sha "HASH_DO_COMMIT"
   powershell -ExecutionPolicy Bypass -File ./scripts/gitlab-connector.ps1 -Action search-task -Project "grupo/projeto" -TaskId "193554"
   ```

---

## 4. Regras de Segurança e Arquitetura

1. **Operação Estritamente Somente Leitura (*Read-Only*):** Os scripts realizam apenas chamadas `GET`.
2. **Armazenamento Protegido:** Os arquivos `./config/gitlab.yaml` e `./config/redmine.yaml` são automaticamente ignorados pelo [`.gitignore`](../.gitignore).
3. **Zero Caminhos Fixos de Máquina:** Os scripts resolvem o diretório da skill dinamicamente (`$PSScriptRoot` / `BASH_SOURCE`), garantindo funcionamento idêntico em qualquer máquina ou instalação via `skills.sh`.
