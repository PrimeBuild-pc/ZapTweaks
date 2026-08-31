import 'dart:convert';

import '../models/hardware_profile.dart';
import 'process_runner.dart';

class HardwareDetectionService {
  HardwareDetectionService({required ProcessRunner processRunner})
    : _processRunner = processRunner;

  final ProcessRunner _processRunner;

  /// Detection runs as one PowerShell process. It is passed as a base64
  /// -EncodedCommand, so the whole script must stay well under the 32767
  /// character Windows command-line limit once encoded (roughly 12000 source
  /// characters). Keep comments out of the string - they are payload.
  /// `hardware_detection_script_test.dart` fails the build if it grows too far.
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

$genericNamePattern = '(?i)^(hid[- ]compliant|usb input device|usb composite|generic |standard |wireless (receiver|dongle)$|composite )'

$usbRootCache = @{}
$productNameCache = @{}
$primaryProtocolCache = @{}

function Get-UsbRootInstanceId {
  param([string]$InstanceId)
  if ($usbRootCache.ContainsKey($InstanceId)) { return $usbRootCache[$InstanceId] }
  $current = $InstanceId
  for ($i = 0; $i -lt 8; $i++) {
    $parent = (Get-PnpDeviceProperty -InstanceId $current -KeyName DEVPKEY_Device_Parent -ErrorAction SilentlyContinue).Data
    if (-not $parent -or $parent -notlike 'USB\VID_*') { break }
    $current = $parent
    if ($current -match '^USB\\VID_[0-9A-Fa-f]{4}&PID_[0-9A-Fa-f]{4}\\') { break }
  }
  $usbRootCache[$InstanceId] = $current
  return $current
}

function Get-DeviceProductName {
  param([string]$InstanceId)
  if ([string]::IsNullOrWhiteSpace($InstanceId)) { return '' }
  if ($productNameCache.ContainsKey($InstanceId)) { return $productNameCache[$InstanceId] }
  $resolved = ''
  $properties = Get-PnpDeviceProperty -InstanceId $InstanceId -KeyName DEVPKEY_Device_BusReportedDeviceDesc,DEVPKEY_Device_FriendlyName,DEVPKEY_Device_DeviceDesc -ErrorAction SilentlyContinue
  foreach ($key in @('DEVPKEY_Device_BusReportedDeviceDesc','DEVPKEY_Device_FriendlyName','DEVPKEY_Device_DeviceDesc')) {
    $value = "$(($properties | Where-Object { $_.KeyName -eq $key } | Select-Object -First 1).Data)".Trim()
    if ($value -and $value -notmatch $genericNamePattern) { $resolved = $value; break }
  }
  $productNameCache[$InstanceId] = $resolved
  return $resolved
}

function Get-PrimaryHidProtocol {
  param([string]$RootInstanceId)
  if ($RootInstanceId -notmatch 'VID_([0-9A-Fa-f]{4})&PID_([0-9A-Fa-f]{4})') { return '' }
  $devicePrefix = "VID_$($Matches[1])&PID_$($Matches[2])&MI_"
  if ($primaryProtocolCache.ContainsKey($devicePrefix)) { return $primaryProtocolCache[$devicePrefix] }
  $primary = ''
  $bestIndex = 99
  try {
    foreach ($k in (Get-ChildItem 'HKLM:\SYSTEM\CurrentControlSet\Enum\USB' -ErrorAction Stop | Where-Object { $_.PSChildName -like "$devicePrefix*" })) {
      $index = 99
      if ($k.PSChildName -match '&MI_([0-9A-Fa-f]{2})$') { $index = [Convert]::ToInt32($Matches[1], 16) }
      if ($index -ge $bestIndex) { continue }
      foreach ($inst in (Get-ChildItem $k.PSPath -ErrorAction SilentlyContinue)) {
        foreach ($id in @((Get-ItemProperty $inst.PSPath -Name CompatibleIDs -ErrorAction SilentlyContinue).CompatibleIDs)) {
          if ("$id" -match 'Class_03&SubClass_01&Prot_02') { $primary = 'Mouse'; $bestIndex = $index; break }
          if ("$id" -match 'Class_03&SubClass_01&Prot_01') { $primary = 'Keyboard'; $bestIndex = $index; break }
        }
      }
    }
  } catch {}
  $primaryProtocolCache[$devicePrefix] = $primary
  return $primary
}

function Get-InputDevices {
  param([string]$DeviceClass)
  $results = [ordered]@{}
  try { $devices = @(Get-PnpDevice -Class $DeviceClass -PresentOnly -ErrorAction Stop) } catch { $devices = @() }
  foreach ($device in $devices) {
    if (-not $device.InstanceId) { continue }
    $root = Get-UsbRootInstanceId $device.InstanceId
    $primary = Get-PrimaryHidProtocol $root
    if ($primary -and $primary -ne $DeviceClass) { continue }
    $name = Get-DeviceProductName $root
    if (-not $name) { $name = Get-DeviceProductName $device.InstanceId }
    $vid = ''
    $productId = ''
    if ($root -match 'VID_([0-9A-Fa-f]{4})&PID_([0-9A-Fa-f]{4})') { $vid = $Matches[1].ToUpperInvariant(); $productId = $Matches[2].ToUpperInvariant() }
    if (-not $results.Contains($root)) { $results[$root] = "$name|$vid|$productId" }
  }
  if ($results.Count -eq 0) {
    $cimClass = if ($DeviceClass -eq 'Mouse') { 'Win32_PointingDevice' } else { 'Win32_Keyboard' }
    foreach ($device in (Get-CimInstance $cimClass -ErrorAction SilentlyContinue)) {
      $name = "$($device.Name)".Trim()
      if ($name -and -not $results.Contains($name)) { $results[$name] = "$name||" }
    }
  }
  return @($results.Values | Sort-Object -Unique)
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
  $name = "$name".Trim()
  $manufacturer = "$manufacturer".Trim()
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
  mice = Get-InputDevices 'Mouse'
  keyboards = Get-InputDevices 'Keyboard'
  windowsBuild = if ($os.BuildNumber) { [int]$os.BuildNumber } else { 0 }
} | ConvertTo-Json -Compress -Depth 4
''';

  /// USB vendor IDs for peripheral makers, used to prefix a bare product
  /// string with the brand. Only verified entries belong here: showing the
  /// wrong brand is worse than showing none, so an unknown VID falls through to
  /// the raw VID/PID instead of a guess.
  static const Map<String, String> _usbVendors = <String, String>{
    '046D': 'Logitech',
    '1532': 'Razer',
    '1B1C': 'Corsair',
    '1038': 'SteelSeries',
    '045E': 'Microsoft',
    '0B05': 'ASUS',
    '1E7D': 'ROCCAT',
    '413C': 'Dell',
    '17EF': 'Lenovo',
    '05AC': 'Apple',
    '0458': 'Genius',
    '2717': 'Xiaomi',
    '24AE': 'Rapoo',
    '31E3': 'Wooting',
    '3434': 'Keychron',
    '0951': 'Kingston',
    '03F0': 'HP',
    '04F2': 'Chicony',
    '3554': 'Compx',
  };

  /// Turns one `name|VID|PID` row from the detection script into the label
  /// shown on the Home page.
  static String formatInputDevice(String raw) {
    final parts = raw.split('|');
    var name = parts.isNotEmpty ? parts[0].trim() : '';
    final vendorId = parts.length > 1 ? parts[1].trim().toUpperCase() : '';
    final productId = parts.length > 2 ? parts[2].trim().toUpperCase() : '';
    final vendor = _usbVendors[vendorId];

    if (name.isNotEmpty &&
        vendor != null &&
        !name.toLowerCase().contains(vendor.toLowerCase())) {
      name = '$vendor $name';
    }
    if (name.isEmpty) {
      name = vendor ?? 'Unknown device';
    }
    // Unbranded devices keep their hardware ids so they stay identifiable.
    if (vendorId.isNotEmpty && vendor == null) {
      name = '$name [VID_$vendorId/PID_$productId]';
    }
    return name;
  }

  List<String> _inputDevices(Object? value) {
    final seen = <String>{};
    return _strings(value)
        .map(formatInputDevice)
        .where((entry) => entry.isNotEmpty && seen.add(entry))
        .toList(growable: false);
  }

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
        mice: _inputDevices(decoded['mice']),
        keyboards: _inputDevices(decoded['keyboards']),
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
