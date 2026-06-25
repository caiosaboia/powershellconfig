# powershellconfig

- Atualiza o PWSH
- Instala o Chocolatey
- Instala o Starship
- Instala o CARGO/Rust
- Instala o miniforge3

> [!WARNING]
> De preferencia rode tudo em modo admin


Rode o Script para baixar e instalar o PowerShell7:

```powershell
cd .config\powershell && .\install_powershell.ps1


```

Rode isso para trazer o repositorio

```powershell
git clone https://github.com/caiosaboia/powershellconfig.git "$HOME\.config\powershell"; if (!(Test-Path $PROFILE)) { New-Item -Type File -Path $PROFILE -Force }; Add-Content -Path $PROFILE -Value "`n. `"$HOME\.config\powershell\user_profile.ps1`""
```



Rode isso para Baixar o Chocolatey
> [!TIP]
> Rodar em modo admin

```powershell

#Rode isso
Set-ExecutionPolicy Bypass -Scope Process

#Depois isso
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

```

Rodar o programa dos Tweaks

```powershell
irm https://christitus.com/win | iex
```


configurar o SSH


baixar o miniforge3 (Python)


Baixar os drivers de NPU da AMD e o Suporte de IA da AMD ![AMD NPU IA](https://ryzenai.docs.amd.com/en/latest/inst.html#install-npu-drivers) 
Segue os passo a passo.

Instalar o fzf, fd command, cat, eza, zeoxide (cargo)

instalar o neovim

instalar o FLM [FastFlowLLM](https://github.com/FastFlowLM/FastFlowLM) 
