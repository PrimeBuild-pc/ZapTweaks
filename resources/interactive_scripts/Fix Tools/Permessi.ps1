# Verifica ed elevazione a privilegi di Amministratore
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Richiesti privilegi di amministratore. Riavvio in corso..." -ForegroundColor Yellow
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "   GESTIONE PERMESSI DI ESECUZIONE SCRIPT" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Sblocco TEMPORANEO (Consigliato)"
Write-Host "   -> Apre una nuova finestra PowerShell con i permessi attivi."
Write-Host "      Puoi eseguire gli script che vuoi li dentro."
Write-Host "      Appena la chiudi, il PC torna protetto come prima."
Write-Host ""
Write-Host "2. Sblocco PERMANENTE (Sconsigliato)"
Write-Host "   -> Modifica le impostazioni di Windows in modo definitivo."
Write-Host "      Rischioso se esegui file da fonti non fidate."
Write-Host "=============================================="
Write-Host ""

$scelta = Read-Host "Digita 1 o 2 e premi Invio"

if ($scelta -eq '1') {
    Write-Host ""
    Write-Host "[OK] Apertura nuova finestra PowerShell con permessi temporanei..." -ForegroundColor Green
    Write-Host "     Esegui i tuoi script li dentro, poi chiudi quella finestra." -ForegroundColor DarkGray

    # Apre una nuova finestra PowerShell interattiva con Bypass attivo
    # -NoExit mantiene la finestra aperta dopo l'avvio
    Start-Process powershell.exe -ArgumentList @(
        "-NoProfile",
        "-ExecutionPolicy", "Bypass",
        "-NoExit",
        "-Command", @"
`$Host.UI.RawUI.WindowTitle = 'PowerShell - Permessi Temporanei Attivi'
Write-Host '==============================================' -ForegroundColor Green
Write-Host '  PERMESSI TEMPORANEI ATTIVI IN QUESTA FINESTRA' -ForegroundColor Green
Write-Host '==============================================' -ForegroundColor Green
Write-Host ''
Write-Host 'Puoi eseguire qualsiasi script .ps1 da qui, ad esempio:' -ForegroundColor Cyan
Write-Host '  .\NomeScript.ps1' -ForegroundColor White
Write-Host ''
Write-Host 'I permessi sono validi SOLO in questa finestra.' -ForegroundColor Yellow
Write-Host 'Chiudila quando hai finito per ripristinare la protezione.' -ForegroundColor Yellow
Write-Host ''
"@
    ) -Verb RunAs

} elseif ($scelta -eq '2') {
    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope LocalMachine -Force
    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser -Force
    Write-Host ""
    Write-Host "[ATTENZIONE] Sblocco permanente attivato su tutto il sistema." -ForegroundColor DarkYellow
} else {
    Write-Host "Scelta non valida. Nessuna modifica apportata." -ForegroundColor Red
}

Write-Host ""
Write-Host "Chiusura in corso..."
Start-Sleep -Seconds 3
