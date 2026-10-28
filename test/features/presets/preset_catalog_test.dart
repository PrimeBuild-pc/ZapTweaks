import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/core/operations/native_operation_catalog.dart';
import 'package:script_utility/core/operations/operation.dart';
import 'package:script_utility/core/services/process_runner.dart';
import 'package:script_utility/features/apps/application/service_inventory.dart';
import 'package:script_utility/features/apps/domain/appx_candidate_policy.dart';
import 'package:script_utility/features/apps/domain/service_safety_policy.dart';
import 'package:script_utility/features/presets/application/preset_preview.dart';
import 'package:script_utility/features/presets/application/startup_inventory.dart';
import 'package:script_utility/features/presets/domain/preset_catalog.dart';
import 'package:script_utility/platform/windows/registry_value_store.dart';

class _NoRegistry implements RegistryValueStore {
  @override
  Future<RawRegistryValue?> read(
    String path,
    String name, {
    RegistryView view = RegistryView.registry64,
  }) async => null;
  @override
  Future<void> write(
    String path,
    String name,
    RawRegistryValue value, {
    RegistryView view = RegistryView.registry64,
  }) async {}
  @override
  Future<void> delete(
    String path,
    String name, {
    RegistryView view = RegistryView.registry64,
  }) async {}
}

Set<String> _keys(Preset preset) => preset.items.map((i) => i.key).toSet();

void main() {
  group('catalog', () {
    test('five presets, lightest first', () {
      expect(builtInPresets.map((p) => p.id), [
        'debloat',
        'clean',
        'gaming',
        'privacy',
        'competitive',
      ]);
      expect(builtInPresets.last.attention, isTrue);
      expect(builtInPresets.take(4).any((p) => p.attention), isFalse);
    });

    test('each step builds on the lighter ones', () {
      final byId = {for (final p in builtInPresets) p.id: _keys(p)};
      expect(byId['clean']!.containsAll(byId['debloat']!), isTrue);
      expect(byId['gaming']!.containsAll(byId['clean']!), isTrue);
      expect(byId['privacy']!.containsAll(byId['clean']!), isTrue);
      expect(byId['competitive']!.containsAll(byId['gaming']!), isTrue);
      expect(byId['competitive']!.containsAll(byId['privacy']!), isTrue);
    });

    test('every item points to something ZapTweaks can do or show', () {
      final operations = {
        for (final operation in createNativeOperationCatalog(
          _NoRegistry(),
          ProcessRunner(mode: ProcessExecutionMode.dryRun),
        ))
          operation.id,
      };
      for (final item in builtInPresets.expand((p) => p.items)) {
        switch (item) {
          case AppPresetItem(:final packageName):
            expect(
              appxCandidatePolicy[packageName]?.removable,
              isTrue,
              reason: packageName,
            );
          case ServicePresetItem(:final name, :final startType):
            expect(changeableCuratedServices, contains(name));
            expect(const <int>{3, 4}, contains(startType));
          case TweakPresetItem(:final operationId):
            expect(operations, contains(operationId));
          case StartupPresetItem(:final rule):
            expect(rule.exeNames.isNotEmpty || rule.names.isNotEmpty, isTrue);
          case ManualPresetItem(:final step):
            expect(step.author, isNotEmpty);
            expect(step.links.every((l) => l.startsWith('https://')), isTrue);
        }
      }
    });

    test('admin split matches the real operation privileges', () {
      final catalog = {
        for (final operation in createNativeOperationCatalog(
          _NoRegistry(),
          ProcessRunner(mode: ProcessExecutionMode.dryRun),
        ))
          operation.id: operation.privilege,
      };
      final used = <String>{
        'app.appx.remove_current_user',
        'service.start.configure',
        'startup.entry.configure',
        'startup.entry.configure_user',
        for (final item in builtInPresets.expand((p) => p.items))
          if (item is TweakPresetItem) item.operationId,
      };
      for (final id in used) {
        expect(
          presetAdminOperations.contains(id),
          catalog[id] == OperationPrivilege.administrator,
          reason: id,
        );
      }
    });

    test('Fr33thy steps are manual, never executed', () {
      final manual = builtInPresets.last.items
          .whereType<ManualPresetItem>()
          .map((i) => i.step);
      expect(manual.map((s) => s.id), containsAll(['driverClean', 'winsux']));
      expect(manual.where((s) => s.author.contains('Fr33thy')), hasLength(2));
    });
  });

  group('startup rules', () {
    test('match the executable or the value name', () {
      final spotify = startupRules['spotify']!;
      expect(
        spotify.matches(
          'Spotify',
          r'"C:\Users\Me\AppData\Roaming\Spotify\Spotify.exe" --autostart',
        ),
        isTrue,
      );
      expect(
        startupRules['edgeAutoLaunch']!.matches(
          'MicrosoftEdgeAutoLaunch_0F1A',
          r'"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" --no-startup-window',
        ),
        isTrue,
      );
      expect(
        startupRules['discord']!.matches(
          'Discord',
          r'C:\Users\Me\AppData\Local\Discord\Update.exe --processStart Discord.exe',
        ),
        isTrue,
      );
      expect(spotify.matches('SecurityHealth', r'C:\Windows\x.exe'), isFalse);
    });

    test('parses the startup inventory', () {
      final entries = parseStartupInventory(
        '[{"Location":"run","Machine":false,"Name":"Spotify","Command":"x","Enabled":true},'
        '{"Location":"nope","Machine":false,"Name":"x","Command":"","Enabled":true}]',
      );
      expect(entries.single.name, 'Spotify');
      expect(entries.single.machine, isFalse);
    });
  });

  group('preview', () {
    final facts = PresetFacts(
      installedAppx: const {'Microsoft.BingNews'},
      services: <String, ServiceEntry>{
        'diagtrack': const ServiceEntry(
          name: 'DiagTrack',
          displayName: 'Connected User Experiences and Telemetry',
          description: null,
          startType: 2,
          delayed: false,
          running: true,
          path: null,
          company: null,
        ),
        'xblauthmanager': const ServiceEntry(
          name: 'XblAuthManager',
          displayName: 'Xbox Live Auth Manager',
          description: null,
          startType: 3,
          delayed: false,
          running: false,
          path: null,
          company: null,
          dependents: 1,
        ),
        'wersvc': const ServiceEntry(
          name: 'WerSvc',
          displayName: 'Windows Error Reporting Service',
          description: null,
          startType: 4,
          delayed: false,
          running: false,
          path: null,
          company: null,
        ),
      },
      startup: const <StartupEntry>[
        (
          location: 'run',
          machine: false,
          name: 'Spotify',
          command: r'C:\S\Spotify.exe',
          enabled: true,
        ),
        (
          location: 'run',
          machine: true,
          name: 'Spotify',
          command: r'C:\S\Spotify.exe',
          enabled: true,
        ),
      ],
      tweaks: const <String, ({SupportResult support, OperationState before})>{
        'power_throttling_off': (
          support: SupportResult.supported(),
          before: OperationState(OperationStateKind.absent),
        ),
        'ui_taskbar_end_task': (
          support: SupportResult.supported(),
          before: OperationState(OperationStateKind.configured, value: 1),
        ),
      },
    );
    final gaming = builtInPresets.firstWhere((p) => p.id == 'gaming');
    final lines = buildPresetPreview(gaming, facts);
    PreviewLine line(String key) => lines.firstWhere((l) => l.item.key == key);

    test('installed app is removed for the current user', () {
      final news = line('app:Microsoft.BingNews');
      expect(news.status, PreviewStatus.apply);
      expect(news.requests.single.operationId, 'app.appx.remove_current_user');
      expect(line('app:Microsoft.BingWeather').reason, SkipReason.notInstalled);
    });

    test('a service other services depend on is skipped, not disabled', () {
      final competitive = buildPresetPreview(builtInPresets.last, facts);
      final xbl = competitive.firstWhere(
        (l) => l.item.key == 'service:XblAuthManager',
      );
      expect(xbl.status, PreviewStatus.skipped);
      expect(xbl.reason, SkipReason.hasDependents);
      expect(xbl.requests, isEmpty);
    });

    test('services: change, already done, missing', () {
      final diag = line('service:DiagTrack');
      expect(diag.status, PreviewStatus.apply);
      expect(diag.requests.single.desiredValue, {
        'startType': 4,
        'delayedAutoStart': false,
      });
      expect(line('service:WerSvc').status, PreviewStatus.done);
      expect(line('service:RetailDemo').reason, SkipReason.notFound);
    });

    test('startup: one request per matching entry, user and machine apart', () {
      final spotify = lines.where((l) => l.item.key == 'startup:spotify');
      final ops = spotify.expand((l) => l.requests).map((r) => r.operationId);
      expect(
        ops,
        containsAll(<String>[
          'startup.entry.configure_user',
          'startup.entry.configure',
        ]),
      );
    });

    test('tweaks: already set is done, unknown is skipped', () {
      expect(line('tweak:ui_taskbar_end_task').status, PreviewStatus.done);
      expect(line('tweak:power_throttling_off').status, PreviewStatus.apply);
    });

    test('plans split by privilege; apps apart so settings can be undone', () {
      final plans = presetPlans(lines);
      expect(
        plans.admin.map((r) => r.operationId),
        contains('service.start.configure'),
      );
      expect(
        plans.userSettings.map((r) => r.operationId),
        contains('startup.entry.configure_user'),
      );
      expect(plans.userApps.single.target, 'Microsoft.BingNews');
      for (final request in plans.admin) {
        expect(request.operationId, isNot('app.appx.remove_current_user'));
      }
    });

    test('manual steps are listed but never planned', () {
      final competitive = buildPresetPreview(builtInPresets.last, facts);
      final manual = competitive.where((l) => l.status == PreviewStatus.manual);
      expect(manual, isNotEmpty);
      expect(manual.expand((l) => l.requests), isEmpty);
    });
  });
}
