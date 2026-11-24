#!/usr/bin/env bash
# =============================================================================
# VERA — Conector Somente Leitura do GitLab (Bash / Linux / macOS / Git Bash)
# =============================================================================
# Gerencia a configuração do Personal Access Token em `./config/gitlab.yaml`
# (arquivo não versionado), exibe o passo a passo de obtenção do token e
# realiza consultas estritamente Read-Only (GET) na API REST v4 do GitLab.
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG_DIR="$SKILL_ROOT/config"
CONFIG_FILE="$CONFIG_DIR/gitlab.yaml"

ACTION="${1:-check-config}"
shift || true

BASE_URL=""
TOKEN=""
DEFAULT_PROJECT=""
PROJECT=""
SHA=""
TASK_ID=""
NON_INTERACTIVE="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --base-url|-BaseUrl) BASE_URL="$2"; shift 2 ;;
    --token|-Token) TOKEN="$2"; shift 2 ;;
    --default-project|-DefaultProject) DEFAULT_PROJECT="$2"; shift 2 ;;
    --project|-Project) PROJECT="$2"; shift 2 ;;
    --sha|-Sha) SHA="$2"; shift 2 ;;
    --task-id|-TaskId) TASK_ID="$2"; shift 2 ;;
    --non-interactive|-NonInteractive) NON_INTERACTIVE="true"; shift 1 ;;
    *) shift 1 ;;
  esac
done

show_token_guide() {
  cat << 'EOF'
===============================================================================
 PASSO A PASSO RESUMIDO: COMO OBTER SEU PERSONAL ACCESS TOKEN NO GITLAB
===============================================================================
1. Acesse o GitLab da sua organização no navegador e faça login.
2. No canto superior esquerdo (ou direito), clique no seu Avatar (Foto de Perfil)
   e selecione 'Edit profile' (Editar perfil) ou 'Preferences' (Preferências).
3. No menu lateral esquerdo, clique em 'Access Tokens' (Tokens de Acesso)
   ou 'Personal access tokens'.
4. Clique no botão 'Add new token' (Adicionar novo token).
5. Preencha os campos do token:
   - Token name (Nome): VERA-Skill-ReadOnly
   - Expiration date (Expiração): Escolha uma data futura (ou deixe em branco, se permitido).
   - Select scopes (Escopos — MARQUE APENAS ESTES DOIS DE LEITURA):
     [x] read_api         (Permite consultar a API do GitLab em modo leitura)
     [x] read_repository  (Permite ler commits, branches e diffs)
6. Clique em 'Create personal access token' (Criar token de acesso pessoal).
7. COPIE O TOKEN GERADO IMEDIATAMENTE (ele só é exibido uma única vez na tela!).
===============================================================================
EOF
}

read_config() {
  CFG_EXISTS="false"
  CFG_URL=""
  CFG_TOKEN=""
  CFG_PROJ=""
  if [[ -f "$CONFIG_FILE" ]]; then
    CFG_EXISTS="true"
    CFG_URL="$(grep -E '^\s*base_url\s*:' "$CONFIG_FILE" | head -n1 | sed -E 's/^\s*base_url\s*:\s*["'\'']?([^"'\''#]+)["'\'']?.*/\1/' | sed 's:/*$::' | xargs || true)"
    CFG_TOKEN="$(grep -E '^\s*personal_access_token\s*:' "$CONFIG_FILE" | head -n1 | sed -E 's/^\s*personal_access_token\s*:\s*["'\'']?([^"'\''#]+)["'\'']?.*/\1/' | xargs || true)"
    CFG_PROJ="$(grep -E '^\s*default_project\s*:' "$CONFIG_FILE" | head -n1 | sed -E 's/^\s*default_project\s*:\s*["'\'']?([^"'\''#]+)["'\'']?.*/\1/' | xargs || true)"
  fi
}

save_config() {
  local url="${1%/}"
  local pat="$2"
  local proj="${3:-}"
  mkdir -p "$CONFIG_DIR"
  cat > "$CONFIG_FILE" << EOF
# =============================================================================
# VERA — Configuração Local do Módulo GitLab (NÃO VERSIONADO)
# =============================================================================

gitlab:
  base_url: "$url"
  api_version: "v4"

  auth:
    personal_access_token: "$pat"
    verify_ssl: true
    timeout_seconds: 30

  access_mode: "read_only"
  default_project: "$proj"

  traceability_patterns:
    issue_reference_regex: "(?:#|Demanda\\s+#?|refs\\s+#|RM-)(\\d+)"
    branch_issue_regex: "(?:^(?:feature|bugfix|hotfix|task)/|^)(\\d+)[-_].+"
EOF
}

case "$ACTION" in
  token-guide)
    show_token_guide
    ;;
  check-config)
    read_config
    HAS_URL="false"
    HAS_TOKEN="false"
    [[ -n "$CFG_URL" && "$CFG_URL" != "https://gitlab.exemplo.gov.br" ]] && HAS_URL="true"
    [[ -n "$CFG_TOKEN" && "$CFG_TOKEN" != "SEU_PERSONAL_ACCESS_TOKEN_AQUI" ]] && HAS_TOKEN="true"
    CONFIGURED="false"
    STATUS="ONBOARDING_REQUIRED"
    if [[ "$HAS_URL" == "true" && "$HAS_TOKEN" == "true" ]]; then
      CONFIGURED="true"
      STATUS="READY"
    fi
    printf '{\n  "status": "%s",\n  "configured": %s,\n  "config_exists": %s,\n  "has_base_url": %s,\n  "has_token": %s,\n  "base_url": "%s",\n  "default_project": "%s",\n  "config_path": "./config/gitlab.yaml"\n}\n' \
      "$STATUS" "$CONFIGURED" "$CFG_EXISTS" "$HAS_URL" "$HAS_TOKEN" "$CFG_URL" "$CFG_PROJ"
    ;;
  setup)
    if [[ -n "$BASE_URL" && -n "$TOKEN" ]]; then
      save_config "$BASE_URL" "$TOKEN" "$DEFAULT_PROJECT"
      printf '{\n  "status": "CONFIG_SAVED",\n  "config_path": "./config/gitlab.yaml",\n  "base_url": "%s",\n  "git_ignored": true\n}\n' "${BASE_URL%/}"
    else
      echo "[VERA - Configuração Inicial do GitLab]"
      echo "  [1] Já possuo meu Personal Access Token (informar agora)"
      echo "  [2] Não sei como obter o Personal Access Token no GitLab (ver passo a passo)"
      read -r -p "Escolha uma opção (1 ou 2): " opt
      if [[ "$opt" == "2" ]]; then
        show_token_guide
      fi
      read -r -p "Informe a URL base do GitLab: " in_url
      read -r -p "Informe o seu Personal Access Token: " in_pat
      read -r -p "Projeto padrão opcional (Enter para pular): " in_proj
      save_config "$in_url" "$in_pat" "$in_proj"
      echo "Configuração salva com sucesso em './config/gitlab.yaml'."
    fi
    ;;
  test)
    read_config
    if [[ -z "$CFG_URL" || -z "$CFG_TOKEN" || "$CFG_URL" == "https://gitlab.exemplo.gov.br" ]]; then
      echo '{"status": "ONBOARDING_REQUIRED", "message": "Configure ./config/gitlab.yaml primeiro."}'
      exit 2
    fi
    curl -sS --fail -H "PRIVATE-TOKEN: $CFG_TOKEN" "$CFG_URL/api/v4/user"
    ;;
esac
