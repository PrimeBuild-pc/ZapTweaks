# Riparazione dell'immagine di sistema e dei file corrotti
Write-Host "--- Avvio scansione DISM (Riparazione Immagine) ---" -ForegroundColor Cyan
dism /online /cleanup-image /restorehealth

Write-Host "--- Avvio scansione SFC (Controllo File di Sistema) ---" -ForegroundColor Cyan
sfc /scannow

Write-Host "Fatto! Riavvia il PC se sono stati trovati e corretti errori." -ForegroundColor Green
Pause