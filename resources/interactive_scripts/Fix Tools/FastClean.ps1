# Ferma i servizi di Windows Update
Write-Host "Arresto servizi di rete e aggiornamento..." -ForegroundColor Cyan
Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue
Stop-Service -Name bits -Force -ErrorAction SilentlyContinue

Start-Sleep -Seconds 2

# Elimina SOLO i file scaricati degli aggiornamenti
Write-Host "Pulizia cache aggiornamenti (Download)..." -ForegroundColor Yellow
$wuDownload = "$env:WinDir\SoftwareDistribution\Download\*"
Remove-Item -Path $wuDownload -Recurse -Force -ErrorAction SilentlyContinue

# Pulisce i file temporanei di sistema
Write-Host "Pulizia file temporanei locali..." -ForegroundColor Yellow
Remove-Item -Path "$env:Temp\*" -Recurse -Force -ErrorAction SilentlyContinue

# Fai ripartire i servizi
Write-Host "Riavvio servizi..." -ForegroundColor Cyan
Start-Service -Name wuauserv -ErrorAction SilentlyContinue
Start-Service -Name bits -ErrorAction SilentlyContinue

Write-Host "Pulizia di base completata." -ForegroundColor Green
Write-Host ""
Write-Host "--- PULIZIA DISCO AVANZATA (Cleanmgr) ---" -ForegroundColor Cyan
Write-Host "Scegli un'opzione per la pulizia profonda:"
Write-Host "[C] Configura la pulizia (apre la finestra, da fare solo la prima volta)"
Write-Host "[E] Esegui la pulizia automatica (silenziosa, usa la configurazione salvata)"
Write-Host "[N] Salta la pulizia profonda"
Write-Host ""

$scelta = Read-Host "Digita C, E oppure N"

if ($scelta -match '^[Cc]$') {
    Write-Host "Apertura configurazione... Spunta le caselle che desideri e premi OK." -ForegroundColor Yellow
    # Apre cleanmgr per salvare le impostazioni nel profilo "65"
    Start-Process cleanmgr.exe -ArgumentList "/sageset:65" -Wait
    
    Write-Host "Configurazione salvata! Avvio la pulizia in background..." -ForegroundColor Green
    # Esegue subito la pulizia con il profilo appena creato
    Start-Process cleanmgr.exe -ArgumentList "/sagerun:65" -Wait
    Write-Host "[OK] Pulizia profonda completata!" -ForegroundColor Green
} 
elseif ($scelta -match '^[Ee]$') {
    Write-Host "Avvio pulizia profonda in background... Attendi." -ForegroundColor Yellow
    # Esegue la pulizia leggendo il profilo "65"
    Start-Process cleanmgr.exe -ArgumentList "/sagerun:65" -Wait
    Write-Host "[OK] Pulizia profonda completata!" -ForegroundColor Green
}
else {
    Write-Host "Pulizia disco avanzata saltata." -ForegroundColor DarkGray
}

Write-Host ""
Write-Host "Tutte le operazioni del FastClean sono terminate!" -ForegroundColor Green
Start-Sleep -Seconds 2