# powershellconfig

## Video tutorial e roteiro
[Video](https://www.youtube.com/watch?v=jERL0wbhtsc&t=544s) 
[roteiro](https://devclass-ricardo.notion.site/Como-ter-AUTOCOMPLETE-no-Powershell-como-no-ZSH-com-o-OH-MY-ZSH-d2bb110dd42a4fd3935d256453f0441f) 

## Instalando o neovim:
  > [!WARNING]
  > Baixe primeiro TODAS as dependencias;
  > [ASTRO](https://docs.astronvim.com/) 

1. Primeiro Passo
```powershell
Move-Item $env:LOCALAPPDATA\nvim $env:LOCALAPPDATA\nvim.bak

```

2. Segundo Passo
```powershell
Move-Item $env:LOCALAPPDATA\nvim-data $env:LOCALAPPDATA\nvim-data.bak
```

3. Terceiro Passo
```powershell
git clone --depth 1 https://github.com/caiosaboia/powershellconfig.git
Move-Item C:~\powershellconfig\nvim\ $env:LOCALAPPDATA\nvim
Remove-Item $env:LOCALAPPDATA\nvim\.git -Recurse -Force
nvim
```
