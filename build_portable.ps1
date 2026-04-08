param(
    [switch]$SkipFlutterBuild
)

$ErrorActionPreference = 'Stop'

$RepoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$BuildPathCandidates = @(
    (Join-Path $RepoRoot 'build\windows\x64\runner\Release'),
    (Join-Path $RepoRoot 'build\windows\runner\Release')
)
$OutputDir = Join-Path $RepoRoot 'output'
$PortableZipPath = Join-Path $OutputDir 'ZapTweaks_Portable.zip'

Write-Host '==========================================' -ForegroundColor Cyan
Write-Host '  ZapTweaks Portable Build' -ForegroundColor Cyan
Write-Host '==========================================' -ForegroundColor Cyan
Write-Host "Repository:  $RepoRoot"
Write-Host ''

if (!(Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

if (-not $SkipFlutterBuild) {
    Write-Host '[->] Building Flutter Windows release...' -ForegroundColor Yellow
    Push-Location $RepoRoot
    try {
        & flutter build windows --release
        if ($LASTEXITCODE -ne 0) {
            throw 'flutter build windows --release failed.'
        }
    }
    finally {
        Pop-Location
    }
}

$BuildPath = $BuildPathCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $BuildPath) {
    throw "Build output not found. Checked: $($BuildPathCandidates -join ', ')"
}

$UninstallerPath = Join-Path $RepoRoot 'uninstaller.bat'
if (Test-Path $UninstallerPath) {
    Copy-Item $UninstallerPath (Join-Path $BuildPath 'uninstaller.bat') -Force
    Write-Host '[->] Included uninstaller.bat in release folder.' -ForegroundColor Yellow
} else {
    Write-Host '[!] uninstaller.bat not found in repo root, skipping inclusion.' -ForegroundColor DarkYellow
}

Write-Host '[->] Creating portable ZIP...' -ForegroundColor Yellow
if (Test-Path $PortableZipPath) {
    Remove-Item $PortableZipPath -Force
}

Compress-Archive -Path (Join-Path $BuildPath '*') -DestinationPath $PortableZipPath -CompressionLevel Optimal -Force

$zipSizeMb = [math]::Round(((Get-Item $PortableZipPath).Length / 1MB), 2)
Write-Host "[OK] Portable package created: $PortableZipPath ($zipSizeMb MB)" -ForegroundColor Green
Write-Host ''
Write-Host '==========================================' -ForegroundColor Cyan
Write-Host '  COMPLETED' -ForegroundColor Green
Write-Host '==========================================' -ForegroundColor Cyan
Write-Host "Output folder: $OutputDir"
