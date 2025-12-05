import 'package:flutter/material.dart';
import 'package:word_map_app/l10n/app_localizations.dart';

class LoginPlaceholderScreen extends StatelessWidget {
  const LoginPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: cs.onSurface),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    loc.loginComingSoonTitle,
                    style: textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    loc.loginComingSoonSubtitle,
                    style: textTheme.bodyMedium,
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed('/levels');
                      },
                      child: Text(loc.loginComingSoonGoToMap),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
