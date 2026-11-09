# powershellconfig

Configuração moderna, unificada e de alta performance para **PowerShell 7**, **Starship Prompt** e **Windows Terminal**, utilizando o tema **Catppuccin Mocha**.

---

## Destaques da Configuração

- ⚡ **Inicialização Ultra-rápida (<20ms de script execution):** 
  - *Lazy-loading* inteligente para **Conda/Miniforge3** (economiza ~900ms a cada abertura de aba).
  - Cache dinâmico em disco (`.cache/`) para scripts de inicialização do `starship`, `zoxide`, `agy-brain` e CLI completions (`gh`, `uv`, `docker`).
- 🤖 **Predição & Autocomplete Dinâmico em Tempo Real:**
  - Módulo oficial **`CompletionPredictor`** integrado ao `PSReadLine` (`InlineView` e `ListView` com tecla `F2`).
  - Completions em cache nativo para **GitHub CLI (`gh`)**, **Astral uv (`uv`)**, **Docker** e **Windows Package Manager (`winget`)**.
- 🎨 **Visual Consistente (Catppuccin Mocha):**
  - Prompt com [Starship](https://starship.rs) completo (Git status, runtime versions, diretório inteligente).
  - Syntax highlighting do `PSReadLine` calibrado com as cores Mocha.
  - Windows Terminal com tema, fontes Nerd Font e atalhos de janelas estilo Vim.
- 🔍 **Busca Fuzzy Interativa (`PSFzf` & Tmux):**
  - `Ctrl + R`: Busca fuzzy reversa de histórico de comandos.
  - `Ctrl + T`: Localização fuzzy de arquivos via `fd` com preview syntax-highlighted via `bat`.
  - `Ctrl + S` (ou `Alt + S`): Menu interativo FZF de sessões ativas do **Tmux** com preview de janelas.
  - `Alt + C`: Navegação fuzzy entre pastas com visualização em árvore via `eza`.
- ⌨️ **Comandos & Aliases Modernos:**
  - `ls`, `la`: Listagem colorida com ícones via `eza`.
  - `ll`: Listagem detalhada com status do Git e diretórios no topo (`eza -la --git`).
  - `lt`: Visualização em árvore (`eza --tree --level=2`).
  - `cat`: Leitura colorida sem quebra de pipes (`bat --paging=never`).
  - `batp`: Leitura interativa completa com paginação.
  - `cd`, `cdi`, `cdz`: Navegação preditiva inteligente com `zoxide`.
  - `lg`: Interface Git via `lazygit`.
  - `n`: Editor `neovim`.
  - `venva`: Ativação automática de `.venv` ou `venv` (ou `venva -Create` com `uv venv`).
  - `tm`: Gerenciador de sessões `psmux`/`tmux` (sem argumentos abre seletor interativo com **FZF** e preview de janelas; `tm <nome>` conecta ou cria direto).
  - `tml`: Atalho direto para listar e trocar de sessão via FZF (`Select-TmuxSession`).
  - `reload`: Limpa caches e recarrega o perfil na hora.
  - `ep`: Atalho para abrir a pasta de configurações no Neovim.
- 🔒 **Segurança e Segredos:**
  - Suporte a `secrets.ps1` (ignorado pelo `.gitignore`) para salvar chaves de API (`GEMINI_API_KEY`, etc.) sem risco de commitar nem sobrescrever variáveis do sistema.

---

## Estrutura do Repositório

```text
powershellconfig/
├── .cache/                            # Caches gerados em tempo de execução (gitignored)
├── scripts/
│   └── Start-PsmuxSession.ps1         # Gerenciador de sessões tmux/psmux
├── starship/
│   └── starship.toml                  # Configuração do Starship (Catppuccin Mocha)
├── wterminal/
│   └── settings.json                  # Configuração do Windows Terminal (Atalhos Vim, Perfis)
├── .gitignore                         # Proteção contra commit de segredos e temporários
├── Microsoft.PowerShell_profile.ps1   # Perfil unificado principal do PowerShell
├── secrets.example.ps1                # Exemplo de arquivo de segredos
├── setup.ps1                          # Script idempotente de instalação e sincronização
└── README.md
```

---

## Como Instalar / Sincronizar

### Em uma Máquina Nova ou Após Atualizações

Abra o **PowerShell 7** e execute:

```powershell
# 1. Clone o repositório se ainda não o tiver
git clone https://github.com/caiosaboia/powershellconfig.git "$HOME\projetos\powershellconfig"
cd "$HOME\projetos\powershellconfig"

# 2. Execute o setup automatizado
.\setup.ps1
```

O `setup.ps1` irá automaticamente:
1. Instalar os módulos `PSFzf` e `CompletionPredictor` (caso ainda não estejam presentes).
2. Criar seu `secrets.ps1` local a partir de `secrets.example.ps1`.
3. Sincronizar `starship.toml` em `~/.config/starship.toml`.
4. Sincronizar `settings.json` do Windows Terminal (com backup automático do atual).
5. Configurar seus arquivos de `$PROFILE` para carregar este repositório como fonte única da verdade.

---

## Atalhos do Windows Terminal

- `Alt + Shift + Plus (+)`: Dividir painel verticalmente.
- `Alt + Shift + Minus (-)`: Dividir painel horizontalmente.
- `Alt + Shift + D`: Duplicar painel atual.
- `Alt + H / J / K / L`: Mover foco entre painéis (estilo Vim).
- `Ctrl + C / Ctrl + V`: Copiar e colar direto.
