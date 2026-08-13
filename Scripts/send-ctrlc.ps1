param(
    [Parameter(Mandatory=$true)]
    [string]$ProcessName
)

# Definimos las funciones de la API de Windows necesarias para
# adjuntarnos a la consola de otro proceso y enviarle un Ctrl+C real
# (CTRL_C_EVENT), exactamente igual que si el usuario lo pulsara
# a mano dentro de esa ventana.
$signature = @'
[DllImport("kernel32.dll", SetLastError = true)]
public static extern bool AttachConsole(uint dwProcessId);

[DllImport("kernel32.dll", SetLastError = true)]
public static extern bool FreeConsole();

[DllImport("kernel32.dll")]
public static extern bool SetConsoleCtrlHandler(IntPtr HandlerRoutine, bool Add);

[DllImport("kernel32.dll", SetLastError = true)]
public static extern bool GenerateConsoleCtrlEvent(uint dwCtrlEvent, uint dwProcessGroupId);
'@

Add-Type -MemberDefinition $signature -Name Win32CtrlC -Namespace Win32Functions -ErrorAction SilentlyContinue

$proc = Get-Process -Name $ProcessName -ErrorAction SilentlyContinue
if (-not $proc) {
    Write-Output "NOTFOUND"
    exit 1
}

# Nos soltamos de nuestra propia consola (la del panel de control)
[Win32Functions.Win32CtrlC]::FreeConsole() | Out-Null

# Nos adjuntamos a la consola del proceso objetivo
$attached = [Win32Functions.Win32CtrlC]::AttachConsole([uint32]$proc.Id)
if (-not $attached) {
    Write-Output "ATTACHFAIL"
    exit 1
}

# Ignoramos el evento en nuestro propio proceso de PowerShell,
# para no cerrarnos a nosotros mismos junto con el objetivo
[Win32Functions.Win32CtrlC]::SetConsoleCtrlHandler([IntPtr]::Zero, $true) | Out-Null

# Enviamos CTRL_C_EVENT (0) a todos los procesos de esa consola
[Win32Functions.Win32CtrlC]::GenerateConsoleCtrlEvent(0, 0) | Out-Null

Start-Sleep -Milliseconds 300

[Win32Functions.Win32CtrlC]::FreeConsole() | Out-Null

Write-Output "OK"
