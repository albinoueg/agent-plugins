<#
.SYNOPSIS
    Conector Somente Leitura do GitLab para a Skill VERA (v0.3.0).
.DESCRIPTION
    Gerencia a configuracao do Personal Access Token (PAT) em ./config/gitlab.yaml
    (arquivo local nao versionado), exibe o passo a passo de obtencao do token
    quando o usuario nao souber como gera-lo, testa a conectividade e realiza
    consultas estritamente Read-Only (GET) na API REST v4 do GitLab.
    100% portavel: utiliza apenas caminhos relativos ao diretorio da skill.
#>

param(
    [Parameter(Position = 0)]
    [ValidateSet("check-config", "token-guide", "setup", "test", "commit", "search-task", "my-commits")]
    [string]$Action = "check-config",

    [string]$BaseUrl = "",
    [string]$Token = "",
    [string]$DefaultProject = "",
    [string]$Project = "",
    [string]$Sha = "",
    [string]$TaskId = "",
    [string]$Since = "",
    [switch]$NonInteractive
)

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Caminhos 100% relativos a raiz da skill (independente de maquina)
$SkillRoot = Split-Path -Parent $PSScriptRoot
$ConfigDir = Join-Path $SkillRoot "config"
$ConfigFile = Join-Path $ConfigDir "gitlab.yaml"

function Show-TokenGuide {
    Write-Output "==============================================================================="
    Write-Output " PASSO A PASSO RESUMIDO: COMO OBTER SEU PERSONAL ACCESS TOKEN NO GITLAB"
    Write-Output "==============================================================================="
    Write-Output "1. Acesse o GitLab da sua organizacao no navegador e faca login."
    Write-Output "2. No canto superior esquerdo (ou direito), clique no seu Avatar (Foto de Perfil)"
    Write-Output "   e selecione 'Edit profile' (Editar perfil) ou 'Preferences' (Preferencias)."
    Write-Output "3. No menu lateral esquerdo, clique em 'Access Tokens' (Tokens de Acesso)"
    Write-Output "   ou 'Personal access tokens'."
    Write-Output "4. Clique no botao 'Add new token' (Adicionar novo token)."
    Write-Output "5. Preencha os campos do token:"
    Write-Output "   - Token name (Nome): VERA-Skill-ReadOnly"
    Write-Output "   - Expiration date (Expiracao): Escolha uma data futura (ou deixe em branco)."
    Write-Output "   - Select scopes (Escopos - MARQUE APENAS ESTES DOIS DE LEITURA):"
    Write-Output "     [x] read_api         (Permite consultar a API do GitLab em modo leitura)"
    Write-Output "     [x] read_repository  (Permite ler commits, branches e diffs)"
    Write-Output "6. Clique em 'Create personal access token' (Criar token de acesso pessoal)."
    Write-Output "7. COPIE O TOKEN GERADO IMEDIATAMENTE (ele so e exibido uma unica vez na tela!)."
    Write-Output "==============================================================================="
}

function Read-GitLabConfig {
    $result = [ordered]@{
        config_exists   = (Test-Path $ConfigFile)
        configured      = $false
        has_base_url    = $false
        has_token       = $false
        base_url        = ""
        default_project = ""
        token           = ""
    }

    if (-not $result.config_exists) {
        return $result
    }

    $lines = Get-Content -Path $ConfigFile -Encoding UTF8
    foreach ($line in $lines) {
        if ($line -match '^\s*base_url\s*:\s*(.+)$') {
            $val = $Matches[1].Trim() -replace '^["'']|["'']$', ''
            $val = ($val -split '#')[0].Trim().TrimEnd('/')
            if ($val -and $val -ne "https://gitlab.exemplo.gov.br") {
                $result.base_url = $val
                $result.has_base_url = $true
            } elseif ($val) {
                $result.base_url = $val
            }
        }
        if ($line -match '^\s*personal_access_token\s*:\s*(.+)$') {
            $val = ($Matches[1] -split '#')[0].Trim() -replace '^["'']|["'']$', ''
            if ($val -and $val -ne "SEU_PERSONAL_ACCESS_TOKEN_AQUI") {
                $result.token = $val
                $result.has_token = $true
            }
        }
        if ($line -match '^\s*default_project\s*:\s*(.+)$') {
            $val = ($Matches[1] -split '#')[0].Trim() -replace '^["'']|["'']$', ''
            $result.default_project = $val
        }
    }

    if ($result.has_base_url -and $result.has_token) {
        $result.configured = $true
    }

    return $result
}

function Save-GitLabConfig {
    param(
        [string]$Url,
        [string]$Pat,
        [string]$DefProj = ""
    )

    $cleanUrl = $Url.Trim().TrimEnd('/')
    $cleanPat = $Pat.Trim()
    $cleanProj = $DefProj.Trim()

    if (-not (Test-Path $ConfigDir)) {
        New-Item -ItemType Directory -Path $ConfigDir -Force | Out-Null
    }

    $yamlContent = @"
# =============================================================================
# VERA - Configuracao Local do Modulo GitLab (NAO VERSIONADO)
# =============================================================================
# ATENCAO: Este arquivo contem seu Personal Access Token pessoal e esta
# protegido no .gitignore para nunca ser enviado ao GitHub.
# =============================================================================

gitlab:
  base_url: "$cleanUrl"
  api_version: "v4"

  auth:
    personal_access_token: "$cleanPat"
    verify_ssl: true
    timeout_seconds: 30

  access_mode: "read_only"
  default_project: "$cleanProj"

  traceability_patterns:
    issue_reference_regex: "(?:#|Demanda\\s+#?|refs\\s+#|RM-)(\\d+)"
    branch_issue_regex: "(?:^(?:feature|bugfix|hotfix|task)/|^)(\\d+)[-_].+"

  diff_analysis:
    include_merge_commits: false
    max_diff_lines_per_commit: 5000
    ignored_paths:
      - "package-lock.json"
      - "yarn.lock"
      - "poetry.lock"
      - "*.min.js"
      - "*.min.css"
"@

    Set-Content -Path $ConfigFile -Value $yamlContent -Encoding UTF8
}

function Invoke-InteractiveOnboarding {
    param($CurrentConfig)

    Write-Output ""
    Write-Output "[VERA - Configuracao Inicial do GitLab]"
    Write-Output "O arquivo 'config/gitlab.yaml' ainda nao existe ou nao possui um Personal Access Token cadastrado."
    Write-Output ""
    Write-Output "Como voce deseja prosseguir?"
    Write-Output "  [1] Ja possuo meu Personal Access Token (informar agora)"
    Write-Output "  [2] Nao sei como obter o Personal Access Token no GitLab (ver passo a passo)"
    Write-Output "  [3] Cancelar"
    Write-Output ""

    $choice = Read-Host "Escolha uma opcao (1, 2 ou 3)"
    if ($choice -eq "2") {
        Write-Output ""
        Show-TokenGuide
        Write-Output ""
    } elseif ($choice -ne "1") {
        Write-Output "Configuracao cancelada pelo usuario."
        exit 1
    }

    $defaultUrl = if ($CurrentConfig.base_url -and $CurrentConfig.base_url -ne "https://gitlab.exemplo.gov.br") { $CurrentConfig.base_url } else { "" }
    if ($defaultUrl) {
        $inputUrl = Read-Host "Informe a URL base do GitLab [$defaultUrl]"
        if (-not $inputUrl) { $inputUrl = $defaultUrl }
    } else {
        $inputUrl = Read-Host "Informe a URL base do GitLab (ex.: https://gitlab.sua-organizacao.gov.br)"
    }

    if (-not $inputUrl) {
        Write-Error "A URL base do GitLab e obrigatoria."
        exit 1
    }

    $inputToken = Read-Host "Informe o seu Personal Access Token do GitLab"
    if (-not $inputToken) {
        Write-Error "O Personal Access Token e obrigatorio."
        exit 1
    }

    $inputProj = Read-Host "Projeto padrao opcional (ex.: grupo/nome-projeto ou Enter para pular)"

    Save-GitLabConfig -Url $inputUrl -Pat $inputToken -DefProj $inputProj
    Write-Output ""
    Write-Output "Configuracao salva com sucesso em './config/gitlab.yaml' (arquivo ignorado pelo Git)."
    return (Read-GitLabConfig)
}

function Ensure-Configured {
    $cfg = Read-GitLabConfig
    if (-not $cfg.configured) {
        if ($NonInteractive) {
            $out = [ordered]@{
                status        = "ONBOARDING_REQUIRED"
                configured    = $false
                config_exists = $cfg.config_exists
                has_base_url  = $cfg.has_base_url
                has_token     = $cfg.has_token
                message       = "O arquivo './config/gitlab.yaml' nao existe ou nao possui Personal Access Token configurado. Solicite o token ao usuario ou ofereca o passo a passo ('token-guide')."
            }
            $out | ConvertTo-Json -Depth 5
            exit 2
        } else {
            $cfg = Invoke-InteractiveOnboarding -CurrentConfig $cfg
        }
    }
    return $cfg
}

function Invoke-GitLabApiGet {
    param(
        [Parameter(Mandatory = $true)] $Config,
        [Parameter(Mandatory = $true)] [string]$Endpoint
    )

    $uri = "$($Config.base_url)/api/v4/$($Endpoint.TrimStart('/'))"
    $headers = @{
        "PRIVATE-TOKEN" = $Config.token
        "Accept"        = "application/json"
    }

    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $response = Invoke-RestMethod -Method Get -Uri $uri -Headers $headers -TimeoutSec 30
        return $response
    } catch {
        $statusCode = $null
        if ($_.Exception.Response) {
            $statusCode = [int]$_.Exception.Response.StatusCode
        }
        $errObj = [ordered]@{
            status      = "ERROR"
            http_status = $statusCode
            endpoint    = $Endpoint
            message     = "Falha na consulta somente leitura ao GitLab: $($_.Exception.Message)"
            hint        = if ($statusCode -eq 401) { "Token invalido, expirado ou revogado. Atualize './config/gitlab.yaml'." } elseif ($statusCode -eq 403) { "Permissao insuficiente. Verifique se o token possui os escopos 'read_api' e 'read_repository'." } else { "Verifique a conectividade de rede/VPN e a URL base configurada em './config/gitlab.yaml'." }
        }
        $errObj | ConvertTo-Json -Depth 5
        exit 1
    }
}

switch ($Action) {
    "token-guide" {
        Show-TokenGuide
    }

    "check-config" {
        $cfg = Read-GitLabConfig
        $out = [ordered]@{
            status          = if ($cfg.configured) { "READY" } else { "ONBOARDING_REQUIRED" }
            configured      = $cfg.configured
            config_exists   = $cfg.config_exists
            has_base_url  = $cfg.has_base_url
            has_token       = $cfg.has_token
            base_url        = $cfg.base_url
            default_project = $cfg.default_project
            config_path     = "./config/gitlab.yaml"
        }
        $out | ConvertTo-Json -Depth 5
    }

    "setup" {
        $cfg = Read-GitLabConfig
        if ($BaseUrl -and $Token) {
            $proj = if ($DefaultProject) { $DefaultProject } else { $cfg.default_project }
            Save-GitLabConfig -Url $BaseUrl -Pat $Token -DefProj $proj
            $masked = if ($Token.Length -gt 8) { $Token.Substring(0, 4) + "****" + $Token.Substring($Token.Length - 4) } else { "****" }
            $out = [ordered]@{
                status          = "CONFIG_SAVED"
                config_path     = "./config/gitlab.yaml"
                base_url        = $BaseUrl.Trim().TrimEnd('/')
                default_project = $proj
                token_masked    = $masked
                git_ignored     = $true
            }
            $out | ConvertTo-Json -Depth 5
        } else {
            Invoke-InteractiveOnboarding -CurrentConfig $cfg | Out-Null
        }
    }

    "test" {
        $cfg = Ensure-Configured
        $user = Invoke-GitLabApiGet -Config $cfg -Endpoint "/user"
        $out = [ordered]@{
            status             = "CONNECTED"
            access_mode        = "read_only"
            gitlab_base_url    = $cfg.base_url
            authenticated_user = [ordered]@{
                id       = $user.id
                username = $user.username
                name     = $user.name
                state    = $user.state
                web_url  = $user.web_url
            }
        }
        $out | ConvertTo-Json -Depth 5
    }

    "commit" {
        $cfg = Ensure-Configured
        $targetProject = if ($Project) { $Project } else { $cfg.default_project }
        if (-not $targetProject -or -not $Sha) {
            Write-Error "Para consultar um commit, informe -Project '<grupo/projeto>' e -Sha '<hash>'."
            exit 1
        }
        $encodedProj = [System.Uri]::EscapeDataString($targetProject)
        $commitMeta = Invoke-GitLabApiGet -Config $cfg -Endpoint "/projects/$encodedProj/repository/commits/$Sha"
        $commitDiff = Invoke-GitLabApiGet -Config $cfg -Endpoint "/projects/$encodedProj/repository/commits/$Sha/diff"

        $out = [ordered]@{
            status   = "OK"
            project  = $targetProject
            commit   = [ordered]@{
                id            = $commitMeta.id
                short_id      = $commitMeta.short_id
                parent_ids    = $commitMeta.parent_ids
                title         = $commitMeta.title
                message       = $commitMeta.message
                author_name   = $commitMeta.author_name
                authored_date = $commitMeta.authored_date
                web_url       = $commitMeta.web_url
                stats         = $commitMeta.stats
            }
            diffs    = $commitDiff
        }
        $out | ConvertTo-Json -Depth 10
    }

    "search-task" {
        $cfg = Ensure-Configured
        $targetProject = if ($Project) { $Project } else { $cfg.default_project }
        if (-not $targetProject -or -not $TaskId) {
            Write-Error "Para buscar evidencias de uma tarefa, informe -Project '<grupo/projeto>' e -TaskId '<numero_da_issue>'."
            exit 1
        }
        $encodedProj = [System.Uri]::EscapeDataString($targetProject)
        $cleanId = $TaskId.TrimStart('#')
        $branches = Invoke-GitLabApiGet -Config $cfg -Endpoint "/projects/$encodedProj/repository/branches?search=$cleanId&per_page=50"
        $commits = Invoke-GitLabApiGet -Config $cfg -Endpoint "/projects/$encodedProj/repository/commits?all=true&per_page=100"
        $matchedCommits = @($commits | Where-Object { $_.title -match $cleanId -or $_.message -match $cleanId })

        $out = [ordered]@{
            status           = "OK"
            task_id          = $cleanId
            project          = $targetProject
            matched_branches = @($branches | Select-Object name, merged, web_url)
            matched_commits  = @($matchedCommits | Select-Object id, short_id, title, author_name, authored_date, web_url)
        }
        $out | ConvertTo-Json -Depth 6
    }

    "my-commits" {
        $cfg = Ensure-Configured
        $user = Invoke-GitLabApiGet -Config $cfg -Endpoint "/user"
        $targetProject = if ($Project) { $Project } else { $cfg.default_project }
        if (-not $targetProject) {
            Write-Error "Informe -Project '<grupo/projeto>' ou configure 'default_project' em './config/gitlab.yaml'."
            exit 1
        }
        $encodedProj = [System.Uri]::EscapeDataString($targetProject)
        $sinceQuery = if ($Since) { "&since=$([System.Uri]::EscapeDataString($Since))" } else { "" }
        $allCommits = Invoke-GitLabApiGet -Config $cfg -Endpoint "/projects/$encodedProj/repository/commits?all=true$sinceQuery&per_page=100"
        $commits = @($allCommits | Where-Object {
            $_.author_name -eq $user.username -or
            $_.author_name -eq $user.name -or
            $_.author_email -eq $user.email
        })

        $out = [ordered]@{
            status  = "OK"
            user    = $user.username
            project = $targetProject
            since   = $Since
            commits = @($commits | Select-Object id, short_id, title, authored_date, web_url)
        }
        $out | ConvertTo-Json -Depth 6
    }
}
