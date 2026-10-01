Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Select-ReleaseAsset {
    param(
        [Parameter(Mandatory = $true)]
        [array]$Assets,
        [Parameter(Mandatory = $true)]
        [string]$Version
    )

    $preferredInstaller = $Assets |
        Where-Object {
            $_.browser_download_url -and $_.name -eq "ZapTweaks_Setup_v$Version.exe"
        } |
        Select-Object -First 1

    if ($preferredInstaller) {
        return $preferredInstaller
    }

    $portableZip = $Assets |
        Where-Object {
            $_.browser_download_url -and $_.name -eq 'ZapTweaks_Portable.zip'
        } |
        Select-Object -First 1

    return $portableZip
}

$owner = 'PrimeBuild-pc'
$repo = 'ZapTweaks'
$latestReleaseApi = "https://api.github.com/repos/$owner/$repo/releases/latest"

Write-Host 'Fetching latest ZapTweaks release metadata...' -ForegroundColor Cyan
$release = Invoke-RestMethod -Uri $latestReleaseApi -Headers @{ 'User-Agent' = 'ZapTweaks-Installer-Latest' }

if (-not $release -or -not $release.assets) {
    throw 'Unable to resolve release assets from GitHub API.'
}

if ($release.tag_name -notmatch '^v\d+\.\d+\.\d+$' -or $release.draft -or $release.prerelease) {
    throw 'Invalid stable release identity.'
}
$version = $release.tag_name.Substring(1)
$asset = Select-ReleaseAsset -Assets $release.assets -Version $version
if (-not $asset) {
    throw 'No compatible installer or portable asset found in latest release.'
}

$assetName = $asset.name
$expectedUrl = "https://github.com/$owner/$repo/releases/download/$($release.tag_name)/$assetName"
if ($asset.browser_download_url -cne $expectedUrl -or
    -not $asset.PSObject.Properties['digest'] -or $asset.digest -notmatch '^sha256:[a-fA-F0-9]{64}$' -or
    $asset.size -le 0 -or $asset.size -gt 512MB) {
    throw 'No verified official release asset is available.'
}
$expectedHash = $asset.digest.Substring(7)
$downloadRoot = Join-Path $env:LOCALAPPDATA "ZapTweaks\installer\$([guid]::NewGuid())"
New-Item -ItemType Directory -Path $downloadRoot -Force | Out-Null
$ownerSid = [Security.Principal.WindowsIdentity]::GetCurrent().User.Value
& icacls.exe $downloadRoot /inheritance:r /grant:r "*$($ownerSid):(OI)(CI)F" '*S-1-5-18:(OI)(CI)F' '*S-1-5-32-544:(OI)(CI)F' | Out-Null
if ($LASTEXITCODE -ne 0) { throw 'Unable to secure installer directory.' }
$downloadPath = Join-Path $downloadRoot $assetName

Write-Host "Downloading $assetName ..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $downloadPath -UseBasicParsing -TimeoutSec 120
if ((Get-Item -LiteralPath $downloadPath).Length -ne $asset.size -or
    (Get-FileHash -LiteralPath $downloadPath -Algorithm SHA256).Hash -ne $expectedHash) {
    Remove-Item -LiteralPath $downloadRoot -Recurse -Force
    throw 'Downloaded release asset failed SHA-256 or size verification.'
}

if ($assetName -match '(?i)\.exe$|\.msi$') {
    Write-Host 'Launching installer...' -ForegroundColor Green
    Start-Process -FilePath $downloadPath -Wait
    Write-Host 'Installer completed.' -ForegroundColor Green
    Remove-Item -LiteralPath $downloadRoot -Recurse -Force
    return
}

if ($assetName -match '(?i)\.zip$') {
    $extractPath = Join-Path $downloadRoot 'portable'
    if (Test-Path $extractPath) {
        Remove-Item -Path $extractPath -Recurse -Force
    }

    Write-Host 'Extracting portable package...' -ForegroundColor Cyan
    Expand-Archive -Path $downloadPath -DestinationPath $extractPath -Force

    $appExe = Get-ChildItem -Path $extractPath -Filter 'ZapTweaks.exe' -File -Recurse | Select-Object -First 1
    if ($appExe) {
        Write-Host 'Launching ZapTweaks portable build...' -ForegroundColor Green
        Start-Process -FilePath $appExe.FullName
    }
    else {
        Write-Host 'Portable package extracted. Opened folder for manual launch.' -ForegroundColor Yellow
        Start-Process -FilePath 'explorer.exe' -ArgumentList $extractPath
    }

    return
}

throw 'Downloaded asset type is not supported by this bootstrap script.'
