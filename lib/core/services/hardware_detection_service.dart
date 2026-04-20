import '../models/hardware_profile.dart';
import 'process_runner.dart';

class HardwareDetectionService {
  HardwareDetectionService({required ProcessRunner processRunner})
    : _processRunner = processRunner;

  final ProcessRunner _processRunner;

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
    String cpuName = 'Unknown CPU';
    String cpuVendor = 'unknown';
    final gpuNames = <String>[];
    final gpuVendors = <String>{};
    var ramInstalledBytes = 0;
    final networkAdapters = <String>[];
    final audioDevices = <String>[];

    final cpu = await _processRunner.run('powershell', <String>[
      '-NoProfile',
      '-Command',
      '(Get-CimInstance Win32_Processor | Select-Object -First 1 -ExpandProperty Name)',
    ]);

    if (cpu.success) {
      final detected = cpu.stdout.trim();
      if (detected.isNotEmpty) {
        cpuName = detected;
        cpuVendor = _detectCpuVendor(detected);
      }
    }

    final gpu = await _processRunner.run('powershell', <String>[
      '-NoProfile',
      '-Command',
      '(Get-CimInstance Win32_VideoController | Select-Object -ExpandProperty Name)',
    ]);

    if (gpu.success) {
      final lines = gpu.stdout
          .split(RegExp(r'\r?\n'))
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList();

      gpuNames.addAll(lines);

      for (final name in lines) {
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
    }

    final ram = await _processRunner.run('powershell', <String>[
      '-NoProfile',
      '-Command',
      r'((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory)',
    ]);

    if (ram.success) {
      final lines = ram.stdout
          .split(RegExp(r'\r?\n'))
          .map((entry) => entry.trim())
          .where((entry) => entry.isNotEmpty)
          .toList(growable: false);
      if (lines.isNotEmpty) {
        ramInstalledBytes = int.tryParse(lines.first) ?? 0;
      }
    }

    const networkScript = r'''
$adapters = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' }
foreach ($adapter in $adapters) {
  $name = $adapter.InterfaceDescription
  $pnp = $adapter.PnPDeviceID
  $driverModel = 'NDIS/Unknown'
  $serviceName = ''
  $driverFile = ''
  $driverDisplayName = ''
  $dependencies = ''
  $ndisVersion = $null

  if ($pnp) {
    $devicePath = 'HKLM:\SYSTEM\CurrentControlSet\Enum\' + $pnp
    $deviceReg = Get-ItemProperty -Path $devicePath -ErrorAction SilentlyContinue

    if ($deviceReg -and $deviceReg.Service) {
      $serviceName = $deviceReg.Service.ToLower()

      $servicePath = 'HKLM:\SYSTEM\CurrentControlSet\Services\' + $deviceReg.Service
      $serviceReg = Get-ItemProperty -Path $servicePath -ErrorAction SilentlyContinue
      if ($serviceReg) {
        if ($serviceReg.ImagePath) {
          $driverFile = [System.IO.Path]::GetFileName($serviceReg.ImagePath).ToLower()
        }
        if ($serviceReg.DependOnService) {
          $dependencies = (@($serviceReg.DependOnService) -join ' ').ToLower()
        }
      }

      try {
        $serviceWmi = Get-CimInstance Win32_SystemDriver -Filter ("Name='" + $deviceReg.Service + "'") -ErrorAction Stop
        if ($serviceWmi.DisplayName) {
          $driverDisplayName = $serviceWmi.DisplayName.ToLower()
        }
        if (-not $driverFile -and $serviceWmi.PathName) {
          $driverFile = [System.IO.Path]::GetFileName($serviceWmi.PathName).ToLower()
        }
      } catch {}
    }

    $ndisPath = $devicePath + '\Device Parameters\Ndis'
    $ndisVersion = (Get-ItemProperty -Path $ndisPath -ErrorAction SilentlyContinue).NdisVersion
  }

  $signal = ($name + ' ' + $serviceName + ' ' + $driverFile + ' ' + $driverDisplayName + ' ' + $dependencies).ToLower()

  if (
    $dependencies -match 'netadaptercx' -or
    $signal -match 'netadaptercx|ndiscx' -or
    $serviceName -match '^rtcx|^e2f|^rtwlanex'
  ) {
    $driverModel = 'NetAdapterCx'
  } elseif ($ndisVersion) {
    $driverModel = 'NDIS ' + $ndisVersion
  }

  if ($driverFile) {
    $name + ' [' + $driverModel + '; driver: ' + $driverFile + ']'
  } else {
    $name + ' [' + $driverModel + ']'
  }
}
''';

    final network = await _processRunner.run('powershell', <String>[
      '-NoProfile',
      '-Command',
      networkScript,
    ]);

    if (network.success) {
      networkAdapters.addAll(
        network.stdout
            .split(RegExp(r'\r?\n'))
            .map((entry) => entry.trim())
            .where((entry) => entry.isNotEmpty),
      );
    }

    if (networkAdapters.isEmpty) {
      final fallbackNetwork = await _processRunner.run('powershell', <String>[
        '-NoProfile',
        '-Command',
        r"Get-NetAdapter | Where-Object { $_.Status -eq 'Up' } | Select-Object -ExpandProperty InterfaceDescription",
      ]);

      if (fallbackNetwork.success) {
        networkAdapters.addAll(
          fallbackNetwork.stdout
              .split(RegExp(r'\r?\n'))
              .map((entry) => entry.trim())
              .where((entry) => entry.isNotEmpty),
        );
      }
    }

    final audio = await _processRunner.run('powershell', <String>[
      '-NoProfile',
      '-Command',
      r"Get-CimInstance Win32_SoundDevice | Select-Object -ExpandProperty Name",
    ]);

    if (audio.success) {
      audioDevices.addAll(
        audio.stdout
            .split(RegExp(r'\r?\n'))
            .map((entry) => entry.trim())
            .where((entry) => entry.isNotEmpty),
      );
    }

    return HardwareProfile(
      cpuName: cpuName,
      cpuVendor: cpuVendor,
      gpuNames: gpuNames,
      gpuVendors: gpuVendors,
      ramInstalledBytes: ramInstalledBytes,
      networkAdapters: networkAdapters,
      audioDevices: audioDevices,
    );
  }
}
