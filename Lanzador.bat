@echo off
:: Lanza el script de PowerShell ocultando la ventana negra de fondo
start "" powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File "%~dp0Scripts\Panel-GUI.ps1"
exit
