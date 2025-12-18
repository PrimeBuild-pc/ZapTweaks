# Script PowerShell per creare installer ZapTweaks
# Crea un archivio ZIP con tutti i file necessari

$AppName = "ZapTweaks"
$Version = "1.0"
$BuildPath = "C:\Users\Lorenzo\Documents\Projects\script\app\script_utility\build\windows\x64\runner\Release"
$OutputPath = "C:\Users\Lorenzo\Documents\Projects\script\app\script_utility\installer_output"
$OutputFile = "$OutputPath\${AppName}_v${Version}_Windows.zip"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  ZapTweaks Installer Creator" -ForegroundColor Cyan
Write-Host "  by PrimeBuild" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Crea la cartella di output se non esiste
if (!(Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
    Write-Host "[OK] Cartella output creata: $OutputPath" -ForegroundColor Green
}

# Verifica che il build esista
if (!(Test-Path $BuildPath)) {
    Write-Host "[ERROR] Build non trovata in $BuildPath" -ForegroundColor Red
    Write-Host "    Esegui flutter build windows --release prima di questo script" -ForegroundColor Yellow
    pause
    exit 1
}

Write-Host "[->] Compressione dei file..." -ForegroundColor Yellow

# Rimuovi vecchio archivio se esiste
if (Test-Path $OutputFile) {
    Remove-Item $OutputFile -Force
    Write-Host "[OK] Vecchio archivio rimosso" -ForegroundColor Green
}

# Crea archivio ZIP
try {
    Compress-Archive -Path "$BuildPath\*" -DestinationPath $OutputFile -CompressionLevel Optimal -Force
    Write-Host "[OK] Archivio creato con successo!" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Errore durante la compressione: $_" -ForegroundColor Red
    pause
    exit 1
}

# Ottieni dimensione file
$FileSize = (Get-Item $OutputFile).Length / 1MB
$FileSizeRounded = [math]::Round($FileSize, 2)

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  INSTALLER CREATO CON SUCCESSO!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "File:        $OutputFile" -ForegroundColor White
Write-Host "Dimensione:  $FileSizeRounded MB" -ForegroundColor White
Write-Host ""
Write-Host "Per installare:" -ForegroundColor Yellow
Write-Host "1. Estrai il contenuto dello ZIP" -ForegroundColor White
Write-Host "2. Esegui script_utility.exe come Amministratore" -ForegroundColor White
Write-Host ""
Write-Host "App richiede privilegi amministratore per" -ForegroundColor Yellow
Write-Host "applicare le ottimizzazioni di sistema." -ForegroundColor Yellow
Write-Host ""

# Apri la cartella di output
Start-Process explorer.exe -ArgumentList "/select,$OutputFile"

Write-Host "Premi un tasto per uscire..." -ForegroundColor Cyan
pause
