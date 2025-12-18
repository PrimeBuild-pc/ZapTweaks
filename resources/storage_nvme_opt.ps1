# Ottimizza impostazioni energetiche che impattano storport/stornvme e i DPC:
# - Disabilita PCIe Link State Power Management (ASPM)
# - Disabilita USB Selective Suspend
# - Disattiva "Spegni disco dopo" (AC/DC)
# - Porta il piano su Prestazioni elevate (o Ultimate se presente)
# Tutto reversibile.

function Run($cmd){ Write-Host $cmd -ForegroundColor DarkGray; cmd /c $cmd | Out-Null }

# Disabilita ASPM (PCIe Link State Power Management) AC e DC
Run "powercfg -setacvalueindex scheme_current SUB_PCIEXPRESS ASPM 0"
Run "powercfg -setdcvalueindex scheme_current SUB_PCIEXPRESS ASPM 0"

# Disabilita USB Selective Suspend (spesso causa wake e DPC su xHCI)
Run "powercfg -setacvalueindex scheme_current SUB_USB USBSELECTIVE 0"
Run "powercfg -setdcvalueindex scheme_current SUB_USB USBSELECTIVE 0"

# Non spegnere mai i dischi
Run "powercfg -setacvalueindex scheme_current SUB_DISK DISKIDLE 0"
Run "powercfg -setdcvalueindex scheme_current SUB_DISK DISKIDLE 0"

# Aumenta la reattività CPU: disattiva deep idle (se disponibile) e 100% min. processor state su AC
Run "powercfg -setacvalueindex scheme_current SUB_PROCESSOR PROCTHROTTLEMIN 100"
# Questo setting potrebbe non esistere su tutti i sistemi; se non esiste, viene ignorato:
cmd /c "powercfg -setacvalueindex scheme_current SUB_PROCESSOR IDLEDISABLE 1" | Out-Null

# Applica
Run "powercfg -setactive scheme_current"

Write-Host "`nOttimizzazioni storage/NVMe applicate. Riavvia consigliato." -ForegroundColor Cyan
