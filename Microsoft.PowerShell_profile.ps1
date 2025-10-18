# Import the Chocolatey Profile that contains the necessary code to enable
# tab-completions to function for `choco`.
# Be aware that if you are missing these lines from your profile, tab completion
# for `choco` will not function.
# See https://ch0.co/tab-completion for details.

Invoke-Expression (&starship init powershell)
Invoke-Expression (& { (zoxide init powershell | Out-String) })

Import-Module PSReadLine

#AUTOCOMPLETE
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineOption -BellStyle None
Set-PSReadLineOption -PredictionSource HistoryAndPlugin
Set-PSReadLineOption -PredictionViewStyle InlineView   
Set-PSReadLineOption -Colors @{
  Command     = 'Cyan'
  # Parameter = 'Green'
  # Operator  = 'Yellow'
  Variable  = 'Magenta'
  # String    = 'DarkYellow'
  # Number    = 'White'
  # Type      = 'DarkCyan'
  # Comment   = 'DarkGreen'
  # Keyword   = 'Blue'
  Error       = 'Red'
  Default     = 'Yellow'
}

$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile))
{
  Import-Module "$ChocolateyProfile"
}

#ENVS
$env:GEMINI_API_KEY=

#FUNCTIONS
function LL()
{ Get-ChildItem | Format-Table
}
function LA()
{ Get-ChildItem | Format-Wide
}
function LB()
{ Get-ChildItem | Format-List
}
function touch {New-Item -ItemType File -Force @args}

function ezinha { eza  --icons @args }

function batinha { bat @args }

function zoxidinha { z @args }

#ALIASES
Set-Alias ls ezinha
Set-Alias cat batinha
Set-Alias cdz zoxidinha
Set-Alias n nvim
Set-Alias rstudio #caminho absoluto do .exe
Set-Alias sumatrapdf #caminho absoluto do .exe
Set-Alias qdrant #caminho absoluto do .exe


