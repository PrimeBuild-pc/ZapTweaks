import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/features/apps/application/leftover_scanner.dart';

const _local = r'C:\Users\Me\AppData\Local';
const _roaming = r'C:\Users\Me\AppData\Roaming';
const _data = r'C:\ProgramData';

LeftoverQuery _query({
  String name = 'Contoso Paint 3.2 (x64)',
  String? publisher = 'Contoso Ltd.',
  String? location = r'C:\Program Files\Contoso\Paint',
  String key = r'HKLM\64\ContosoPaint',
}) => LeftoverQuery(
  name: name,
  publisher: publisher,
  installLocation: location,
  uninstallKey: key,
);

List<Leftover> _classify(LeftoverQuery query, LeftoverFacts facts) =>
    classifyLeftovers(query, facts);

Leftover _find(List<Leftover> items, String path) =>
    items.firstWhere((item) => item.path == path);

void main() {
  test('names: version and architecture are dropped', () {
    expect(_query().tokens, contains('contosopaint'));
    expect(_query().tokens, contains('paint'));
    expect(_query(name: '7-Zip 23.01 (x64)').tokens, contains('7zip'));
  });

  test('a name that differs only by punctuation is Medium, not Good', () {
    final items = _classify(
      _query(),
      const LeftoverFacts(
        folders: [
          (root: _local, path: '$_local\\Contoso-Paint', depth: 1),
          (root: _roaming, path: '$_roaming\\ContosoPaint', depth: 1),
        ],
      ),
    );
    expect(
      _find(items, '$_local\\Contoso-Paint').confidence,
      LeftoverConfidence.medium,
      reason: 'could be another program: never preselected',
    );
    expect(
      _find(items, '$_roaming\\ContosoPaint').confidence,
      LeftoverConfidence.good,
      reason: 'only spaces and case differ',
    );
  });

  test('install folder still on disk is Good', () {
    final items = _classify(
      _query(),
      const LeftoverFacts(existingFolders: {r'C:\Program Files\Contoso\Paint'}),
    );
    expect(
      _find(items, r'C:\Program Files\Contoso\Paint').confidence,
      LeftoverConfidence.good,
    );
    expect(items.single.machine, isTrue);
  });

  test(
    'AppData folders: exact app name Good, publisher\\app Good, publisher alone Low',
    () {
      final items = _classify(
        _query(),
        const LeftoverFacts(
          folders: [
            (root: _local, path: '$_local\\Contoso Paint', depth: 1),
            (root: _roaming, path: '$_roaming\\Contoso', depth: 1),
            (root: _roaming, path: '$_roaming\\Contoso\\Paint', depth: 2),
            (root: _roaming, path: '$_roaming\\Contoso\\Other Tool', depth: 2),
            (root: _data, path: '$_data\\Contoso', depth: 1),
            (root: _local, path: '$_local\\PaintShop', depth: 1),
            (root: _local, path: '$_local\\Microsoft', depth: 1),
          ],
        ),
      );
      expect(
        _find(items, '$_local\\Contoso Paint').confidence,
        LeftoverConfidence.good,
      );
      expect(
        _find(items, '$_roaming\\Contoso\\Paint').confidence,
        LeftoverConfidence.good,
      );
      expect(
        _find(items, '$_roaming\\Contoso').confidence,
        LeftoverConfidence.low,
        reason: 'holds Other Tool too',
      );
      expect(
        _find(items, '$_data\\Contoso').confidence,
        LeftoverConfidence.medium,
        reason: 'publisher folder with nothing else listed',
      );
      expect(_find(items, '$_data\\Contoso').machine, isTrue);
      expect(
        items.where((i) => i.path.endsWith('PaintShop')),
        isEmpty,
        reason: 'a different product that only shares a word',
      );
      expect(items.where((i) => i.path.endsWith('Microsoft')), isEmpty);
    },
  );

  test('registry Software keys follow the same rule', () {
    final items = _classify(
      _query(),
      const LeftoverFacts(
        registryKeys: [
          r'HKCU\Software\Contoso',
          r'HKCU\Software\Contoso\Paint',
          r'HKLM\Software\Contoso Paint',
          r'HKLM\Software\WOW6432Node\Contoso\Paint',
          r'HKLM\Software\Microsoft',
        ],
      ),
    );
    expect(
      _find(items, r'HKCU\Software\Contoso\Paint').confidence,
      LeftoverConfidence.good,
    );
    expect(
      _find(items, r'HKLM\Software\Contoso Paint').confidence,
      LeftoverConfidence.good,
    );
    expect(
      _find(items, r'HKLM\Software\WOW6432Node\Contoso\Paint').confidence,
      LeftoverConfidence.good,
    );
    expect(
      _find(items, r'HKCU\Software\Contoso').confidence,
      LeftoverConfidence.medium,
    );
    expect(_find(items, r'HKCU\Software\Contoso\Paint').machine, isFalse);
    expect(items.where((i) => i.path.endsWith('Microsoft')), isEmpty);
  });

  test('an Uninstall key that survived the uninstaller is Medium', () {
    final items = _classify(
      _query(),
      const LeftoverFacts(uninstallKeyPresent: true),
    );
    expect(items.single.kind, LeftoverKind.registryKey);
    expect(
      items.single.path,
      r'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\ContosoPaint',
    );
    expect(items.single.confidence, LeftoverConfidence.medium);
  });

  test(
    'shortcuts, Run entries, tasks and firewall rules pointing into the folder are Good',
    () {
      final items = _classify(
        _query(),
        const LeftoverFacts(
          shortcuts: [
            (
              path:
                  r'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Contoso Paint.lnk',
              target: r'C:\Program Files\Contoso\Paint\paint.exe',
            ),
            (
              path: r'C:\Users\Me\Desktop\Notes.lnk',
              target: r'C:\Windows\notepad.exe',
            ),
            (path: r'C:\Users\Me\Desktop\Contoso Paint.lnk', target: ''),
          ],
          runEntries: [
            (
              key: r'HKCU\Software\Microsoft\Windows\CurrentVersion\Run',
              name: 'PaintTray',
              command: r'"C:\Program Files\Contoso\Paint\tray.exe" /min',
            ),
            (
              key: r'HKCU\Software\Microsoft\Windows\CurrentVersion\Run',
              name: 'Other',
              command: r'C:\Other\o.exe',
            ),
          ],
          tasks: [
            (
              path: r'\Contoso\PaintUpdate',
              execute: r'C:\Program Files\Contoso\Paint\update.exe',
            ),
            (
              path: r'\Microsoft\Windows\Defrag\ScheduledDefrag',
              execute: r'%windir%\system32\defrag.exe',
            ),
          ],
          firewallRules: [
            (
              name: '{1}',
              displayName: 'Contoso Paint',
              program: r'C:\Program Files\Contoso\Paint\paint.exe',
            ),
            (name: '{2}', displayName: 'Core Networking', program: 'System'),
          ],
        ),
      );
      final good = {
        for (final item in items)
          if (item.confidence == LeftoverConfidence.good) item.path,
      };
      expect(good, {
        r'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Contoso Paint.lnk',
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\Run|PaintTray',
        r'\Contoso\PaintUpdate',
        '{1}',
      });
      expect(
        _find(items, r'C:\Users\Me\Desktop\Contoso Paint.lnk').confidence,
        LeftoverConfidence.medium,
        reason: 'broken shortcut with the app name',
      );
      expect(items.where((i) => i.path.contains('Notes')), isEmpty);
      expect(items.where((i) => i.path.contains('Defrag')), isEmpty);
      expect(items.where((i) => i.path == '{2}'), isEmpty);
    },
  );

  test('only Good leftovers start selected', () {
    final items = _classify(
      _query(),
      const LeftoverFacts(
        existingFolders: {r'C:\Program Files\Contoso\Paint'},
        uninstallKeyPresent: true,
      ),
    );
    expect(
      {for (final i in items) i.confidence: i.preselected},
      {LeftoverConfidence.good: true, LeftoverConfidence.medium: false},
    );
  });

  test('a too generic name never matches anything', () {
    final items = _classify(
      _query(name: 'Tools', publisher: null, location: null),
      const LeftoverFacts(
        folders: [(root: _local, path: '$_local\\Tools', depth: 1)],
        registryKeys: [r'HKCU\Software\Tools'],
      ),
    );
    expect(items, isEmpty);
  });

  test('a shared InstallLocation never makes other programs Good', () {
    for (final shared in [
      r'C:\',
      r'C:\Program Files (x86)',
      r'C:\Program Files\Common Files',
    ]) {
      final items = _classify(
        _query(location: shared),
        LeftoverFacts(
          existingFolders: {shared},
          shortcuts: const [
            (
              path: r'C:\Users\Me\Desktop\Other.lnk',
              target: r'C:\Program Files (x86)\Other\o.exe',
            ),
          ],
          tasks: const [
            (
              path: r'\Other\Update',
              execute: r'C:\Program Files (x86)\Other\u.exe',
            ),
          ],
        ),
      );
      expect(items, isEmpty, reason: shared);
    }
  });
}
