import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:word_map_app/l10n/app_localizations.dart';
import 'package:word_map_app/services/app_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showLanguagePicker(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final appState = context.read<AppState>();

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
              title: Text(loc.settingsLanguageEnglish),
              trailing: appState.appLocale?.languageCode == 'en'
                  ? Icon(LucideIcons.check, color: Theme.of(context).colorScheme.primary)
                  : null,
              onTap: () {
                appState.changeLocale(const Locale('en'));
                Navigator.of(ctx).pop();
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.languages),
              title: Text(loc.settingsLanguageFarsi),
              trailing: appState.appLocale?.languageCode == 'fa'
                  ? Icon(LucideIcons.check, color: Theme.of(context).colorScheme.primary)
                  : null,
              onTap: () {
                appState.changeLocale(const Locale('fa'));
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
              title: Text(loc.settingsChangeLanguage),
              leading: const Icon(LucideIcons.globe),
              onTap: () => _showLanguagePicker(context),
            ),
          ],
        ),
      ),
    );
  }
}
