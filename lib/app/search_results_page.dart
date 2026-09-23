import 'package:fluent_ui/fluent_ui.dart';

import '../core/models/tweak_descriptor.dart';
import '../core/search/search_matcher.dart';
import '../features/apps/application/app_store_catalog.dart';
import '../features/apps/domain/store_app.dart';
import '../features/tweaks/application/tweak_controller.dart';
import '../l10n/app_localizations.dart';

class SearchResultsPage extends StatefulWidget {
  const SearchResultsPage({
    required this.controller,
    required this.query,
    super.key,
  });

  final TweakController controller;
  final String query;

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  late final Future<AppStoreCatalog> _apps = AppStoreCatalog.load();

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final sections =
        <_SearchDestination>[
              _SearchDestination(
                strings.guidedSetup,
                'Guided Setup',
                0,
                'wizard setup configurazione',
              ),
              _SearchDestination(
                strings.appStore,
                'Apps',
                0,
                'software programs winget applicazioni',
              ),
              _SearchDestination(
                strings.optionalFeatures,
                'Apps',
                2,
                'windows features funzionalita',
              ),
              _SearchDestination(
                strings.startupApps,
                'Apps',
                3,
                'avvio automatico task manager',
              ),
              _SearchDestination(
                strings.driverInventory,
                'Drivers',
                0,
                'driver store dispositivi',
              ),
              _SearchDestination(
                strings.driverTools,
                'Drivers',
                1,
                'assisted flows windows update device manager gestione dispositivi aggiornamenti driver',
              ),
              _SearchDestination(
                strings.powerPlans,
                'Gaming & Performance',
                0,
                'power settings explorer powrprof piani energia ac dc',
              ),
              _SearchDestination(
                strings.interruptConfiguration,
                'Gaming & Performance',
                1,
                'msi utility v3 message signaled interrupts affinity tool affinita interrupt',
              ),
              _SearchDestination(
                strings.recovery,
                'Diagnostics & Recovery',
                0,
                'dism sfc restore ripristino',
              ),
              _SearchDestination(
                strings.hardwareMonitor,
                'Diagnostics & Recovery',
                1,
                'gpu memory temperature sensori',
              ),
              _SearchDestination(
                strings.dpcLatencyAnalyzer,
                'Diagnostics & Recovery',
                2,
                'latencymon wtools etw dpc isr trace driver latency latenza',
              ),
              _SearchDestination(
                strings.diagnosticTools,
                'Diagnostics & Recovery',
                3,
                'pulizia cleanup strumenti diagnostica',
              ),
            ]
            .where(
              (item) => SearchMatcher.matches(
                widget.query,
                '${item.title} ${item.keywords}',
              ),
            )
            .toList();
    final tweaks = widget.controller.searchTweaks(
      widget.query,
      includeExpert: true,
    );

    return FutureBuilder<AppStoreCatalog>(
      future: _apps,
      builder: (context, snapshot) {
        final apps = (snapshot.data?.apps ?? const <StoreApp>[])
            .where(
              (app) => SearchMatcher.matches(
                widget.query,
                '${app.name} ${app.id} ${app.wingetId ?? ''} ${app.category} ${app.author}',
              ),
            )
            .take(60)
            .toList(growable: false);
        final empty = sections.isEmpty && tweaks.isEmpty && apps.isEmpty;
        return ListView(
          padding: const EdgeInsets.all(24),
          children: <Widget>[
            Text(
              strings.searchResults,
              style: FluentTheme.of(context).typography.title,
            ),
            const SizedBox(height: 16),
            if (empty && snapshot.connectionState != ConnectionState.waiting)
              Text(strings.noSearchResults)
            else ...<Widget>[
              if (sections.isNotEmpty) ...<Widget>[
                _heading(context, strings.searchSections),
                ...sections.map(
                  (item) => _resultCard(
                    context,
                    title: item.title,
                    subtitle: item.category,
                    onPressed: () => widget.controller.navigateTo(
                      item.category,
                      tab: item.tab,
                    ),
                  ),
                ),
              ],
              if (apps.isNotEmpty) ...<Widget>[
                _heading(context, strings.searchApps),
                ...apps.map(
                  (app) => _resultCard(
                    context,
                    title: app.name,
                    subtitle: '${app.category} · ${app.attribution}',
                    onPressed: () => widget.controller.navigateTo(
                      'Apps',
                      searchTerm: app.name,
                    ),
                  ),
                ),
              ],
              if (tweaks.isNotEmpty) ...<Widget>[
                _heading(context, strings.searchCatalog),
                ...tweaks.take(80).map((item) => _tweakCard(context, item)),
              ],
            ],
          ],
        );
      },
    );
  }

  Widget _tweakCard(BuildContext context, TweakDescriptor item) {
    final strings = AppLocalizations.of(context);
    final locked =
        item.category == 'Expert' && !widget.controller.expertModeEnabled;
    return _resultCard(
      context,
      title: item.title,
      subtitle: locked
          ? '${item.category} · ${strings.searchExpertRequired}'
          : '${item.category} · ${item.collection}',
      onPressed: () => widget.controller.navigateTo(
        locked ? TweakController.settingsCategory : item.category,
        tab: item.category == 'Drivers' ? 1 : 0,
      ),
    );
  }

  Widget _heading(BuildContext context, String text) => Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 8),
    child: Text(text, style: FluentTheme.of(context).typography.bodyStrong),
  );

  Widget _resultCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required VoidCallback onPressed,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Button(
          onPressed: onPressed,
          child: Text(AppLocalizations.of(context).searchOpenResult),
        ),
      ),
    ),
  );
}

class _SearchDestination {
  const _SearchDestination(this.title, this.category, this.tab, this.keywords);
  final String title;
  final String category;
  final int tab;
  final String keywords;
}
