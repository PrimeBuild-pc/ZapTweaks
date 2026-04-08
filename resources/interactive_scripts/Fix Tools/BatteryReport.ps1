# Genera report batteria (Versione Migliorata)
$desktopPath = [Environment]::GetFolderPath("Desktop")
$reportPath = Join-Path -Path $desktopPath -ChildPath "BatteryReport.html"

powercfg /batteryreport /output $reportPath

Write-Host "Report generato sul desktop: $reportPath" -ForegroundColor Green
Invoke-Item $reportPath