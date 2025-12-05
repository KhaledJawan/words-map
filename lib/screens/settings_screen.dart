import 'package:flutter/material.dart';
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
              leading: const Icon(Icons.language),
              title: Text(loc.settingsLanguageEnglish),
              trailing: appState.appLocale?.languageCode == 'en'
                  ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                  : null,
              onTap: () {
                appState.changeLocale(const Locale('en'));
                Navigator.of(ctx).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.translate),
              title: Text(loc.settingsLanguageFarsi),
              trailing: appState.appLocale?.languageCode == 'fa'
                  ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
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
      appBar: AppBar(
        title: Text(loc.settingsTitle),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text(loc.settingsChangeLanguage),
            leading: const Icon(Icons.language),
            onTap: () => _showLanguagePicker(context),
          ),
        ],
      ),
    );
  }
}