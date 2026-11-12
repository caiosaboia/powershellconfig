@echo off
rem Wrapper executavel para recarregar perfis e caches do PowerShell a partir de qualquer shell (CMD, agy !, bash)
pwsh.exe -NoLogo -NoProfile -Command "$cacheDir = 'C:\Users\cocad\projetos\powershellconfig\.cache'; if (Test-Path $cacheDir) { Remove-Item (Join-Path $cacheDir '*.ps1') -Force -ErrorAction SilentlyContinue }; Write-Host 'Caches do PowerShell limpos com sucesso!' -ForegroundColor Green"
exit /b 0
