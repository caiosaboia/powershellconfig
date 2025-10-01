# Import the Chocolatey Profile that contains the necessary code to enable
# tab-completions to function for `choco`.
# Be aware that if you are missing these lines from your profile, tab completion
# for `choco` will not function.
# See https://ch0.co/tab-completion for details.

Invoke-Expression (&starship init powershell)

Import-Module Get-ChildItemColor
Import-Module PSReadLine
Import-Module Terminal-Icons

#AUTOCOMPLETE
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineOption -BellStyle None
Set-PSReadLineOption -PredictionSource HistoryAndPlugin
Set-PSReadLineOption -PredictionViewStyle InlineView   
Set-PSReadLineOption -Colors @{
  Command     = 'Blue'
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
$env:GEMINI_API_KEY = ""


function ll()
{ Get-ChildItem | Format-Table
}
function la()
{ Get-ChildItem | Format-Wide
}
function lb()
{ Get-ChildItem | Format-List
}

Set-Alias n nvim
Set-Alias vim nvim

