# Diretório de Catálogos (`catalogs/`)

> **Status (`v0.2.0`):** Catálogo de Atividades (Anexo I — Repertório de Estimativas) + Entendimentos Acordados Economia & CAST estruturados em YAML e acompanhados de JSON Schema formal.

---

## 1. Arquivos Disponíveis

| Arquivo | Formato | Descrição |
| :--- | :---: | :--- |
| [`catalogo-atividades.yaml`](./catalogo-atividades.yaml) | YAML | **Catálogo canônico ativo.** Contém a hierarquia de fontes de verdade, o entendimento acordado Economia & CAST sobre CRUD/Unidades Elementares, a regra de `enum` (1 UM/commit), as 4 sessões e as 31 atividades com regras de UST e checklists de auditoria. |
| [`catalog.schema.json`](./catalog.schema.json) | JSON Schema | **Contrato formal de estrutura (Draft 2020-12).** Define os campos obrigatórios, tipos de dados e enumerações aceitas para qualquer catálogo adicionado a este diretório. |

---

## 2. Destaques das Regras Incorporadas (`catalogo-atividades.yaml`)

1. **Entendimento Economia & CAST sobre CRUD e Unidades Elementares (`[backend]` / `[backend-alteracao]`):**
   - **Contabilizar:** Unidades Elementares CRUD principais + Operações/Ações acessórias coesas (responsabilidade única e bem definida) que agreguem valor ao negócio (alertando quando pertencerem a outro item de catálogo).
   - **Não Contabilizar (`[desconsiderado] — 0 UM`):** Getters, Setters, métodos de delegação entre camadas (`Controller`, `Service`, `DAO`), criação de classes `.java` cujas ações já foram contadas, criação de `.css`/`.xhtml`/`.js` (pertencentes aos catálogos de tela/frontend), fragmentação de método coeso em partes menores, formatação pura, logs puros e funções mecânicas de limpeza/reset.
2. **Regra de `ENUM` (`1 UM por Commit`):**
   - Em um mesmo commit, a criação (`[backend]`) ou alteração (`[backend-alteracao]`) de **1 ou 10 `enums`** contabiliza **somente 1 UM por commit** (por categoria).
3. **Regras Atualizadas de `[Componente]` e `[Suporte]`:**
   - **`[Componente]`:** `2 UST por U.M.` (1 UM por arquivo de propriedades `.properties`, descritor `pom.xml`/`web.xml`/`weblogic.xml`/`log4j2.xml` ou componente configurado/alterado).
   - **`[Suporte]`:** `1 UST por chamado único` (1 UM por atendimento/chamado SS/OS/GLPI único comprovado por anexo, com deduplicação obrigatória de múltiplos prints do mesmo chamado).

---

## 3. Índice Rápido das 31 Atividades (`catalogo-atividades.yaml`)

### Sessão 1 — Atividades de Design e UX
| Tag | Título | Unidade de Medida | UST | Exige Git? |
| :--- | :--- | :--- | :---: | :---: |
| `[Protótipo]` | Elaboração de protótipo ou wireframe | Por tela | `4` | Não |
| `[Imagem]` | Elaboração de ícone ou imagem vetorial | Único | `2` | Quando aplicável |

### Sessão 2 — Atividades de Análise e Projeto
| Tag | Título | Unidade de Medida | UST | Exige Git? |
| :--- | :--- | :--- | :---: | :---: |
| `[Backlog]` | Backlog | Para até 7 user-stories ou demandas | `16` | Não |
| `[Modelo]` | Modelo de dados | Número de classes de objeto | `1` | Não |
| `[sprint-review-restrospective]` | Sprint review-retrospective | Por participante da contratada | `4` | Não |
| `[user-story]` | Especificação de funcionalidade (user story) | Por critério de aceitação | `2` | Não |
| `[plano-trabalho]` | Elaborar plano de trabalho | 2 USTs para cada 80 USTs planejadas | `2` | Não |
| `[arquitetura]` | Elaboração do Desenho/Arquitetura da solução | Único | `36` | Não |
| `[avaliacao-squad]` | Elaboração de documento de avaliação de squad *(Requer autorização prévia)* | Único | `36` | Não |

### Sessão 3 — Atividades de Desenvolvimento e Implantação
| Tag | Título | Unidade de Medida | UST | Exige Git? |
| :--- | :--- | :--- | :---: | :---: |
| `[backend]` | Criação de funcionalidade no backend do sistema | Qtd. operações CRUD / Unid. Elementares (+ máx. 1 UM/commit p/ Enums) | `4` | **Obrigatório** |
| `[backend-alteracao]` | Alteração ou reuso de funcionalidade no backend | Qtd. operações CRUD / Unid. Elementares (+ máx. 1 UM/commit p/ Enums) | `2` | **Obrigatório** |
| `[teste-unitario]` | Criação de teste automatizado de back-end | Qtd. funcionalidade back-end coberta | `4` | **Obrigatório** |
| `[teste-unitario-alteracao]` | Alteração de teste de bac-kend | Qtd. funcionalidade back-end coberta | `2` | **Obrigatório** |
| `[relatorio]` | Elaboração de relatório em arquivo | Por relatório em arquivo elaborado | `10` | **Obrigatório** |
| `[relatorio-alteracao]` | Alteração de relatório em arquivo | Por alteração em relatório em arquivo | `6` | **Obrigatório** |
| `[frontend]` | Criação de funcionalidade de usabilidade no front end | Quantidade de funcionalidade | `4` | **Obrigatório** |
| `[frontend-alteracao]` | Alteração/reuso no front end e funcionalidade simples | Quantidade de funcionalidade | `1` | **Obrigatório** |
| `[problema]` | Verificação e registro de problema | Único | `2` *(ou `0` garantia)* | Não |
| `[deploy]` | Deploy de sistema | Ambiente | `1` | Quando aplicável |
| `[configuracao-sistema]` | Configuração de sistema | Quantidade de ambientes | `4` | Quando aplicável |
| `[Componente]` | Configuração/execução de componente (Biblioteca/Rotina/Extensão) | Qtd. de arquivos de propriedades/descritores/componentes (1 UM/arq) | `2` | Quando aplicável |
| `[Script]` | Elaboração e execução de scripts | 1 UST por cada 4 tabelas | `1` | Quando aplicável |
| `[Teste]` | Teste funcional | Por critério de aceitação ou funcionalidade | `1` | Não |

### Sessão 4 — Atividades de Suporte e Documentação
| Tag | Título | Unidade de Medida | UST | Exige Git? |
| :--- | :--- | :--- | :---: | :---: |
| `[Registro-tarefa]` | Registro de ocorrências e tarefas (Itop e Redmine) | Registro | `0,15` | Não |
| `[Suporte]` | Suporte | Qtd. de atendimentos/chamados únicos comprovados por anexo | `1` | Não |
| `[Manual-usuário]` | Elaboração de manual de usuário | História de Usuário | `1` | Não |
| `[Documento]` | Elaboração de documentação auxiliar *(Excepcional / Requer autorização prévia)* | Quantidade de horas de elaboração | `1` | Não |
| `[Parecer-técnico]` | Análise e elaboração de Parecer técnico *(Excepcional / Requer autorização prévia)* | Hora de análise e elaboração | `1` | Não |
| `[Configuracao]` | Configuração de sistema e/ou perfil | Único | `1` | Não |
| `[Treinamento-presencial]` | Realizar treinamento técnico presencial | Hora/aula | `1` | Não |
| `[Reuniao]` | Participação em reuniões | Único (1 por hora de reunião) | `1` | Não |
