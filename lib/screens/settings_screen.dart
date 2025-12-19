import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:word_map_app/l10n/app_localizations.dart';
import 'package:word_map_app/models/app_language.dart';
import 'package:word_map_app/services/app_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showWordLanguagesPicker(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final appState = context.read<AppState>();
    final messenger = ScaffoldMessenger.of(context);
    final selected = List<AppLanguage>.of(appState.wordLanguages);

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            void setSelected(List<AppLanguage> next) {
              selected
                ..clear()
                ..addAll(next);
              setSheetState(() {});
              appState.setWordLanguages(next);
            }

            Widget option(AppLanguage language) {
              final isSelected = selected.contains(language);
              final isDisabled = !isSelected && selected.length >= 2;
              return ListTile(
                leading: const Icon(LucideIcons.globe),
                title: Text(language.nativeName),
                trailing: isSelected
                    ? Icon(LucideIcons.check, color: theme.colorScheme.primary)
                    : null,
                enabled: !isDisabled,
                onTap: isDisabled
                    ? null
                    : () {
                        if (isSelected) {
                          if (selected.length == 1) {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(loc.settingsWordLanguagesMinOne),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                            return;
                          }
                          setSelected(
                              selected.where((l) => l != language).toList());
                          return;
                        }
                        if (selected.length >= 2) {
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(loc.settingsWordLanguagesMaxTwo),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                          return;
                        }
                        setSelected([...selected, language]);
                      },
              );
            }

            final subtitle = selected.map((l) => l.nativeName).join(' + ');

            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 6),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        loc.settingsSelectWordLanguagesTitle,
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 12),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        '${loc.settingsSelectWordLanguagesHint} • $subtitle',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ),
                  option(AppLanguage.en),
                  option(AppLanguage.fa),
                  option(AppLanguage.ps),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showLanguagePicker(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final appState = context.read<AppState>();
    final currentLanguage = appState.appLanguage;

    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                loc.settingsSelectLanguageTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            ListTile(
              leading: const Icon(LucideIcons.globe),
              title: Text(AppLanguage.en.nativeName),
              trailing: currentLanguage == AppLanguage.en
                  ? Icon(LucideIcons.check, color: Theme.of(context).colorScheme.primary)
                  : null,
              onTap: () {
                appState.setLanguage(AppLanguage.en);
                Navigator.of(ctx).pop();
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.globe),
              title: Text(AppLanguage.fa.nativeName),
              trailing: currentLanguage == AppLanguage.fa
                  ? Icon(LucideIcons.check, color: Theme.of(context).colorScheme.primary)
                  : null,
              onTap: () {
                appState.setLanguage(AppLanguage.fa);
                Navigator.of(ctx).pop();
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.globe),
              title: Text(AppLanguage.ps.nativeName),
              trailing: currentLanguage == AppLanguage.ps
                  ? Icon(LucideIcons.check, color: Theme.of(context).colorScheme.primary)
                  : null,
              onTap: () {
                appState.setLanguage(AppLanguage.ps);
                Navigator.of(ctx).pop();
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final appState = context.watch<AppState>();
    final appLanguageLabel = appState.appLanguage.nativeName;
    final wordLanguagesLabel =
        appState.wordLanguages.map((l) => l.nativeName).join(' + ');

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(top: 16),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                loc.settingsTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(loc.settingsAppLanguageTitle),
              leading: const Icon(LucideIcons.globe),
              subtitle: Text(appLanguageLabel),
              onTap: () => _showLanguagePicker(context),
            ),
            ListTile(
              title: Text(loc.settingsWordLanguagesTitle),
              leading: const Icon(LucideIcons.languages),
              subtitle: Text(wordLanguagesLabel),
              onTap: () => _showWordLanguagesPicker(context),
            ),
          ],
        ),
      ),
    );
  }
}
