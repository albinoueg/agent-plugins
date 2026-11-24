#!/usr/bin/env bash
# =============================================================================
# VERA - Conector Somente Leitura do Redmine (Bash / Linux / macOS / Git Bash)
# =============================================================================
# Gerencia a configuracao da Chave de Acesso API em `./config/redmine.yaml`
# (arquivo nao versionado), exibe o passo a passo de obtencao da chave e
# realiza consultas estritamente Read-Only (GET) na API REST do Redmine.
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG_DIR="$SKILL_ROOT/config"
CONFIG_FILE="$CONFIG_DIR/redmine.yaml"

ACTION="${1:-check-config}"
shift || true

BASE_URL=""
API_KEY=""
DEFAULT_PROJECT=""
ISSUE_ID=""
NON_INTERACTIVE="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --base-url|-BaseUrl) BASE_URL="$2"; shift 2 ;;
    --api-key|-ApiKey|--token|-Token) API_KEY="$2"; shift 2 ;;
    --default-project|-DefaultProject) DEFAULT_PROJECT="$2"; shift 2 ;;
    --issue-id|-IssueId) ISSUE_ID="$2"; shift 2 ;;
    --non-interactive|-NonInteractive) NON_INTERACTIVE="true"; shift 1 ;;
    *) shift 1 ;;
  esac
done

show_token_guide() {
  cat << 'EOF'
===============================================================================
 PASSO A PASSO RESUMIDO: COMO OBTER SUA CHAVE DE ACESSO API NO REDMINE
===============================================================================
1. Acesse o Redmine da sua organizacao no navegador e faca login.
2. No canto superior direito da tela, clique em 'Minha conta' (My account).
3. Na coluna lateral direita da pagina, localize a secao
   'Chave de acesso API' (API access key).
4. Clique no link 'Mostrar' (Show) para exibir sua chave.
   (Observacao: caso ainda nao tenha uma chave gerada, clique em 'Redefinir' / 'Reset').
5. COPIE A CHAVE ALFANUMERICA EXIBIDA (ex.: 40 caracteres hexadecimais).
===============================================================================
EOF
}

read_config() {
  CFG_EXISTS="false"
  CFG_URL=""
  CFG_KEY=""
  CFG_PROJ=""
  if [[ -f "$CONFIG_FILE" ]]; then
    CFG_EXISTS="true"
    CFG_URL="$(grep -E '^\s*base_url\s*:' "$CONFIG_FILE" | head -n1 | sed -E 's/^\s*base_url\s*:\s*["'\'']?([^"'\''#]+)["'\'']?.*/\1/' | sed 's:/*$::' | xargs || true)"
    CFG_KEY="$(grep -E '^\s*api_key\s*:' "$CONFIG_FILE" | head -n1 | sed -E 's/^\s*api_key\s*:\s*["'\'']?([^"'\''#]+)["'\'']?.*/\1/' | xargs || true)"
    CFG_PROJ="$(grep -E '^\s*default_project\s*:' "$CONFIG_FILE" | head -n1 | sed -E 's/^\s*default_project\s*:\s*["'\'']?([^"'\''#]+)["'\'']?.*/\1/' | xargs || true)"
  fi
}

save_config() {
  local url="${1%/}"
  local key="$2"
  local proj="${3:-}"
  mkdir -p "$CONFIG_DIR"
  cat > "$CONFIG_FILE" << EOF
# =============================================================================
# VERA - Configuracao Local do Modulo Redmine (NAO VERSIONADO)
# =============================================================================

redmine:
  base_url: "$url"

  auth:
    api_key: "$key"
    verify_ssl: true
    timeout_seconds: 30

  access_mode: "read_only"
  default_project: "$proj"

  defaults:
    include_subtasks: true
    include_journals: true
    include_attachments: true
    include_time_entries: true
    pagination_limit: 100
EOF
}

case "$ACTION" in
  token-guide)
    show_token_guide
    ;;
  check-config)
    read_config
    HAS_URL="false"
    HAS_KEY="false"
    [[ -n "$CFG_URL" && "$CFG_URL" != "https://redmine.exemplo.gov.br" ]] && HAS_URL="true"
    [[ -n "$CFG_KEY" && "$CFG_KEY" != "SUA_API_KEY_AQUI" ]] && HAS_KEY="true"
    CONFIGURED="false"
    STATUS="ONBOARDING_REQUIRED"
    if [[ "$HAS_URL" == "true" && "$HAS_KEY" == "true" ]]; then
      CONFIGURED="true"
      STATUS="READY"
    fi
    printf '{\n  "status": "%s",\n  "configured": %s,\n  "config_exists": %s,\n  "has_base_url": %s,\n  "has_api_key": %s,\n  "base_url": "%s",\n  "default_project": "%s",\n  "config_path": "./config/redmine.yaml"\n}\n' \
      "$STATUS" "$CONFIGURED" "$CFG_EXISTS" "$HAS_URL" "$HAS_KEY" "$CFG_URL" "$CFG_PROJ"
    ;;
  setup)
    if [[ -n "$BASE_URL" && -n "$API_KEY" ]]; then
      save_config "$BASE_URL" "$API_KEY" "$DEFAULT_PROJECT"
      printf '{\n  "status": "CONFIG_SAVED",\n  "config_path": "./config/redmine.yaml",\n  "base_url": "%s",\n  "git_ignored": true\n}\n' "${BASE_URL%/}"
    else
      echo "[VERA - Configuracao Inicial do Redmine]"
      echo "  [1] Ja possuo minha Chave de Acesso API do Redmine (informar agora)"
      echo "  [2] Nao sei como obter a Chave de Acesso API no Redmine (ver passo a passo)"
      read -r -p "Escolha uma opcao (1 ou 2): " opt
      if [[ "$opt" == "2" ]]; then
        show_token_guide
      fi
      read -r -p "Informe a URL base do Redmine: " in_url
      read -r -p "Informe a sua Chave de Acesso API: " in_key
      read -r -p "Projeto padrao opcional (Enter para pular): " in_proj
      save_config "$in_url" "$in_key" "$in_proj"
      echo "Configuracao salva com sucesso em './config/redmine.yaml'."
    fi
    ;;
  test)
    read_config
    if [[ -z "$CFG_URL" || -z "$CFG_KEY" || "$CFG_URL" == "https://redmine.exemplo.gov.br" ]]; then
      echo '{"status": "ONBOARDING_REQUIRED", "message": "Configure ./config/redmine.yaml primeiro."}'
      exit 2
    fi
    curl -sS --fail -H "X-Redmine-API-Key: $CFG_KEY" "$CFG_URL/users/current.json"
    ;;
  issue|demand)
    read_config
    CLEAN_ID="${ISSUE_ID#\#}"
    curl -sS --fail -H "X-Redmine-API-Key: $CFG_KEY" "$CFG_URL/issues/${CLEAN_ID}.json?include=children,attachments,relations,journals"
    ;;
esac
