$MaximumHistoryCount = 20000

Import-Module posh-git 
Import-Module PSReadLine
Import-Module Get-ChildItemColor
Import-Module Terminal-Icons
Import-Module DockerCompletion

# Set-PoshPrompt - Theme spaceship
oh-my-posh init pwsh --config 'C:\Users\cocad\AppData\Local\Programs\oh-my-posh\themes\illusi0n.omp.json' | Invoke-Expression

# Uses tab for autocompletion
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

# History definitions
$HistoryFilePath = Join-Path ([Environment]::GetFolderPath('UserProfile')) .ps_history
Register-EngineEvent PowerShell.Exiting -Action { Get-History | Export-Clixml $HistoryFilePath } | out-null
if (Test-path $HistoryFilePath) { Import-Clixml $HistoryFilePath | Add-History }

Set-PSReadLineOption -HistorySearchCursorMovesToEnd
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward

Set-PSReadLineOption -ShowToolTips
Set-PSReadLineOption -PredictionSource History

# Aliases
Set-Alias which Get-Command
Set-Alias open Invoke-Item
Set-Alias touch New-Item
Set-Alias rm remove-item
Set-Alias mkdir Makedir

function ll() { Get-ChildItem | Format-Table }
function la() { Get-ChildItem | Format-Wide }
function lb() { Get-ChildItem | Format-List }
function Makedir{
  New-Item -ItemType directory $args
}



Set-Alias ls la
Set-Alias l lb

# Aliases Functions
# function cdd() { Set-Location "D:\Downloads" }
# function cdp() { Set-Location "D:\Desenvolvimento\Projetos" }

# function opd() { open "D:\Downloads" }
# function opp() { open "D:\Desenvolvimento\Projetos" }

# function edp() { code $PROFILE }
# function edh() { code "$HOME\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt" }
# function eds() { code "$HOME\AppData\Local\oh-my-posh\illusi0n.omp.json" }

# # Compute file hashes - useful for checking successful downloads
# function md5    { Get-FileHash -Algorithm MD5 $args }
# function sha1   { Get-FileHash -Algorithm SHA1 $args }
# function sha256 { Get-FileHash -Algorithm SHA256 $args }

# function tail { Get-Content $args -Tail 30 -Wait }

function take {
  New-Item -ItemType directory $args
  Set-Location "$args"
}



# Import the Chocolatey Profile that contains the necessary code to enable
# tab-completions to function for `choco`.
# Be aware that if you are missing these lines from your profile, tab completion
# for `choco` will not function.
# See https://ch0.co/tab-completion for details.
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

