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
$gpus = @(Get-CimInstance Win32_VideoController | ForEach-Object { $_.Name })
$computer = Get-CimInstance Win32_ComputerSystem | Select-Object -First 1
$os = Get-CimInstance Win32_OperatingSystem | Select-Object -First 1
$audio = @(Get-CimInstance Win32_SoundDevice | ForEach-Object { $_.Name })

$network = @(Get-NetAdapter | Where-Object { $_.Status -eq 'Up' } | ForEach-Object {
  $adapter = $_
  $name = $adapter.InterfaceDescription
  $driverModel = 'NDIS/Unknown'
  $driverFile = ''

  if ($adapter.PnPDeviceID) {
    $devicePath = 'HKLM:\SYSTEM\CurrentControlSet\Enum\' + $adapter.PnPDeviceID
    $device = Get-ItemProperty -Path $devicePath
    $serviceName = "$($device.Service)".ToLower()
    $dependencies = ''

    if ($serviceName) {
      $service = Get-ItemProperty -Path ('HKLM:\SYSTEM\CurrentControlSet\Services\' + $serviceName)
      $driverFile = [System.IO.Path]::GetFileName("$($service.ImagePath)").ToLower()
      $dependencies = (@($service.DependOnService) -join ' ').ToLower()
    }

    $ndisVersion = (Get-ItemProperty -Path ($devicePath + '\Device Parameters\Ndis')).NdisVersion
    $signal = ($name + ' ' + $serviceName + ' ' + $driverFile + ' ' + $dependencies).ToLower()

    if ($dependencies -match 'netadaptercx' -or $signal -match 'netadaptercx|ndiscx' -or $serviceName -match '^rtcx|^e2f|^rtwlanex') {
      $driverModel = 'NetAdapterCx'
    } elseif ($ndisVersion) {
      $driverModel = 'NDIS ' + $ndisVersion
    }
  }

  if ($driverFile) {
    $name + ' [' + $driverModel + '; driver: ' + $driverFile + ']'
  } else {
    $name + ' [' + $driverModel + ']'
  }
})

if ($network.Count -eq 0) {
  $network = @(Get-NetAdapter | Where-Object { $_.Status -eq 'Up' } | ForEach-Object { $_.InterfaceDescription })
}

[pscustomobject]@{
  cpuName = if ($cpu.Name) { "$($cpu.Name)" } else { 'Unknown CPU' }
  gpuNames = $gpus
  ramInstalledBytes = if ($computer.TotalPhysicalMemory) { [uint64]$computer.TotalPhysicalMemory } else { 0 }
  networkAdapters = $network
  audioDevices = $audio
  windowsBuild = if ($os.BuildNumber) { [int]$os.BuildNumber } else { 0 }
} | ConvertTo-Json -Compress -Depth 3
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
