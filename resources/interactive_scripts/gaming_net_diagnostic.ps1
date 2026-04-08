param(
    [int]$IdleSeconds = 20,
    [int]$LoadSeconds = 30
)

$ErrorActionPreference = "SilentlyContinue"

# Directory script e log
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ScriptDir

Write-Host "=== Diagnostica rete gaming (Windows) ===" -ForegroundColor Green

# =========================
# CONFIGURAZIONE DI BASE
# =========================

$PingTargets = @{
    Gateway  = $null      # se $null, auto-detect
    DNS1     = "1.1.1.1"
    DNS2     = "8.8.8.8"
    Internet = "8.8.8.8"
}

$DownloadUrl = "http://speedtest.tele2.net/100MB.zip"

# =========================
# GAME TARGETS
# → QUI INCOLLI A MANO IP/PORTA presi dallo sniffer
# =========================
$GameTargets = @(
    # Esempio:
     @{ Name = "Fortnite_EU"; Host = "18.157.42.2"; Port = 9060; Proto = "UDP" }
)

# =========================
# FUNZIONI
# =========================

function Write-Section($title) {
    Write-Host ""
    Write-Host "=== $title ===" -ForegroundColor Cyan
}

function Get-Gateway {
    $gw = (Get-NetRoute -DestinationPrefix "0.0.0.0/0" -ErrorAction SilentlyContinue |
           Sort-Object RouteMetric |
           Select-Object -First 1 -ExpandProperty NextHop)
    if (-not $gw) { return $null }
    return $gw
}

function Test-PingStats {
    param(
        [string]$TargetHost,
        [int]$Seconds,
        [string]$Label,
        [string]$LogFileName = $null
    )

    if (-not $TargetHost) {
        Write-Host "${Label}: target vuoto, skip." -ForegroundColor Yellow
        return
    }

    $interval = 0.2
    $count = [int]([math]::Round($Seconds / $interval))

    Write-Host "[INFO] Ping ${Label} verso $TargetHost per ~${Seconds}s (count=$count)..." -ForegroundColor Blue

    # Statistiche con Test-Connection
    $results = Test-Connection -TargetName $TargetHost -Count $count -ErrorAction SilentlyContinue

    if (-not $results) {
        Write-Host "${Label}: N/A (nessuna risposta, possibile ICMP bloccato)" -ForegroundColor Yellow
    } else {
        $rtts = $results | Select-Object -ExpandProperty ResponseTime
        $avg  = ($rtts | Measure-Object -Average).Average
        $std  = ($rtts | Measure-Object -StandardDeviation).StandardDeviation

        $avg  = [math]::Round($avg, 2)
        $jitt = [math]::Round($std, 2)

        $lossCount = $count - $rtts.Count
        $lossPct = 0
        if ($count -gt 0) {
            $lossPct = [math]::Round(($lossCount / $count) * 100, 1)
        }

        Write-Host ("{0}: avg={1}ms, jitter≈{2}ms, loss={3}% ({4}/{5} persi)" -f `
            $Label, $avg, $jitt, $lossPct, $lossCount, $count)
    }

    # Log su file (formato semplice, leggibile)
    if ($LogFileName) {
        $logPath = Join-Path $ScriptDir $LogFileName
        $lines = @()
        $lines += "# Ping log per ${Label} verso ${TargetHost}"
        $lines += "# Data: $(Get-Date -Format o)"
        $lines += "# Tentativi: $count"
        if ($results) {
            $lines += "# Risposte ricevute: $($results.Count)"
            $lines += "# Ogni riga: <index> <rtt_ms>"
            $i = 0
            foreach ($r in $results) {
                $i++
                $lines += ("{0} {1}" -f $i, $r.ResponseTime)
            }
        } else {
            $lines += "# Nessuna risposta"
        }
        $lines | Set-Content -Encoding UTF8 $logPath
        Write-Host "  -> Log salvato in $logPath"
    }
}

function Test-BufferbloatDownload {
    param(
        [string]$TargetHost,
        [int]$Seconds,
        [string]$LogFileName = $null
    )

    if (-not $TargetHost) {
        Write-Host "Bufferbloat: host vuoto, skip." -ForegroundColor Yellow
        return
    }

    Write-Host "[INFO] Test bufferbloat download verso $TargetHost per ~${Seconds}s" -ForegroundColor Blue

    $interval = 0.2
    $count = [int]([math]::Round($Seconds / $interval))

    # Ping in background (per stats)
    $pingJob = Start-Job -ScriptBlock {
        param($TargetHost, $Count)
        Test-Connection -TargetName $TargetHost -Count $Count -ErrorAction SilentlyContinue
    } -ArgumentList $TargetHost, $count

    # Download “pesante” in foreground
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    while ($sw.Elapsed.TotalSeconds -lt $Seconds) {
        try {
            curl.exe $using:DownloadUrl -o "$env:TEMP\gaming_diag_dl.tmp" 1>$null 2>$null
        } catch {}
    }
    $sw.Stop()

    $results = Receive-Job $pingJob -Wait -AutoRemoveJob
    if (-not $results) {
        Write-Host "Ping sotto carico: N/A (nessuna risposta, ICMP bloccato?)" -ForegroundColor Yellow
    } else {
        $rtts = $results | Select-Object -ExpandProperty ResponseTime
        $avg  = ($rtts | Measure-Object -Average).Average
        $std  = ($rtts | Measure-Object -StandardDeviation).StandardDeviation
        $avg  = [math]::Round($avg, 2)
        $jitt = [math]::Round($std, 2)

        $lossCount = $count - $rtts.Count
        $lossPct = 0
        if ($count -gt 0) {
            $lossPct = [math]::Round(($lossCount / $count) * 100, 1)
        }

        Write-Host ("Ping Internet sotto carico: avg={0}ms, jitter≈{1}ms, loss={2}% ({3}/{4} persi)" -f `
            $avg, $jitt, $lossPct, $lossCount, $count)

        # Log
        if ($LogFileName) {
            $logPath = Join-Path $ScriptDir $LogFileName
            $lines = @()
            $lines += "# Ping log sotto carico verso ${TargetHost}"
            $lines += "# Data: $(Get-Date -Format o)"
            $lines += "# Tentativi: $count"
            $lines += "# Ogni riga: <index> <rtt_ms>"
            $i = 0
            foreach ($r in $results) {
                $i++
                $lines += ("{0} {1}" -f $i, $r.ResponseTime)
            }
            $lines | Set-Content -Encoding UTF8 $logPath
            Write-Host "  -> Log salvato in $logPath"
        }
    }
}

function Test-GameServers {
    Write-Section "5. Test server di gioco REALI (IP sniffati)"

    if (-not $GameTargets -or $GameTargets.Count -eq 0) {
        Write-Host "Nessun GAME_TARGET configurato. Prima esegui sniff_game_server.ps1 e copia qui IP/porta." -ForegroundColor Yellow
        return
    }

    foreach ($g in $GameTargets) {
        $name = $g.Name
        $hostAddr = $g.Host
        $port = $g.Port
        $proto = $g.Proto

        Write-Host ""
        Write-Host ">>> ${name}  (${hostAddr}:${port} ${proto})" -ForegroundColor Green

        # Ping ICMP (no log qui per non creare troppi file; se vuoi possiamo aggiungerlo)
        Test-PingStats -TargetHost $hostAddr -Seconds 10 -Label "Ping ICMP $name"

        # Test-NetConnection
        try {
            $tnc = Test-NetConnection -ComputerName $hostAddr -Port $port -WarningAction SilentlyContinue
            $rtt = $null
            if ($tnc.PingReplyDetails) {
                $rtt = $tnc.PingReplyDetails.RoundtripTime
            }
            Write-Host ("Test-NetConnection: TcpTestSucceeded={0}, RTT={1}ms" -f $tnc.TcpTestSucceeded, $rtt)
        } catch {
            Write-Host "Test-NetConnection fallito: $_"
        }

        # Traceroute
        Write-Host "Traceroute (tracert) verso $hostAddr..."
        tracert $hostAddr
    }
}

# =========================
# MAIN
# =========================

Write-Section "1. Info di base"
Write-Host "Hostname: $env:COMPUTERNAME"
Write-Host "Data/ora: $(Get-Date)"
Write-Host "OS: $([System.Environment]::OSVersion.VersionString)"
Write-Host "Interfacce IP:"
Get-NetIPConfiguration | Select-Object InterfaceAlias,IPv4Address,IPv4DefaultGateway | Format-Table

if (-not $PingTargets.Gateway) {
    $PingTargets.Gateway = Get-Gateway
}
Write-Host "Gateway rilevato: $($PingTargets.Gateway)"

Write-Section "2. Latenza e jitter idle"
Test-PingStats -TargetHost $PingTargets.Gateway  -Seconds $IdleSeconds -Label "Gateway"                    -LogFileName "ping_gateway_idle.log"
Test-PingStats -TargetHost $PingTargets.DNS1     -Seconds $IdleSeconds -Label "DNS1 ($($PingTargets.DNS1))" -LogFileName "ping_dns1_idle.log"
Test-PingStats -TargetHost $PingTargets.DNS2     -Seconds $IdleSeconds -Label "DNS2 ($($PingTargets.DNS2))" -LogFileName "ping_dns2_idle.log"
Test-PingStats -TargetHost $PingTargets.Internet -Seconds $IdleSeconds -Label "Internet ($($PingTargets.Internet))" -LogFileName "ping_internet_idle.log"

Write-Section "3. Bufferbloat (download generale)"
Test-BufferbloatDownload -TargetHost $PingTargets.Internet -Seconds $LoadSeconds -LogFileName "ping_internet_download.log"

Write-Section "4. DNS test"
$domains = "google.com","cloudflare.com","valorant.com","leagueoflegends.com"
foreach ($d in $domains) {
    Write-Host "Query DNS per $d..."
    try {
        $t0 = Get-Date
        $res = Resolve-DnsName $d -ErrorAction Stop
        $t1 = Get-Date
        $ms = [math]::Round(($t1 - $t0).TotalMilliseconds, 2)
        Write-Host "  OK in ${ms}ms → $($res[0].IPAddress)"
    } catch {
        Write-Host "  FALLITA: $_" -ForegroundColor Yellow
    }
}

Test-GameServers

Write-Host ""
Write-Host "=== Test completato (Windows) ===" -ForegroundColor Green
Write-Host "Log generati (se ping ha risposto): ping_*.log nella cartella dello script."
