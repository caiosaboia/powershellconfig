<#
.SYNOPSIS
    Emite notificacao de desktop para o Noctty Terminal usando OSC 777 (com suporte a passthrough no PSMux).
.DESCRIPTION
    Detecta se o shell esta rodando dentro de uma sessao PSMux/Tmux ou diretamente no terminal hospedeiro.
    Envelopa a sequencia OSC 777 no formato DCS Passthrough (\ePtmux;\e...\e\) para atravessar o PSMux
    e alcancar o Noctty diretamente.
#>
param(
    [string]$Title = "Noctty",
    [string]$Message = "Comando finalizado!"
)

# Remove quebras de linha e sanitiza caracteres delimitadores
$cleanTitle = ($Title -replace '[;\r\n]', ' ').Trim()
$cleanMessage = ($Message -replace '[;\r\n]', ' ').Trim()

$osc777 = "`e]777;notify;$cleanTitle;$cleanMessage`e\"

if ($env:TMUX -or $env:PSMUX) {
    # Envelope DCS Passthrough do Tmux: \ePtmux;\e <sequencia com \e duplicado> \e\
    $escapedOsc = $osc777 -replace "`e", "`e`e"
    [Console]::Write("`ePtmux;$escapedOsc`e\")
} else {
    [Console]::Write($osc777)
}
