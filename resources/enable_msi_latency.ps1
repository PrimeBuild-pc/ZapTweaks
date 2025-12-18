# Abilita MSI mode e priorità "High" su LAN (Realtek), GPU (NVIDIA/AMD), NVMe e controller USB/xHCI
# Crea anche un backup dei valori precedenti (Desktop\msi_backup.csv) per eventuale ripristino.

# --- Funzioni di utilità ---
function Ensure-Key($Path) { if (-not (Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null } }

function Set-MSI($InstanceId) {
    $base = "HKLM:\SYSTEM\CurrentControlSet\Enum\$InstanceId\Device Parameters\Interrupt Management"
    $msi  = Join-Path $base "MessageSignaledInterruptProperties"
    $aff  = Join-Path $base "Affinity Policy"
    Ensure-Key $msi
    Ensure-Key $aff

    # Backup valore precedente
    $prev = (Get-ItemProperty -Path $msi -Name MSISupported -ErrorAction SilentlyContinue).MSISupported
    [PSCustomObject]@{
        Timestamp   = (Get-Date)
        InstanceId  = $InstanceId
        PrevMSI     = if ($prev -ne $null) { $prev } else { "<unset>" }
    }
    # Abilita MSI
    New-ItemProperty -Path $msi -Name MSISupported -PropertyType DWord -Value 1 -Force | Out-Null
    # Suggerisci priorità alta (Windows può ignorarla se non supportata)
    New-ItemProperty -Path $aff -Name DevicePolicy -PropertyType String -Value "High" -Force | Out-Null
}

Write-Host "Raccolta dispositivi..." -ForegroundColor Cyan
$devs = @()

# LAN Realtek
$devs += Get-PnpDevice -Class Net -PresentOnly | Where-Object {
    $_.Status -eq "OK" -and $_.Manufacturer -match "Realtek"
}

# GPU (NVIDIA / AMD)
$devs += Get-PnpDevice -Class Display -PresentOnly | Where-Object {
    $_.Status -eq "OK" -and ($_.Manufacturer -match "NVIDIA|Advanced Micro Devices|AMD")
}

# NVMe controller (può essere in 'Storage controllers' o 'SCSIAdapter')
$devs += Get-PnpDevice -PresentOnly | Where-Object {
    $_.Status -eq "OK" -and ($_.FriendlyName -match "NVMe" -or $_.InstanceId -match "NVME")
}

# USB/xHCI controller
$devs += Get-PnpDevice -PresentOnly | Where-Object {
    $_.Status -eq "OK" -and ($_.FriendlyName -match "xHCI|USB 3\.|USB3|USB eXtensible Host Controller")
}

$devs = $devs | Sort-Object InstanceId -Unique

if (-not $devs) { Write-Host "Nessun dispositivo idoneo trovato." -ForegroundColor Yellow; return }

# Backup su CSV
$backupPath = Join-Path ([Environment]::GetFolderPath('Desktop')) "msi_backup.csv"
$backup = @()

Write-Host "`nDispositivi trovati:" -ForegroundColor Green
$devs | ForEach-Object {
    Write-Host " - $($_.FriendlyName) [$($_.InstanceId)]"
    $backup += Set-MSI -InstanceId $_.InstanceId
}

$backup | Export-Csv -Path $backupPath -NoTypeInformation -Encoding UTF8
Write-Host "`nBackup creato: $backupPath" -ForegroundColor Yellow
Write-Host "MSI abilitato. Riavvia Windows per applicare." -ForegroundColor Cyan
