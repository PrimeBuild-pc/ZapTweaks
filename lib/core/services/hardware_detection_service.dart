import 'dart:convert';

import '../models/hardware_profile.dart';
import 'process_runner.dart';

class HardwareDetectionService {
  HardwareDetectionService({required ProcessRunner processRunner})
    : _processRunner = processRunner;

  final ProcessRunner _processRunner;

  static const String _detectionScript = r'''
$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'SilentlyContinue'

$cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
$computer = Get-CimInstance Win32_ComputerSystem | Select-Object -First 1
$os = Get-CimInstance Win32_OperatingSystem | Select-Object -First 1
$signedDrivers = @{}
Get-CimInstance Win32_PnPSignedDriver | ForEach-Object {
  if ($_.DeviceID) { $signedDrivers["$($_.DeviceID)".ToUpperInvariant()] = $_ }
}

function Get-Driver {
  param([string]$PnpDeviceId)
  if ([string]::IsNullOrWhiteSpace($PnpDeviceId)) { return $null }
  return $signedDrivers[$PnpDeviceId.ToUpperInvariant()]
}

function Format-Driver {
  param([object]$Driver)
  if ($null -eq $Driver) { return '' }
  $parts = @()
  if ($Driver.DriverProviderName) { $parts += "$($Driver.DriverProviderName)" }
  if ($Driver.DriverVersion) { $parts += "v$($Driver.DriverVersion)" }
  return $parts -join ' '
}

function Get-NetworkDriverModel {
  param([string]$PnpDeviceId)
  if ([string]::IsNullOrWhiteSpace($PnpDeviceId)) { return 'NDIS' }
  try {
    $enumKey = Get-ItemProperty -Path ('HKLM:\SYSTEM\CurrentControlSet\Enum\' + $PnpDeviceId) -ErrorAction Stop
    $driverKey = "$($enumKey.Driver)"
    if ([string]::IsNullOrWhiteSpace($driverKey)) { return 'NDIS' }
    $ndi = Get-ItemProperty -Path ('HKLM:\SYSTEM\CurrentControlSet\Control\Class\' + $driverKey + '\Ndi') -ErrorAction Stop
    $serviceName = "$($ndi.Service)".TrimEnd('.')
    if ([string]::IsNullOrWhiteSpace($serviceName)) { return 'NDIS' }
    $service = Get-ItemProperty -Path ('HKLM:\SYSTEM\CurrentControlSet\Services\' + $serviceName) -ErrorAction Stop
    $imagePath = "$($service.ImagePath)".Trim('"') -replace '^\\SystemRoot', $env:SystemRoot -replace '^System32', (Join-Path $env:SystemRoot 'System32') -replace '%SystemRoot%', $env:SystemRoot
    if (-not (Test-Path -LiteralPath $imagePath)) { return 'NDIS' }
    $bytes = [System.IO.File]::ReadAllBytes($imagePath)
    $length = [Math]::Min($bytes.Length, 1048576)
    $binaryText = [System.Text.Encoding]::ASCII.GetString($bytes, 0, $length)
    if ($binaryText.IndexOf('NetAdapter', [System.StringComparison]::OrdinalIgnoreCase) -ge 0) { return 'NetAdapterCx' }
  } catch {}
  return 'NDIS'
}

function Get-InputDevices {
  param([string]$CimClass)
  $named = @()
  $fallback = @()
  foreach ($device in (Get-CimInstance $CimClass)) {
    $fallbackName = "$($device.Name)".Trim()
    $name = ''
    if ($device.PNPDeviceID) {
      $properties = Get-PnpDeviceProperty -InstanceId "$($device.PNPDeviceID)" -KeyName DEVPKEY_Device_BusReportedDeviceDesc,DEVPKEY_Device_FriendlyName -ErrorAction SilentlyContinue
      $name = @($properties | Where-Object { $_.Data } | ForEach-Object { "$($_.Data)".Trim() } | Where-Object { $_ } | Select-Object -First 1)[0]
    }
    if ($name -and $name -notmatch '(?i)^HID-compliant|^USB Input Device') {
      $named += $name
    } elseif ($fallbackName) {
      $fallback += $fallbackName
    }
  }
  if ($named.Count -gt 0) { return @($named | Sort-Object -Unique) }
  return @($fallback | Sort-Object -Unique)
}

function Convert-WmiText {
  param([object]$Characters)
  if ($null -eq $Characters) { return '' }
  return -join @($Characters | Where-Object { [int]$_ -ne 0 } | ForEach-Object { [char]$_ })
}

$videoControllers = @(Get-CimInstance Win32_VideoController)
$gpuNames = @($videoControllers | ForEach-Object { "$($_.Name)".Trim() } | Where-Object { $_ } | Sort-Object -Unique)
$gpuDrivers = @($videoControllers | ForEach-Object {
  $name = "$($_.Name)".Trim()
  if (-not $name) { return }
  $driver = Get-Driver "$($_.PNPDeviceID)"
  $details = Format-Driver $driver
  if (-not $details -and $_.DriverVersion) { $details = "v$($_.DriverVersion)" }
  if ($details) { "$name [$details]" } else { $name }
} | Sort-Object -Unique)

$audioDevices = @(Get-CimInstance Win32_SoundDevice | ForEach-Object {
  $name = "$($_.Name)".Trim()
  if (-not $name) { return }
  $details = Format-Driver (Get-Driver "$($_.PNPDeviceID)")
  if ($details) { "$name [$details]" } else { $name }
} | Sort-Object -Unique)

$physicalAdapters = @(Get-NetAdapter -Physical -ErrorAction SilentlyContinue | Where-Object { $_.Status -ne 'Not Present' })
if ($physicalAdapters.Count -eq 0) { $physicalAdapters = @(Get-NetAdapter -ErrorAction SilentlyContinue | Where-Object { $_.HardwareInterface -and $_.Status -ne 'Not Present' }) }
$networkAdapters = @($physicalAdapters | ForEach-Object {
  $adapter = $_
  $name = "$($adapter.InterfaceDescription)".Trim()
  if (-not $name) { $name = "$($adapter.Name)".Trim() }
  $driver = Get-Driver "$($adapter.PnPDeviceID)"
  $details = Format-Driver $driver
  if (-not $details -and $adapter.DriverProvider) { $details = "$($adapter.DriverProvider) v$($adapter.DriverVersion)".Trim() }
  $model = Get-NetworkDriverModel "$($adapter.PnPDeviceID)"
  $status = "$($adapter.Status)".Trim()
  $meta = @($model, $details, $status) | Where-Object { $_ } | Select-Object -Unique
  if ($meta.Count -gt 0) { "$name [$($meta -join '; ')]" } else { $name }
} | Sort-Object -Unique)

$chipsetPattern = 'chipset|smbus|lpc|pci express root|pci root|gpio|i2c|serial io|management engine|\bmei\b|\bpsp\b|iommu|amd.*(pci|smbus|gpio)|intel.*(pci|smbus|serial|management)'
$chipsetDrivers = @($signedDrivers.Values | Where-Object {
  "$($_.DeviceClass)" -eq 'System' -and ("$($_.DeviceName) $($_.DriverName)" -match $chipsetPattern)
} | ForEach-Object {
  $name = "$($_.DeviceName)".Trim()
  $details = Format-Driver $_
  if ($name -and $details) { "$name [$details]" } elseif ($name) { $name }
} | Sort-Object -Unique | Select-Object -First 12)

$monitors = @(Get-CimInstance -Namespace root\wmi -ClassName WmiMonitorID | ForEach-Object {
  $name = Convert-WmiText $_.UserFriendlyName
  $manufacturer = Convert-WmiText $_.ManufacturerName
  if ($name -and $manufacturer) { "$manufacturer $name" } elseif ($name) { $name }
} | Where-Object { $_ } | Sort-Object -Unique)
if ($monitors.Count -eq 0) {
  $monitors = @(Get-CimInstance Win32_DesktopMonitor | ForEach-Object { "$($_.Name)".Trim() } | Where-Object { $_ -and $_ -notmatch '^Generic' } | Sort-Object -Unique)
}

[pscustomobject]@{
  cpuName = if ($cpu.Name) { "$($cpu.Name)" } else { 'Unknown CPU' }
  gpuNames = $gpuNames
  gpuDrivers = $gpuDrivers
  chipsetDrivers = $chipsetDrivers
  ramInstalledBytes = if ($computer.TotalPhysicalMemory) { [uint64]$computer.TotalPhysicalMemory } else { 0 }
  networkAdapters = $networkAdapters
  audioDevices = $audioDevices
  monitors = $monitors
  mice = Get-InputDevices 'Win32_PointingDevice'
  keyboards = Get-InputDevices 'Win32_Keyboard'
  windowsBuild = if ($os.BuildNumber) { [int]$os.BuildNumber } else { 0 }
} | ConvertTo-Json -Compress -Depth 4
''';

  String _detectCpuVendor(String cpuName) {
    final normalized = cpuName.trim().toLowerCase();
    if (normalized.contains('intel')) {
      return 'intel';
    }

    if (normalized.contains('advanced micro devices') ||
        normalized.contains('amd') ||
        normalized.contains('ryzen') ||
        normalized.contains('epyc') ||
        normalized.contains('threadripper')) {
      return 'amd';
    }

    return 'unknown';
  }

  Future<HardwareProfile> detect() async {
    try {
      final output = await _processRunner.runPowerShellForOutput(
        _detectionScript,
      );
      final decoded = jsonDecode(output);
      if (decoded is! Map<String, dynamic>) {
        return HardwareProfile.unknown;
      }

      final cpuName = _string(decoded['cpuName'], fallback: 'Unknown CPU');
      final gpuNames = _strings(decoded['gpuNames']);
      final gpuVendors = <String>{};

      for (final name in gpuNames) {
        final lower = name.toLowerCase();
        if (lower.contains('nvidia') || lower.contains('geforce')) {
          gpuVendors.add('nvidia');
        }
        if (lower.contains('amd') || lower.contains('radeon')) {
          gpuVendors.add('amd');
        }
        if (lower.contains('intel') || lower.contains('arc')) {
          gpuVendors.add('intel');
        }
      }

      return HardwareProfile(
        cpuName: cpuName,
        cpuVendor: _detectCpuVendor(cpuName),
        gpuNames: gpuNames,
        gpuVendors: gpuVendors,
        ramInstalledBytes: (decoded['ramInstalledBytes'] as num?)?.toInt() ?? 0,
        networkAdapters: _strings(decoded['networkAdapters']),
        audioDevices: _strings(decoded['audioDevices']),
        gpuDrivers: _strings(decoded['gpuDrivers']),
        chipsetDrivers: _strings(decoded['chipsetDrivers']),
        monitors: _strings(decoded['monitors']),
        mice: _strings(decoded['mice']),
        keyboards: _strings(decoded['keyboards']),
        windowsBuild: (decoded['windowsBuild'] as num?)?.toInt() ?? 0,
      );
    } catch (_) {
      return HardwareProfile.unknown;
    }
  }

  String _string(Object? value, {required String fallback}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  List<String> _strings(Object? value) {
    final values = value is List ? value : (value == null ? const [] : [value]);
    return values
        .map((entry) => entry.toString().trim())
        .where((entry) => entry.isNotEmpty)
        .toList(growable: false);
  }
}
