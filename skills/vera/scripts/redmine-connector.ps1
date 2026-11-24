<#
.SYNOPSIS
    Conector Somente Leitura do Redmine para a Skill VERA (v0.4.0).
.DESCRIPTION
    Gerencia a configuracao da Chave de Acesso API (API Key) em ./config/redmine.yaml
    (arquivo local nao versionado), exibe o passo a passo de obtencao da chave
    quando o usuario nao souber como obte-la, testa a conectividade e realiza
    consultas estritamente Read-Only (GET) na API REST do Redmine.
    100% portavel: utiliza apenas caminhos relativos ao diretorio da skill.
#>

param(
    [Parameter(Position = 0)]
    [ValidateSet("check-config", "token-guide", "setup", "test", "issue", "demand", "my-issues", "time-entries")]
    [string]$Action = "check-config",

    [string]$BaseUrl = "",
    [string]$ApiKey = "",
    [string]$Token = "",
    [string]$DefaultProject = "",
    [string]$IssueId = "",
    [string]$Assignee = "",
    [string]$From = "",
    [string]$To = "",
    [switch]$NonInteractive
)

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Permitir passar tanto -ApiKey quanto -Token por conveniencia
if (-not $ApiKey -and $Token) {
    $ApiKey = $Token
}

# Caminhos 100% relativos a raiz da skill (independente de maquina)
$SkillRoot = Split-Path -Parent $PSScriptRoot
$ConfigDir = Join-Path $SkillRoot "config"
$ConfigFile = Join-Path $ConfigDir "redmine.yaml"

function Show-TokenGuide {
    Write-Output "==============================================================================="
    Write-Output " PASSO A PASSO RESUMIDO: COMO OBTER SUA CHAVE DE ACESSO API NO REDMINE"
    Write-Output "==============================================================================="
    Write-Output "1. Acesse o Redmine da sua organizacao no navegador e faca login."
    Write-Output "2. No canto superior direito da tela, clique em 'Minha conta' (My account)."
    Write-Output "3. Na coluna lateral direita da pagina, localize a secao"
    Write-Output "   'Chave de acesso API' (API access key)."
    Write-Output "4. Clique no link 'Mostrar' (Show) para exibir sua chave."
    Write-Output "   (Observacao: caso ainda nao tenha uma chave gerada, clique em 'Redefinir' / 'Reset')."
    Write-Output "5. COPIE A CHAVE ALFANUMERICA EXIBIDA (ex.: 40 caracteres hexadecimais)."
    Write-Output "==============================================================================="
}

function Read-RedmineConfig {
    $result = [ordered]@{
        config_exists   = (Test-Path $ConfigFile)
        configured      = $false
        has_base_url    = $false
        has_api_key     = $false
        base_url        = ""
        default_project = ""
        api_key         = ""
    }

    if (-not $result.config_exists) {
        return $result
    }

    $lines = Get-Content -Path $ConfigFile -Encoding UTF8
    foreach ($line in $lines) {
        if ($line -match '^\s*base_url\s*:\s*(.+)$') {
            $val = ($Matches[1] -split '#')[0].Trim() -replace '^["'']|["'']$', ''
            $val = $val.Trim().TrimEnd('/')
            if ($val -and $val -ne "https://redmine.exemplo.gov.br") {
                $result.base_url = $val
                $result.has_base_url = $true
            } elseif ($val) {
                $result.base_url = $val
            }
        }
        if ($line -match '^\s*api_key\s*:\s*(.+)$') {
            $val = ($Matches[1] -split '#')[0].Trim() -replace '^["'']|["'']$', ''
            if ($val -and $val -ne "SUA_API_KEY_AQUI") {
                $result.api_key = $val
                $result.has_api_key = $true
            }
        }
        if ($line -match '^\s*default_project\s*:\s*(.+)$') {
            $val = ($Matches[1] -split '#')[0].Trim() -replace '^["'']|["'']$', ''
            $result.default_project = $val
        }
    }

    if ($result.has_base_url -and $result.has_api_key) {
        $result.configured = $true
    }

    return $result
}

function Save-RedmineConfig {
    param(
        [string]$Url,
        [string]$Key,
        [string]$DefProj = ""
    )

    $cleanUrl = $Url.Trim().TrimEnd('/')
    $cleanKey = $Key.Trim()
    $cleanProj = $DefProj.Trim()

    if (-not (Test-Path $ConfigDir)) {
        New-Item -ItemType Directory -Path $ConfigDir -Force | Out-Null
    }

    $yamlContent = @"
# =============================================================================
# VERA - Configuracao Local do Modulo Redmine (NAO VERSIONADO)
# =============================================================================
# ATENCAO: Este arquivo contem sua Chave de Acesso API pessoal do Redmine e
# esta protegido no .gitignore para nunca ser enviado ao GitHub.
# =============================================================================

redmine:
  base_url: "$cleanUrl"

  auth:
    api_key: "$cleanKey"
    verify_ssl: true
    timeout_seconds: 30

  access_mode: "read_only"
  default_project: "$cleanProj"

  defaults:
    include_subtasks: true
    include_journals: true
    include_attachments: true
    include_time_entries: true
    pagination_limit: 100
"@

    Set-Content -Path $ConfigFile -Value $yamlContent -Encoding UTF8
}

function Invoke-InteractiveOnboarding {
    param($CurrentConfig)

    Write-Output ""
    Write-Output "[VERA - Configuracao Inicial do Redmine]"
    Write-Output "O arquivo 'config/redmine.yaml' ainda nao existe ou nao possui uma Chave de Acesso API (API Key) cadastrada."
    Write-Output ""
    Write-Output "Como voce deseja prosseguir?"
    Write-Output "  [1] Ja possuo minha Chave de Acesso API do Redmine (informar agora)"
    Write-Output "  [2] Nao sei como obter a Chave de Acesso API no Redmine (ver passo a passo)"
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

    $defaultUrl = if ($CurrentConfig.base_url -and $CurrentConfig.base_url -ne "https://redmine.exemplo.gov.br") { $CurrentConfig.base_url } else { "" }
    if ($defaultUrl) {
        $inputUrl = Read-Host "Informe a URL base do Redmine [$defaultUrl]"
        if (-not $inputUrl) { $inputUrl = $defaultUrl }
    } else {
        $inputUrl = Read-Host "Informe a URL base do Redmine (ex.: https://gestaoprojetosti.economia.go.gov.br)"
    }

    if (-not $inputUrl) {
        Write-Error "A URL base do Redmine e obrigatoria."
        exit 1
    }

    $inputKey = Read-Host "Informe a sua Chave de Acesso API (API Key) do Redmine"
    if (-not $inputKey) {
        Write-Error "A Chave de Acesso API do Redmine e obrigatoria."
        exit 1
    }

    $inputProj = Read-Host "Identificador do projeto padrao opcional (ou Enter para pular)"

    Save-RedmineConfig -Url $inputUrl -Key $inputKey -DefProj $inputProj
    Write-Output ""
    Write-Output "Configuracao salva com sucesso em './config/redmine.yaml' (arquivo ignorado pelo Git)."
    return (Read-RedmineConfig)
}

function Ensure-Configured {
    $cfg = Read-RedmineConfig
    if (-not $cfg.configured) {
        if ($NonInteractive) {
            $out = [ordered]@{
                status        = "ONBOARDING_REQUIRED"
                configured    = $false
                config_exists = $cfg.config_exists
                has_base_url  = $cfg.has_base_url
                has_api_key   = $cfg.has_api_key
                message       = "O arquivo './config/redmine.yaml' nao existe ou nao possui Chave de Acesso API configurada. Solicite a chave ao usuario ou ofereca o passo a passo ('token-guide')."
            }
            $out | ConvertTo-Json -Depth 5
            exit 2
        } else {
            $cfg = Invoke-InteractiveOnboarding -CurrentConfig $cfg
        }
    }
    return $cfg
}

function Invoke-RedmineApiGet {
    param(
        [Parameter(Mandatory = $true)] $Config,
        [Parameter(Mandatory = $true)] [string]$Endpoint
    )

    $uri = "$($Config.base_url)/$($Endpoint.TrimStart('/'))"
    $headers = @{
        "X-Redmine-API-Key" = $Config.api_key
        "Accept"            = "application/json"
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
            message     = "Falha na consulta somente leitura ao Redmine: $($_.Exception.Message)"
            hint        = if ($statusCode -eq 401) { "Chave de Acesso API invalida ou expirada. Verifique em 'Minha conta' -> 'Chave de acesso API' e atualize './config/redmine.yaml'." } elseif ($statusCode -eq 403) { "Permissao insuficiente para acessar este recurso/projeto no Redmine." } elseif ($statusCode -eq 404) { "Tarefa ou endpoint nao encontrado no Redmine." } else { "Verifique a conectividade de rede/VPN e a URL base configurada em './config/redmine.yaml'." }
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
        $cfg = Read-RedmineConfig
        $out = [ordered]@{
            status          = if ($cfg.configured) { "READY" } else { "ONBOARDING_REQUIRED" }
            configured      = $cfg.configured
            config_exists   = $cfg.config_exists
            has_base_url    = $cfg.has_base_url
            has_api_key     = $cfg.has_api_key
            base_url        = $cfg.base_url
            default_project = $cfg.default_project
            config_path     = "./config/redmine.yaml"
        }
        $out | ConvertTo-Json -Depth 5
    }

    "setup" {
        $cfg = Read-RedmineConfig
        if ($BaseUrl -and $ApiKey) {
            $proj = if ($DefaultProject) { $DefaultProject } else { $cfg.default_project }
            Save-RedmineConfig -Url $BaseUrl -Key $ApiKey -DefProj $proj
            $masked = if ($ApiKey.Length -gt 8) { $ApiKey.Substring(0, 4) + "****" + $ApiKey.Substring($ApiKey.Length - 4) } else { "****" }
            $out = [ordered]@{
                status          = "CONFIG_SAVED"
                config_path     = "./config/redmine.yaml"
                base_url        = $BaseUrl.Trim().TrimEnd('/')
                default_project = $proj
                api_key_masked  = $masked
                git_ignored     = $true
            }
            $out | ConvertTo-Json -Depth 5
        } else {
            Invoke-InteractiveOnboarding -CurrentConfig $cfg | Out-Null
        }
    }

    "test" {
        $cfg = Ensure-Configured
        $resp = Invoke-RedmineApiGet -Config $cfg -Endpoint "/users/current.json"
        $user = $resp.user
        $out = [ordered]@{
            status             = "CONNECTED"
            access_mode        = "read_only"
            redmine_base_url   = $cfg.base_url
            authenticated_user = [ordered]@{
                id          = $user.id
                login       = $user.login
                firstname   = $user.firstname
                lastname    = $user.lastname
                full_name   = "$($user.firstname) $($user.lastname)".Trim()
                mail        = $user.mail
                last_login  = $user.last_login_on
            }
        }
        $out | ConvertTo-Json -Depth 5
    }

    "issue" {
        $cfg = Ensure-Configured
        if (-not $IssueId) {
            Write-Error "Para consultar uma tarefa, informe -IssueId '<numero_da_issue>'."
            exit 1
        }
        $cleanId = $IssueId.TrimStart('#')
        $issueResp = Invoke-RedmineApiGet -Config $cfg -Endpoint "/issues/$cleanId.json?include=children,attachments,relations,journals"
        $timeResp = Invoke-RedmineApiGet -Config $cfg -Endpoint "/time_entries.json?issue_id=$cleanId&limit=100"

        $issue = $issueResp.issue
        $spentHours = if ($null -ne $issue.spent_hours) { [double]$issue.spent_hours } else { 0.0 }
        $statusName = $issue.status.name
        $isClosedOrValidation = ($statusName -match '(?i)(Fechad|Resolvid|Valida|Conclu)') -or ($issue.done_ratio -eq 100)

        $billingNotes = @()
        if ($issue.journals) {
            foreach ($j in $issue.journals) {
                if ($j.notes -and ($j.notes.Trim().Length -gt 0)) {
                    $billingNotes += [ordered]@{
                        id         = $j.id
                        user       = $j.user.name
                        created_on = $j.created_on
                        notes      = $j.notes
                    }
                }
            }
        }

        $auditState = "EM_ANDAMENTO"
        if ($isClosedOrValidation) {
            if ($spentHours -gt 0) {
                $auditState = "100_PORCENTO_COBRADO_OU_REGULAR"
            } else {
                $auditState = "PENDENTE_DE_HORAS"
            }
        }

        $out = [ordered]@{
            status      = "OK"
            issue_url   = "$($cfg.base_url)/issues/$cleanId"
            audit_state = $auditState
            issue       = [ordered]@{
                id                  = $issue.id
                project             = $issue.project.name
                tracker             = $issue.tracker.name
                status              = $statusName
                priority            = $issue.priority.name
                author              = $issue.author.name
                assigned_to         = if ($issue.assigned_to) { $issue.assigned_to.name } else { $null }
                parent_id           = if ($issue.parent) { $issue.parent.id } else { $null }
                subject             = $issue.subject
                description         = $issue.description
                start_date          = $issue.start_date
                due_date            = $issue.due_date
                done_ratio          = $issue.done_ratio
                spent_hours         = $spentHours
                total_spent_hours   = $issue.total_spent_hours
                custom_fields       = $issue.custom_fields
                children            = $issue.children
                attachments         = @($issue.attachments | Select-Object id, filename, filesize, content_type, description, content_url, created_on)
                journals_with_notes = $billingNotes
                time_entries        = @($timeResp.time_entries | Select-Object id, user, activity, hours, comments, spent_on)
            }
        }
        $out | ConvertTo-Json -Depth 10
    }

    "demand" {
        $cfg = Ensure-Configured
        if (-not $IssueId) {
            Write-Error "Para auditar uma demanda e suas subtarefas, informe -IssueId '<numero_da_demanda>'."
            exit 1
        }
        $cleanId = $IssueId.TrimStart('#')
        $parentResp = Invoke-RedmineApiGet -Config $cfg -Endpoint "/issues/$cleanId.json?include=children,attachments,relations,journals"
        $parentIssue = $parentResp.issue

        $subtasksDetailed = @()
        $unassignedOrOtherSubtasks = @()

        if ($parentIssue.children) {
            foreach ($childRef in $parentIssue.children) {
                $cId = $childRef.id
                $cResp = Invoke-RedmineApiGet -Config $cfg -Endpoint "/issues/$cId.json?include=attachments,relations,journals"
                $cTime = Invoke-RedmineApiGet -Config $cfg -Endpoint "/time_entries.json?issue_id=$cId&limit=100"
                $cIssue = $cResp.issue

                $cAssignee = if ($cIssue.assigned_to) { $cIssue.assigned_to.name } else { $null }
                $cAssigneeId = if ($cIssue.assigned_to) { $cIssue.assigned_to.id } else { $null }

                if ($Assignee -and (-not $cAssignee -or ($cAssignee -notmatch "(?i)$Assignee" -and "$cAssigneeId" -ne $Assignee))) {
                    $unassignedOrOtherSubtasks += [ordered]@{
                        id          = $cIssue.id
                        subject     = $cIssue.subject
                        status      = $cIssue.status.name
                        assigned_to = $cAssignee
                        spent_hours = if ($null -ne $cIssue.spent_hours) { [double]$cIssue.spent_hours } else { 0.0 }
                    }
                    continue
                }

                $cNotes = @()
                $commitLinks = @()
                if ($cIssue.journals) {
                    foreach ($j in $cIssue.journals) {
                        if ($j.notes -and ($j.notes.Trim().Length -gt 0)) {
                            $cNotes += [ordered]@{
                                id         = $j.id
                                user       = $j.user.name
                                created_on = $j.created_on
                                notes      = $j.notes
                            }
                            $matchesUrls = [regex]::Matches($j.notes, 'https?://[^\s\)\]]+/-/commit/[0-9a-fA-F]{7,40}')
                            foreach ($m in $matchesUrls) {
                                if ($commitLinks -notcontains $m.Value) {
                                    $commitLinks += $m.Value
                                }
                            }
                        }
                    }
                }

                $sistemaModulo = ""
                $catalogoCast = ""
                $unidMedidaCast = ""
                $complexAltissima = ""
                if ($cIssue.custom_fields) {
                    foreach ($cf in $cIssue.custom_fields) {
                        if ($cf.id -eq 63 -or $cf.name -match 'Sistema') { $sistemaModulo = $cf.value }
                        elseif ($cf.id -eq 102 -or $cf.name -match '13/2024') { $catalogoCast = $cf.value }
                        elseif ($cf.id -eq 29 -or $cf.name -match 'Unid\.\s*Medida') { $unidMedidaCast = $cf.value }
                        elseif ($cf.id -eq 104 -or $cf.name -match 'Complexidade') { $complexAltissima = $cf.value }
                    }
                }

                $cSpent = if ($null -ne $cIssue.spent_hours) { [double]$cIssue.spent_hours } else { 0.0 }
                $cStatus = $cIssue.status.name
                $cClosed = ($cStatus -match '(?i)(Fechad|Resolvid|Valida|Conclu)') -or ($cIssue.done_ratio -eq 100)
                $cAuditState = if ($cClosed) { if ($cSpent -gt 0) { "100_PORCENTO_COBRADO_OU_REGULAR" } else { "PENDENTE_DE_HORAS" } } else { "EM_ANDAMENTO" }

                $subtasksDetailed += [ordered]@{
                    id                  = $cIssue.id
                    issue_url           = "$($cfg.base_url)/issues/$($cIssue.id)"
                    audit_state         = $cAuditState
                    subject             = $cIssue.subject
                    tracker             = $cIssue.tracker.name
                    status              = $cStatus
                    assigned_to         = $cAssignee
                    assigned_to_id      = $cAssigneeId
                    start_date          = $cIssue.start_date
                    done_ratio          = $cIssue.done_ratio
                    spent_hours         = $cSpent
                    sistema_modulo      = $sistemaModulo
                    catalogo_cast       = $catalogoCast
                    unid_medida_cast    = $unidMedidaCast
                    complex_altissima   = $complexAltissima
                    commit_urls_in_note = $commitLinks
                    journals_with_notes = $cNotes
                    time_entries        = @($cTime.time_entries | Select-Object id, @{Name="user";Expression={$_.user.name}}, @{Name="activity";Expression={$_.activity.name}}, hours, comments, spent_on)
                }
            }
        }

        $out = [ordered]@{
            status      = "OK"
            demand_url  = "$($cfg.base_url)/issues/$cleanId"
            demand      = [ordered]@{
                id                = $parentIssue.id
                parent_id         = if ($parentIssue.parent) { $parentIssue.parent.id } else { $null }
                project           = $parentIssue.project.name
                tracker           = $parentIssue.tracker.name
                status            = $parentIssue.status.name
                subject           = $parentIssue.subject
                author            = $parentIssue.author.name
                assigned_to       = if ($parentIssue.assigned_to) { $parentIssue.assigned_to.name } else { $null }
                spent_hours       = $parentIssue.spent_hours
                total_spent_hours = $parentIssue.total_spent_hours
                total_children    = if ($parentIssue.children) { @($parentIssue.children).Count } else { 0 }
            }
            subtasks_audited       = $subtasksDetailed
            other_or_unassigned    = $unassignedOrOtherSubtasks
        }
        $out | ConvertTo-Json -Depth 10
    }

    "my-issues" {
        $cfg = Ensure-Configured
        $resp = Invoke-RedmineApiGet -Config $cfg -Endpoint "/issues.json?assigned_to_id=me&limit=50"
        $out = [ordered]@{
            status      = "OK"
            total_count = $resp.total_count
            issues      = @($resp.issues | Select-Object id, @{Name="project";Expression={$_.project.name}}, @{Name="tracker";Expression={$_.tracker.name}}, @{Name="status";Expression={$_.status.name}}, subject, spent_hours, updated_on)
        }
        $out | ConvertTo-Json -Depth 6
    }

    "time-entries" {
        $cfg = Ensure-Configured
        $query = "limit=100"
        if ($IssueId) {
            $cleanId = $IssueId.TrimStart('#')
            $query += "&issue_id=$cleanId"
        } else {
            $query += "&user_id=me"
        }
        if ($From) { $query += "&from=$From" }
        if ($To) { $query += "&to=$To" }

        $resp = Invoke-RedmineApiGet -Config $cfg -Endpoint "/time_entries.json?$query"
        $totalHours = 0.0
        foreach ($te in $resp.time_entries) {
            $totalHours += [double]$te.hours
        }
        $out = [ordered]@{
            status       = "OK"
            total_count  = $resp.total_count
            total_hours  = [math]::Round($totalHours, 2)
            time_entries = @($resp.time_entries | Select-Object id, @{Name="issue_id";Expression={$_.issue.id}}, @{Name="user";Expression={$_.user.name}}, @{Name="activity";Expression={$_.activity.name}}, hours, comments, spent_on)
        }
        $out | ConvertTo-Json -Depth 6
    }
}
