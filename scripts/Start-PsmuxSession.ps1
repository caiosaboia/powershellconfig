<#
.SYNOPSIS
    Gerenciador automatico de sessoes do psmux / tmux para PowerShell no Windows.
.DESCRIPTION
    Verifica se a sessao informada (padrao: 'main') existe. Se existir, conecta (attach).
    Se nao existir, cria a nova sessao em segundo plano e conecta automaticamente.
    Possui protecao contra loops recursivos dentro do proprio tmux e comandos para
    salvar e restaurar o estado das sessoes.
#>

param(
    [string]$SessionName = "main",
    [switch]$Force
)

$PsmuxConfigDir = "$HOME\.config\psmux"
$SaveFile = "$PsmuxConfigDir\saved_sessions.json"

if (-not (Test-Path $PsmuxConfigDir)) {
    New-Item -ItemType Directory -Path $PsmuxConfigDir -Force | Out-Null
}

function Test-InTmux {
    return [bool]($env:TMUX -or $env:PSMUX)
}

function Get-TmuxSessionsList {
    $raw = @(tmux list-sessions 2>$null)
    $list = @()
    foreach ($line in $raw) {
        if ($line -match "^([^:]+):") {
            $list += $matches[1]
        }
    }
    return $list
}

function Save-PsmuxState {
    [CmdletBinding()]
    param()
    $sessions = Get-TmuxSessionsList
    $state = [PSCustomObject]@{
        SavedAt   = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        Sessions  = $sessions
    }
    $state | ConvertTo-Json -Depth 3 | Set-Content -Path $SaveFile -Encoding utf8
    Write-Host "[psmux] Sessoes salvas com sucesso em: $SaveFile" -ForegroundColor Green
}

function Restore-PsmuxState {
    [CmdletBinding()]
    param()
    if (-not (Test-Path $SaveFile)) {
        Write-Warning "[psmux] Nenhum estado salvo encontrado em $SaveFile"
        return
    }
    $data = Get-Content -Path $SaveFile -Raw | ConvertFrom-Json
    $existing = Get-TmuxSessionsList
    foreach ($s in $data.Sessions) {
        if ($s -notin $existing) {
            Write-Host "[psmux] Restaurando sessao '$s'..." -ForegroundColor Cyan
            tmux new-session -s "$s" -d
        }
    }
    Write-Host "[psmux] Restauracao concluida!" -ForegroundColor Green
}

function Start-Psmux {
    param([string]$Name = "main")

    if (Test-InTmux) {
        return
    }

    $existingSessions = Get-TmuxSessionsList
    if ($Name -notin $existingSessions) {
        tmux new-session -s "$Name" -d
    }

    Save-PsmuxState
    tmux attach -t "$Name"
}

if ($MyInvocation.InvocationName -ne '.' -and $MyInvocation.InvocationName -ne '&') {
    Start-Psmux -Name $SessionName
}
