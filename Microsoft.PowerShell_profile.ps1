# ==============================================================================
# PowerShell Profile - Unified & High Performance
# Repo: C:\Users\cocad\projetos\powershellconfig
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. Guard contra execucao duplicada e sessoes nao-interativas
# ------------------------------------------------------------------------------
if ($global:UserProfileLoaded) { return }

# Evita travar subshells headless de ferramentas de automacao e agentes (ex: Antigravity CLI, VS Code tasks, CI)
$isNonInteractive = $false
try {
    if ([Console]::IsOutputRedirected -or [Console]::IsInputRedirected) {
        $isNonInteractive = $true
    }
} catch {
    $isNonInteractive = $true
}

if ($isNonInteractive -or $env:TERM_PROGRAM -eq 'vscode' -and $env:VSCODE_NONINTERACTIVE) {
    # Em sessoes nao-interativas, garante apenas ferramentas de runtime no PATH sem carregar modulos TUI/readline
    $miniforge = "C:\Users\cocad\miniforge3"
    if (Test-Path $miniforge) {
        $paths = @("$miniforge\Library\bin", "$miniforge\Scripts")
        foreach ($p in $paths) {
            if ((Test-Path $p) -and ($env:PATH -split ';' -notcontains $p)) {
                $env:PATH = "$p;$env:PATH"
            }
        }
    }
    return
}

$global:UserProfileLoaded = $true

$Script:RepoRoot = "C:\Users\cocad\projetos\powershellconfig"
$Script:CacheDir = Join-Path $Script:RepoRoot ".cache"
if (-not (Test-Path $Script:CacheDir)) {
    New-Item -ItemType Directory -Path $Script:CacheDir -Force | Out-Null
}

# ------------------------------------------------------------------------------
# 2. Inicializacao em Cache (Starship, Zoxide, Agy-Brain)
# ------------------------------------------------------------------------------
function Invoke-CachedInit {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$CommandName,
        [Parameter(Mandatory = $true)][scriptblock]$Generator
    )

    $cmd = Get-Command $CommandName -ErrorAction SilentlyContinue
    if (-not $cmd) { return }

    $cacheFile = Join-Path $Script:CacheDir "$Name.ps1"
    $needsRefresh = $true

    if (Test-Path $cacheFile) {
        $cacheItem = Get-Item $cacheFile
        $binItem = Get-Item $cmd.Source
        if ($cacheItem.LastWriteTime -ge $binItem.LastWriteTime -and $cacheItem.Length -gt 0) {
            $needsRefresh = $false
        }
    }

    if ($needsRefresh) {
        try {
            $scriptContent = & $Generator
            if ($scriptContent) {
                Set-Content -Path $cacheFile -Value $scriptContent -Encoding utf8 -Force
            }
        } catch {
            # Fallback seguro caso falhe gerar o cache
        }
    }

    if (Test-Path $cacheFile) {
        . $cacheFile
    } else {
        & $Generator | Invoke-Expression
    }
}

# Starship Prompt
Invoke-CachedInit -Name "starship" -CommandName "starship" -Generator {
    (& starship init powershell --print-full-init | Out-String)
}

# Zoxide
Invoke-CachedInit -Name "zoxide" -CommandName "zoxide" -Generator {
    (& zoxide init powershell | Out-String)
}

# Aliases amigaveis do Zoxide
if (Get-Command __zoxide_z -ErrorAction SilentlyContinue) {
    Set-Alias cd __zoxide_z -Option AllScope -Scope Global -Force
}
if (Get-Command __zoxide_zi -ErrorAction SilentlyContinue) {
    Set-Alias cdi __zoxide_zi -Option AllScope -Scope Global -Force
    Set-Alias cdz __zoxide_zi -Option AllScope -Scope Global -Force
}

# Antigravity CLI Brain Navigator
Invoke-CachedInit -Name "brain" -CommandName "brain" -Generator {
    (& brain init powershell | Out-String)
}

# CLI Completions em Cache (gh, uv, docker, winget)
Invoke-CachedInit -Name "completion-gh" -CommandName "gh" -Generator {
    (& gh completion -s powershell | Out-String)
}

Invoke-CachedInit -Name "completion-uv" -CommandName "uv" -Generator {
    (& uv generate-shell-completion powershell | Out-String)
}

Invoke-CachedInit -Name "completion-docker" -CommandName "docker" -Generator {
    (& docker completion powershell | Out-String)
}

# Winget Native Argument Completer
if (Get-Command winget -ErrorAction SilentlyContinue) {
    Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
        param($wordToComplete, $commandAst, $cursorPosition)
        [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
        $Local:word = $wordToComplete.Replace('"', '""')
        $Local:ast = $commandAst.ToString().Replace('"', '""')
        winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
    }
}

# ------------------------------------------------------------------------------
# 3. PSReadLine, CompletionPredictor & Cores Catppuccin Mocha
# ------------------------------------------------------------------------------
if (Get-Module -ListAvailable CompletionPredictor) {
    Import-Module CompletionPredictor -ErrorAction SilentlyContinue
}

if (Get-Module -ListAvailable PSReadLine) {
    Import-Module PSReadLine -ErrorAction SilentlyContinue

    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
    Set-PSReadLineKeyHandler -Chord 'F2' -Function SwitchPredictionView
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

    Set-PSReadLineOption -BellStyle None

    if (-not [Console]::IsOutputRedirected) {
        try {
            Set-PSReadLineOption -PredictionSource HistoryAndPlugin -ErrorAction Stop
            Set-PSReadLineOption -PredictionViewStyle InlineView -ErrorAction Stop
        } catch {}
    }

    # Paleta Catppuccin Mocha
    Set-PSReadLineOption -Colors @{
        Command            = '#89b4fa' # Blue
        Parameter          = '#f5c2e7' # Pink
        Operator           = '#89dceb' # Sky
        Variable           = '#cba6f7' # Mauve
        String             = '#a6e3a1' # Green
        Number             = '#fab387' # Peach
        Type               = '#94e2d5' # Teal
        Comment            = '#6c7086' # Overlay0
        Keyword            = '#b4befe' # Lavender
        Error              = '#f38ba8' # Red
        Default            = '#cdd6f4' # Text
        InlinePrediction   = '#585b70' # Surface2
    }
}

# ------------------------------------------------------------------------------
# 4. FZF & PSFzf (Integrado com fd, bat e eza)
# ------------------------------------------------------------------------------
# Cores Catppuccin Mocha para FZF
$env:FZF_DEFAULT_OPTS = @"
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc
--color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8
--color=selected-bg:#45475a
--height=50% --layout=reverse --border --inline-info
"@

if (Get-Command fd -ErrorAction SilentlyContinue) {
    $env:FZF_DEFAULT_COMMAND = 'fd --type f --hidden --follow --exclude .git'
    $env:FZF_CTRL_T_COMMAND = $env:FZF_DEFAULT_COMMAND
    $env:FZF_ALT_C_COMMAND = 'fd --type d --hidden --follow --exclude .git'
}

if (Get-Module -ListAvailable PSFzf) {
    Import-Module PSFzf -ErrorAction SilentlyContinue
    if (Get-Command Set-PsFzfOption -ErrorAction SilentlyContinue) {
        Set-PsFzfOption -PSReadlineChordReverseHistory 'Ctrl+r'
        Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t'
        Set-PsFzfOption -PSReadlineChordSetLocation 'Alt+c'

        if (Get-Command bat -ErrorAction SilentlyContinue) {
            $env:FZF_CTRL_T_OPTS = "--preview 'bat --color=always --style=numbers --line-range=:200 {}'"
        }
        if (Get-Command eza -ErrorAction SilentlyContinue) {
            $env:FZF_ALT_C_OPTS = "--preview 'eza --tree --level=2 --icons --color=always {}'"
        }
    }
}

# ------------------------------------------------------------------------------
# 5. Lazy-Loading do Conda / Miniforge3 (~900ms economizados no boot)
# ------------------------------------------------------------------------------
$MiniforgeRoot = "C:\Users\cocad\miniforge3"
if (Test-Path $MiniforgeRoot) {
    # Garante ferramentas como uv/python acessiveis no PATH sem engasgar o startup
    $PathsToAdd = @(
        "$MiniforgeRoot\Library\bin",
        "$MiniforgeRoot\Scripts"
    )
    foreach ($p in $PathsToAdd) {
        if ((Test-Path $p) -and ($env:PATH -split ';' -notcontains $p)) {
            $env:PATH = "$p;$env:PATH"
        }
    }

    # Hook carregado apenas quando invocar conda ou mamba
    function global:Initialize-CondaHook {
        if (-not $global:CondaHookInitialized) {
            $condaExe = "$MiniforgeRoot\Scripts\conda.exe"
            if (Test-Path $condaExe) {
                Write-Host "Inicializando ambiente Conda/Miniforge3..." -ForegroundColor DarkGray
                (& $condaExe "shell.powershell" "hook") | Out-String | ?{$_} | Invoke-Expression
            }
            $global:CondaHookInitialized = $true
        }
    }

    function global:conda {
        Initialize-CondaHook
        conda.exe @args
    }

    function global:mamba {
        Initialize-CondaHook
        mamba.exe @args
    }
}

# ------------------------------------------------------------------------------
# 6. Chocolatey
# ------------------------------------------------------------------------------
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path $ChocolateyProfile) {
    Import-Module "$ChocolateyProfile" -ErrorAction SilentlyContinue
}

# ------------------------------------------------------------------------------
# 7. Funcoes Utilitarias e Aliases Modernos
# ------------------------------------------------------------------------------
function touch { New-Item -ItemType File -Force @args }

# Listagem avancada com eza
if (Get-Command eza -ErrorAction SilentlyContinue) {
    function global:ezinha { eza --icons --group-directories-first @args }
    function global:ll { eza -la --icons --git --group-directories-first @args }
    function global:la { eza -a --icons --group-directories-first @args }
    function global:lt { eza --tree --level=2 --icons --group-directories-first @args }
    Set-Alias ls ezinha -Option AllScope -Scope Global -Force
} else {
    function global:ll { Get-ChildItem @args | Format-Table }
    function global:la { Get-ChildItem @args | Format-Wide }
}
function global:lb { Get-ChildItem @args | Format-List }

# Leitura com bat sem travar scripts
if (Get-Command bat -ErrorAction SilentlyContinue) {
    function global:batinha { bat --paging=never @args }
    function global:batp { bat @args }
    Set-Alias cat batinha -Option AllScope -Scope Global -Force
}

# Navegacao rapida
function .. { Set-Location .. }
function ... { Set-Location ..\.. }
function mkcd {
    param([string]$Path)
    New-Item -ItemType Directory -Path $Path -Force | Out-Null
    Set-Location $Path
}

# Gerenciador de Virtualenv Inteligente (suporta uv e navegacao hierarquica)
function global:venva {
    param([switch]$Create)

    if ($Create) {
        if (Get-Command uv -ErrorAction SilentlyContinue) {
            Write-Host "Criando virtualenv com uv..." -ForegroundColor Cyan
            uv venv
        } else {
            Write-Host "Criando virtualenv com python -m venv..." -ForegroundColor Cyan
            python -m venv .venv
        }
    }

    # Procura .venv ou venv recursivamente ate 3 niveis acima
    $curr = (Get-Location).Path
    $found = $null
    for ($i = 0; $i -lt 3; $i++) {
        $candidates = @(
            Join-Path $curr ".venv\Scripts\Activate.ps1",
            Join-Path $curr "venv\Scripts\Activate.ps1"
        )
        foreach ($c in $candidates) {
            if (Test-Path $c) {
                $found = $c
                break
            }
        }
        if ($found) { break }
        $parent = Split-Path $curr -Parent
        if (-not $parent -or $parent -eq $curr) { break }
        $curr = $parent
    }

    if ($found) {
        Write-Host "Ativando ambiente virtual: $found" -ForegroundColor Green
        & $found
    } else {
        Write-Host "Nenhum ambiente virtual (.venv ou venv) encontrado! Use 'venva -Create' para criar um." -ForegroundColor Yellow
    }
}

# Recarregar perfil
function global:reload {
    Write-Host "Limpando caches e recarregando perfil do PowerShell..." -ForegroundColor Cyan
    Remove-Item -Path "$Script:CacheDir\*.ps1" -Force -ErrorAction SilentlyContinue
    $global:UserProfileLoaded = $false
    . $PROFILE
    Write-Host "Perfil recarregado com sucesso!" -ForegroundColor Green
}

# Atalho para abrir a configuracao no Neovim
function global:ep {
    Set-Location $Script:RepoRoot
    if (Get-Command nvim -ErrorAction SilentlyContinue) {
        nvim .
    }
}

# Utilitario which estilo Unix
function global:which {
    param([string]$Name)
    Get-Command $Name -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
}

# Aliases extras
Set-Alias n nvim -ErrorAction SilentlyContinue
Set-Alias lg lazygit -ErrorAction SilentlyContinue

# ------------------------------------------------------------------------------
# 8. Psmux (Tmux) Session Manager Versionado
# ------------------------------------------------------------------------------
$PsmuxScript = Join-Path $Script:RepoRoot "scripts\Start-PsmuxSession.ps1"
if (Test-Path $PsmuxScript) {
    . $PsmuxScript
    function global:tm {
        param([string]$Session)
        if ($Session) {
            Start-Psmux -Name $Session
        } else {
            Select-TmuxSession
        }
    }
    Set-Alias tml Select-TmuxSession -Option AllScope -Scope Global -Force

    # Atalho de teclado interativo (Ctrl+S / Alt+S) para abrir sessoes do tmux via FZF
    if (Get-Module -ListAvailable PSReadLine) {
        Set-PSReadLineKeyHandler -Key 'Ctrl+s' -ScriptBlock {
            [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
            Select-TmuxSession
            [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
        }
        Set-PSReadLineKeyHandler -Chord 'Alt+s' -ScriptBlock {
            [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
            Select-TmuxSession
            [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
        }
    }
}

# ------------------------------------------------------------------------------
# 9. Carregamento Seguro de Segredos Locais (secrets.ps1)
# ------------------------------------------------------------------------------
$LocalSecrets = Join-Path $Script:RepoRoot "secrets.ps1"
if (Test-Path $LocalSecrets) {
    . $LocalSecrets
}
