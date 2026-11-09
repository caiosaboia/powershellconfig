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

# 5. Sincronizar Windows Terminal
Write-Host "`n[5/6] Sincronizando Windows Terminal settings.json..." -ForegroundColor Yellow
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

# 6. Configurar $PROFILE
Write-Host "`n[6/6] Apontando `$PROFILE para o repositorio..." -ForegroundColor Yellow
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
