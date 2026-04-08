# ==============================================================================
# RIPRISTINO PROFONDO ANTEPRIME E ICONE (SYSTEM-WIDE & CURRENT USER)
# ==============================================================================

Write-Host "--- Avvio ripristino profondo anteprime ---" -ForegroundColor Cyan

# 1. Impostazioni Utente Corrente (Opzioni Cartella)
Write-Host "1/4 Forzatura 'Mostra Anteprime' nelle opzioni utente..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "IconsOnly" -Value 0 -Force

# 2. Rimozione blocchi dai Criteri di Gruppo (Utente e Macchina)
Write-Host "2/4 Pulizia delle restrizioni di sistema (Policies)..."
$policies = @(
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer",
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer"
)

foreach ($policy in $policies) {
    if (Test-Path $policy) {
        # Rimuove le policy che bloccano le anteprime, se esistono, senza dare errori se non ci sono
        Remove-ItemProperty -Path $policy -Name "DisableThumbnails" -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $policy -Name "DisableThumbnailsOnNetworkFolders" -ErrorAction SilentlyContinue
    }
}

# 3. Pulizia profonda della Cache (Richiede chiusura di Explorer)
Write-Host "3/4 Chiusura di Esplora File per sbloccare la cache..." -ForegroundColor Yellow
Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

Write-Host "    -> Eliminazione database anteprime e icone..."
$cachePath = "$env:LocalAppData\Microsoft\Windows\Explorer"
# Elimina sia la cache delle miniature che quella delle icone base
Remove-Item -Path "$cachePath\thumbcache_*.db" -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$cachePath\iconcache_*.db" -Force -ErrorAction SilentlyContinue

# 4. Riavvio di Esplora File
Write-Host "4/4 Riavvio dell'interfaccia di Windows..." -ForegroundColor Cyan
Start-Process explorer.exe

Write-Host "[OK] Procedura di ripristino completata con successo!" -ForegroundColor Green
Write-Host "Nota: dai a Windows qualche secondo per rigenerare le immagini la prima volta che apri una cartella."

Start-Sleep -Seconds 4