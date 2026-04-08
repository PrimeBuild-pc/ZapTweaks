# Cambia Nome Account Amministratore
Write-Host "--- Modifica Nome Account Amministratore ---" -ForegroundColor Cyan
$newName = Read-Host "Inserisci il nuovo nome completo per l'account Administrator"

if ([string]::IsNullOrWhiteSpace($newName)) {
    Write-Host "Nessun nome inserito. Operazione annullata." -ForegroundColor Red
} else {
    net user Administrator /fullname:"$newName"
    Write-Host "Nome aggiornato con successo in: $newName" -ForegroundColor Green
}

Start-Sleep -Seconds 2