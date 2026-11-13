<#
.SYNOPSIS
    Script de configuracao e bootstrap idempotente do ambiente PowerShell 7.
.DESCRIPTION
    1. Instala/verifica modulos necessarios (PSFzf).
    2. Aponta os profiles do PowerShell ($PROFILE) para este repositorio.
    3. Cria links simbolicos (ou sincroniza) os arquivos de Starship e Windows Terminal.
    4. Inicializa o arquivo local de segredos (secrets.ps1) caso nao exista.
#>

[CmdletBinding()]
param(
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
$RepoRoot = $PSScriptRoot
Write-Host "=== Iniciando Setup do PowerShell ($RepoRoot) ===" -ForegroundColor Cyan

# 0. Instalar utilitarios de linha de comando no PATH local (~/.local/bin)
$localBin = "$HOME\.local\bin"
if (-not (Test-Path $localBin)) {
    New-Item -ItemType Directory -Path $localBin -Force | Out-Null
}
$reloadCmdSource = Join-Path $RepoRoot "scripts\reload.cmd"
if (Test-Path $reloadCmdSource) {
    Copy-Item $reloadCmdSource (Join-Path $localBin "reload.cmd") -Force
    Write-Host "Comando executavel 'reload.cmd' instalado em $localBin" -ForegroundColor Green
}

# 1. Modulos PowerShell (PSFzf e CompletionPredictor)
Write-Host "`n[1/6] Verificando modulo PSFzf..." -ForegroundColor Yellow
if (-not (Get-Module -ListAvailable PSFzf)) {
    Write-Host "Instalando PSFzf da PSGallery..." -ForegroundColor Green
    Install-Module -Name PSFzf -Scope CurrentUser -Force -SkipPublisherCheck
} else {
    Write-Host "PSFzf ja instalado." -ForegroundColor Green
}

Write-Host "`n[2/6] Verificando modulo CompletionPredictor..." -ForegroundColor Yellow
if (-not (Get-Module -ListAvailable CompletionPredictor)) {
    Write-Host "Instalando CompletionPredictor da PSGallery..." -ForegroundColor Green
    Install-Module -Name CompletionPredictor -Scope CurrentUser -Force -SkipPublisherCheck
} else {
    Write-Host "CompletionPredictor ja instalado." -ForegroundColor Green
}

# 3. Configurar secrets.ps1
Write-Host "`n[3/6] Verificando secrets.ps1..." -ForegroundColor Yellow
$secretsFile = Join-Path $RepoRoot "secrets.ps1"
$exampleFile = Join-Path $RepoRoot "secrets.example.ps1"
if (-not (Test-Path $secretsFile) -and (Test-Path $exampleFile)) {
    Copy-Item $exampleFile $secretsFile
    Write-Host "Arquivo secrets.ps1 criado a partir do exemplo (edite com suas chaves se desejar)." -ForegroundColor Green
} else {
    Write-Host "Arquivo secrets.ps1 ja existe ou configurado." -ForegroundColor Green
}

# 4. Configurar Starship
Write-Host "`n[4/6] Sincronizando Starship..." -ForegroundColor Yellow
$configDir = "$HOME\.config"
if (-not (Test-Path $configDir)) {
    New-Item -ItemType Directory -Path $configDir -Force | Out-Null
}
$starshipTarget = Join-Path $configDir "starship.toml"
$starshipSource = Join-Path $RepoRoot "starship\starship.toml"

if (Test-Path $starshipSource) {
    Copy-Item $starshipSource $starshipTarget -Force
    Write-Host "starship.toml sincronizado em: $starshipTarget" -ForegroundColor Green
}

# 5. Sincronizar Windows Terminal & Noctty
Write-Host "`n[5/7] Sincronizando Windows Terminal settings.json..." -ForegroundColor Yellow
$wtDir = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
$wtTarget = Join-Path $wtDir "settings.json"
$wtSource = Join-Path $RepoRoot "wterminal\settings.json"

if (Test-Path $wtDir) {
    if (Test-Path $wtTarget) {
        Copy-Item $wtTarget "$wtTarget.bak" -Force
    }
    Copy-Item $wtSource $wtTarget -Force
    Write-Host "Windows Terminal settings.json atualizado com sucesso." -ForegroundColor Green
} else {
    Write-Warning "Diretorio do Windows Terminal nao encontrado. Pulando etapa de settings.json."
}

# 6. Sincronizar Noctty Terminal & Scripts do PSMux
Write-Host "`n[6/7] Sincronizando Noctty e scripts de notificacao..." -ForegroundColor Yellow
$nocttyDir = "$env:LOCALAPPDATA\noctty"
$nocttySource = Join-Path $RepoRoot "noctty\config.ghostty"
if (Test-Path $nocttySource) {
    if (-not (Test-Path $nocttyDir)) {
        New-Item -ItemType Directory -Path $nocttyDir -Force | Out-Null
    }
    Copy-Item $nocttySource (Join-Path $nocttyDir "config.ghostty") -Force
    Write-Host "Noctty config.ghostty sincronizado com sucesso." -ForegroundColor Green
}

$psmuxScriptsDir = "$HOME\.psmux\scripts"
$notifierSource = Join-Path $RepoRoot "scripts\Send-WindowsNotification.ps1"
if (Test-Path $notifierSource) {
    if (-not (Test-Path $psmuxScriptsDir)) {
        New-Item -ItemType Directory -Path $psmuxScriptsDir -Force | Out-Null
    }
    Copy-Item $notifierSource (Join-Path $psmuxScriptsDir "Send-WindowsNotification.ps1") -Force
    Write-Host "Script Send-WindowsNotification.ps1 sincronizado em ~/.psmux/scripts" -ForegroundColor Green
}

$psmuxConf = "$HOME\.psmux.conf"
if (Test-Path $psmuxConf) {
    $confContent = Get-Content $psmuxConf -Raw
    if ($confContent -match 'set -g prediction-dimming on') {
        $confContent = $confContent -replace 'set -g prediction-dimming on', 'set -g prediction-dimming off'
        Set-Content -Path $psmuxConf -Value $confContent -Encoding utf8 -Force
        Write-Host "Configuracao prediction-dimming desativada em $psmuxConf (preserva cores customizadas de PSReadLine e FZF)" -ForegroundColor Green
    }
}
if (Get-Command psmux -ErrorAction SilentlyContinue) {
    try {
        & psmux set-option -g prediction-dimming off 2>$null
    } catch {}
}

# 7. Configurar $PROFILE
Write-Host "`n[7/7] Apontando `$PROFILE para o repositorio..." -ForegroundColor Yellow
$profileDirs = @(
    "$HOME\Documents\PowerShell",
    "$HOME\.config\powershell"
)
foreach ($dir in $profileDirs) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}

$repoProfilePath = Join-Path $RepoRoot "Microsoft.PowerShell_profile.ps1"
$loaderContent = @"
# Loader automatico gerado pelo setup de powershellconfig
if ([Console]::IsInputRedirected -or [Console]::IsOutputRedirected) {
    # Em sessoes nao-interativas (como subshells do agy-cli), evita pendurar TUI/Starship/PSReadLine
    return
}
. "$repoProfilePath"
"@

# Atualiza os arquivos padroes de profile do PowerShell 7
$profileTargets = @(
    "$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1",
    "$HOME\Documents\PowerShell\profile.ps1",
    "$HOME\.config\powershell\user_profile.ps1"
)

foreach ($target in $profileTargets) {
    Set-Content -Path $target -Value $loaderContent -Encoding utf8 -Force
    Write-Host "Profile atualizado: $target" -ForegroundColor Green
}

# Limpa caches antigos
$cacheDir = Join-Path $RepoRoot ".cache"
if (Test-Path $cacheDir) {
    Remove-Item "$cacheDir\*.ps1" -Force -ErrorAction SilentlyContinue
}

Write-Host "`n=== Setup concluido com sucesso! ===" -ForegroundColor Cyan
Write-Host "Abra uma nova aba do terminal ou rode '. `$PROFILE' para testar." -ForegroundColor Gray
