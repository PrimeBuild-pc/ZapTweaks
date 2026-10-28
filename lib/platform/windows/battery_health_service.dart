import 'dart:convert';
import 'dart:math' as math;

import '../../core/services/process_runner.dart';

enum BatteryHealthBand { good, fair, poor }

/// One battery as Windows reports it. Capacities are in mWh; a value that was
/// not read stays null and is shown as "not available", never as 0.
class BatteryHealth {
  const BatteryHealth({
    required this.name,
    this.designedMwh,
    this.fullChargedMwh,
    this.cycles,
    this.remainingMwh,
    this.onAcPower,
  });

  final String name;
  final int? designedMwh;
  final int? fullChargedMwh;
  final int? cycles;
  final int? remainingMwh;
  final bool? onAcPower;

  /// Full-charge capacity over design capacity, capped at 100.
  int? get healthPercent => designedMwh == null || fullChargedMwh == null
      ? null
      : math.min(100, (fullChargedMwh! / designedMwh! * 100).round());

  int? get wearPercent => healthPercent == null ? null : 100 - healthPercent!;

  int? get chargePercent => remainingMwh == null || fullChargedMwh == null
      ? null
      : math.min(100, (remainingMwh! / fullChargedMwh! * 100).round());

  /// ≥80 good, 60–79 fair, <60 poor.
  BatteryHealthBand? get band => switch (healthPercent) {
    null => null,
    >= 80 => BatteryHealthBand.good,
    >= 60 => BatteryHealthBand.fair,
    _ => BatteryHealthBand.poor,
  };
}

enum BatterySource { wmi, report, none }

class BatterySnapshot {
  const BatterySnapshot({required this.source, required this.batteries});

  final BatterySource source;
  final List<BatteryHealth> batteries;

  bool get hasBattery => batteries.isNotEmpty;
}

/// Read-only, no administrator rights. root\wmi battery classes first; when
/// they give no design capacity, `powercfg /batteryreport /xml` into a
/// randomly named temp file that is deleted right after reading.
class WindowsBatteryHealthService {
  const WindowsBatteryHealthService({required this.processRunner});

  final ProcessRunner processRunner;

  static const script = r'''
function Read-Wmi([string]$class) { try { @(Get-CimInstance -Namespace root/wmi -ClassName $class -ErrorAction Stop) } catch { @() } }
function Pos($v) { if ($null -ne $v -and [int64]$v -gt 0) { [int64]$v } else { $null } }
$static = Read-Wmi 'BatteryStaticData'; $full = Read-Wmi 'BatteryFullChargedCapacity'
$cycles = Read-Wmi 'BatteryCycleCount'; $status = Read-Wmi 'BatteryStatus'
$names = @($full + $status + $static | ForEach-Object { [string]$_.InstanceName } | Where-Object { $_ } | Select-Object -Unique)
$source = 'wmi'
$rows = @($names | ForEach-Object { $n = $_
  $s = $static | Where-Object InstanceName -EQ $n | Select-Object -First 1
  $f = $full | Where-Object InstanceName -EQ $n | Select-Object -First 1
  $c = $cycles | Where-Object InstanceName -EQ $n | Select-Object -First 1
  $b = $status | Where-Object InstanceName -EQ $n | Select-Object -First 1
  [ordered]@{ name = $n; designed = (Pos $s.DesignedCapacity); full = (Pos $f.FullChargedCapacity)
    cycles = $(if ($c) { [int64]$c.CycleCount } else { $null }); remaining = (Pos $b.RemainingCapacity)
    online = $(if ($b) { [bool]$b.PowerOnline } else { $null }) } })
if ($rows.Count -eq 0 -or @($rows | Where-Object { $null -eq $_.designed }).Count -gt 0) {
  $file = Join-Path $env:TEMP ('zt-battery-' + [guid]::NewGuid().ToString('N') + '.xml')
  try {
    & "$env:SystemRoot\System32\powercfg.exe" /batteryreport /xml /output $file *> $null
    if (Test-Path -LiteralPath $file) {
      $report = [xml](Get-Content -LiteralPath $file -Raw)
      $list = @($report.BatteryReport.Batteries.Battery)
      if ($list.Count -gt 0) {
        $source = 'report'
        $rows = @(for ($i = 0; $i -lt $list.Count; $i++) { $r = $list[$i]
          $w = if ($i -lt $rows.Count) { $rows[$i] } else { $null }
          [ordered]@{ name = $(if ($r.Id) { [string]$r.Id } else { "Battery $i" })
            designed = (Pos $r.DesignCapacity); full = (Pos $r.FullChargeCapacity)
            cycles = $(if ($r.CycleCount -ne $null -and [string]$r.CycleCount -ne '') { [int64]$r.CycleCount } else { $null })
            remaining = $(if ($w) { $w.remaining } else { $null }); online = $(if ($w) { $w.online } else { $null }) } })
      }
    }
  } catch {} finally { Remove-Item -LiteralPath $file -Force -ErrorAction SilentlyContinue }
}
if ($rows.Count -eq 0) { $source = 'none' }
[ordered]@{ source = $source; batteries = $rows } | ConvertTo-Json -Compress -Depth 4
''';

  Future<BatterySnapshot> capture() async =>
      parse(await processRunner.runPowerShellForOutput(script));

  static BatterySnapshot parse(String output) {
    final json = jsonDecode(output);
    if (json is! Map || json['batteries'] is! List) {
      throw const FormatException('Invalid battery response.');
    }
    final source = BatterySource.values.firstWhere(
      (value) => value.name == json['source'],
      orElse: () => BatterySource.none,
    );
    int? positive(Object? value) =>
        value is num && value > 0 ? value.toInt() : null;
    final batteries = <BatteryHealth>[
      for (final row in json['batteries'] as List)
        if (row is Map && row['name'] is String)
          BatteryHealth(
            name: row['name'] as String,
            designedMwh: positive(row['designed']),
            fullChargedMwh: positive(row['full']),
            // Firmware without a cycle counter reports 0: treat it as unread.
            cycles: positive(row['cycles']),
            remainingMwh: positive(row['remaining']),
            onAcPower: row['online'] is bool ? row['online'] as bool : null,
          )
        else
          throw const FormatException('Invalid battery row.'),
    ];
    return BatterySnapshot(
      source: batteries.isEmpty ? BatterySource.none : source,
      batteries: List.unmodifiable(batteries),
    );
  }
}
