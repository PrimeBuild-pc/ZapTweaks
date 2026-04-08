# Reset completo delle impostazioni di rete
Write-Host "--- Reset della rete in corso ---" -ForegroundColor Yellow
ipconfig /release
ipconfig /renew
ipconfig /flushdns
netsh int ip reset
netsh winsock reset

Write-Host "Rete resettata. Un riavvio è caldamente consigliato." -ForegroundColor Green
Pause