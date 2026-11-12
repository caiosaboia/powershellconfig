<#
.SYNOPSIS
    Dispara notificacao nativa Toast no Windows (via WinRT) com protecao anti-flood.
.DESCRIPTION
    Utilizado por hooks do psmux (alert-bell, alert-activity) e por scripts do terminal.
    Executa de forma segura sem dependencias de modulos externos.
#>
param(
    [string]$Title = "PSMux Alerta",
    [string]$Message = "Seu harness ou comando finalizou!",
    [int]$ThrottleSeconds = 2
)

# Protecao anti-flood para evitar acumulo de notificacoes em testes intensivos
$lockFile = Join-Path $env:TEMP "psmux_toast_throttle.tmp"
$now = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()

if (Test-Path $lockFile) {
    try {
        $last = [int64](Get-Content $lockFile -Raw -ErrorAction SilentlyContinue)
        if (($now - $last) -lt $ThrottleSeconds) {
            exit 0
        }
    } catch {}
}
try { Set-Content -Path $lockFile -Value $now -Force -ErrorAction SilentlyContinue } catch {}

# Sanitizacao basica de XML
$cleanTitle = [System.Security.SecurityElement]::Escape($Title)
$cleanMessage = [System.Security.SecurityElement]::Escape($Message)

$template = @"
<toast>
    <visual>
        <binding template="ToastGeneric">
            <text>$cleanTitle</text>
            <text>$cleanMessage</text>
        </binding>
    </visual>
    <audio src="ms-winsoundevent:Notification.Default" />
</toast>
"@

try {
    [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
    [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime] | Out-Null

    $xml = New-Object Windows.Data.Xml.Dom.XmlDocument
    $xml.LoadXml($template)
    $toast = New-Object Windows.UI.Notifications.ToastNotification $xml
    $appId = '{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe'
    [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($appId).Show($toast)
} catch {}
