Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$currentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal($currentIdentity)
$isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host 'Relaunching with administrator privileges...' -ForegroundColor Yellow

    $scriptUrl = 'https://raw.githubusercontent.com/PrimeBuild-pc/ZapTweaks/main/scripts/installer-latest.ps1'
    $relaunchCommand = "irm '$scriptUrl' | iex"

    Start-Process -FilePath 'powershell' -Verb RunAs -ArgumentList @(
        '-NoProfile',
        '-ExecutionPolicy', 'Bypass',
        '-Command', $relaunchCommand
    ) | Out-Null

    exit
}

function Select-ReleaseAsset {
    param(
        [Parameter(Mandatory = $true)]
        [array]$Assets
    )

    $preferredInstaller = $Assets |
        Where-Object {
            $_.browser_download_url -and (
                $_.name -match '(?i)setup|installer|\.exe$|\.msi$'
            )
        } |
        Select-Object -First 1

    if ($preferredInstaller) {
        return $preferredInstaller
    }

    $portableZip = $Assets |
        Where-Object {
            $_.browser_download_url -and $_.name -match '(?i)portable|\.zip$'
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

$asset = Select-ReleaseAsset -Assets $release.assets
if (-not $asset) {
    throw 'No compatible installer or portable asset found in latest release.'
}

$downloadRoot = Join-Path $env:TEMP 'ZapTweaks\installer'
New-Item -ItemType Directory -Path $downloadRoot -Force | Out-Null

$assetName = [IO.Path]::GetFileName($asset.browser_download_url)
$downloadPath = Join-Path $downloadRoot $assetName

Write-Host "Downloading $assetName ..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $downloadPath -UseBasicParsing

if ($assetName -match '(?i)\.exe$|\.msi$') {
    Write-Host 'Launching installer...' -ForegroundColor Green
    Start-Process -FilePath $downloadPath -Wait
    Write-Host 'Installer completed.' -ForegroundColor Green
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
