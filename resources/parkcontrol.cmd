@echo off
echo Disabilito Core Parking e Frequency Scaling per massime prestazioni...
echo (Esegui come Amministratore!)

:: Disabilita Core Parking (imposta minimo cores al 100%)
powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR CPMINCORES 100
powercfg /setdcvalueindex SCHEME_CURRENT SUB_PROCESSOR CPMINCORES 100

:: Disabilita Frequency Scaling (imposta minimo processor state al 100%)
powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 100
powercfg /setdcvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 100

:: Applica le modifiche immediatamente
powercfg /setactive SCHEME_CURRENT

echo.
echo Fatto!
echo Per ripristinare i valori di default: powercfg -restoredefaultschemes
pause