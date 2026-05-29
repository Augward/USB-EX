@echo off
TITLE USB-EX Execution Engine
COLOR 0B

:: 1. Auto-Elevate to Administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [!] Requesting Administrative Privileges...
    powershell -Command "Start-Process '%~f0' -ArgumentList '%~1' -Verb RunAs"
    exit /b
)

:: 2. Execution Payload
echo =======================================================
echo USB-EX Script Loader Initializing...
echo Running with Master Administrator Privileges...
echo Target: %~1
echo =======================================================

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& {try { & '%~1' } catch { Write-Host 'Error: ' $_.Exception.Message -ForegroundColor Red } }"