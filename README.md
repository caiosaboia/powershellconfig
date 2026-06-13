# powershellconfig

- Atualiza o PWSH
- Instala o Chocolatey
- Instala o Starship
- Instala o CARGO/NPM (tree-sitter-cli)
- Instala o Conda

```shell
git clone https://github.com/caiosaboia/powershellconfig.git "$HOME\.config\powershell"; if (!(Test-Path $PROFILE)) { New-Item -Type File -Path $PROFILE -Force }; Add-Content -Path $PROFILE -Value "`n. `"$HOME\.config\powershell\meu_perfil.ps1`""
