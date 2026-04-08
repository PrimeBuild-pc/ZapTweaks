@echo off
chcp 65001 >nul
title Toolkit di Manutenzione di Sistema

:: Richiesta automatica permessi di Amministratore
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Richiesta permessi di amministratore in corso...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: Imposta la directory di lavoro dove risiede il .bat
cd /d "%~dp0"

:menu
cls
echo ===============================================================
echo                   TOOLKIT DI MANUTENZIONE
echo ===============================================================
echo  1. Genera Report Batteria
echo  2. Pulizia Rapida (Cache Windows Update e Temp)
echo  3. Reset di Rete
echo  4. Ripristina Anteprime Immagini USB
echo  5. Riparazione Sistema (SFC e DISM)
echo  6. Cambia Nome Amministratore
echo  7. Gestione Permessi Esecuzione Script
echo  T. Esegui TUTTE le operazioni (1-6)
echo ---------------------------------------------------------------
echo  P. Esci e apri PowerShell con permessi temporanei
echo  E. Esci
echo ===============================================================
echo.
echo Digita i numeri delle operazioni da eseguire consecutivamente
echo Esempio: "145" esegue Report, Anteprime e Riparazione.
echo.
set /p "choices=Scelta: "

:: Gestione uscita semplice
if /i "%choices%"=="E" goto :fine

:: Uscita con finestra PowerShell permessi temporanei
if /i "%choices%"=="P" (
    echo.
    echo [*] Apertura PowerShell con permessi temporanei...
    powershell -Command "Start-Process powershell.exe -ArgumentList '-NoProfile -ExecutionPolicy Bypass -NoExit -Command \"$Host.UI.RawUI.WindowTitle=''PowerShell - Permessi Temporanei Attivi''; Write-Host ''============================================'' -ForegroundColor Green; Write-Host ''  PERMESSI TEMPORANEI ATTIVI'' -ForegroundColor Green; Write-Host ''============================================'' -ForegroundColor Green; Write-Host ''; Write-Host ''Esegui i tuoi script con: .\NomeScript.ps1'' -ForegroundColor Cyan; Write-Host ''Chiudi questa finestra quando hai finito.'' -ForegroundColor Yellow; Write-Host ''\"' -Verb RunAs"
    goto :fine
)

if /i "%choices%"=="T" set choices=123456

echo %choices% | findstr /C:"1" >nul
if %errorlevel%==0 (
    echo.
    echo [*] Esecuzione: Report Batteria...
    powershell -NoProfile -ExecutionPolicy Bypass -File "BatteryReport.ps1"
)

echo %choices% | findstr /C:"2" >nul
if %errorlevel%==0 (
    echo.
    echo [*] Esecuzione: Pulizia Rapida...
    powershell -NoProfile -ExecutionPolicy Bypass -File "FastClean.ps1"
)

echo %choices% | findstr /C:"3" >nul
if %errorlevel%==0 (
    echo.
    echo [*] Esecuzione: Reset di Rete...
    powershell -NoProfile -ExecutionPolicy Bypass -File "ResetNetwork.ps1"
)

echo %choices% | findstr /C:"4" >nul
if %errorlevel%==0 (
    echo.
    echo [*] Esecuzione: Ripristina Anteprime...
    powershell -NoProfile -ExecutionPolicy Bypass -File "RipristinaAntemprime.ps1"
)

echo %choices% | findstr /C:"5" >nul
if %errorlevel%==0 (
    echo.
    echo [*] Esecuzione: SFC e DISM...
    powershell -NoProfile -ExecutionPolicy Bypass -File "SFC___DISM.ps1"
)

echo %choices% | findstr /C:"6" >nul
if %errorlevel%==0 (
    echo.
    echo [*] Esecuzione: Cambia Nome...
    powershell -NoProfile -ExecutionPolicy Bypass -File "Change_Name.ps1"
)

echo %choices% | findstr /C:"7" >nul
if %errorlevel%==0 (
    echo.
    echo [*] Esecuzione: Gestione Permessi...
    powershell -NoProfile -ExecutionPolicy Bypass -File "Permessi.ps1"
)

echo.
echo ===============================================================
echo Operazioni completate con successo!
pause
goto menu

:fine
echo.
echo Arrivederci!
timeout /t 2 >nul
exit
