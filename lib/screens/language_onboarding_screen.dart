import 'package:flutter/material.dart';
import 'package:word_map_app/l10n/app_localizations.dart';

class LanguageOnboardingScreen extends StatefulWidget {
  const LanguageOnboardingScreen({
    super.key,
    required this.currentLocale,
    required this.onLocaleChanged,
    required this.onFinished,
  });

  final Locale currentLocale;
  final ValueChanged<Locale> onLocaleChanged;
  final VoidCallback onFinished;

  @override
  State<LanguageOnboardingScreen> createState() =>
      _LanguageOnboardingScreenState();
}

class _LanguageOnboardingScreenState extends State<LanguageOnboardingScreen> {
  final List<String> _nativeLanguageCodes = const [
    'en',
    'de',
    'fa',
    'ar',
    'es',
    'fr',
    'tr',
  ];

  String? _selectedNativeLanguage;
  final String _learningLanguageCode = 'de';

  String _languageLabel(BuildContext context, String code) {
    final loc = AppLocalizations.of(context)!;
    switch (code) {
      case 'en':
        return loc.languageEnglish;
      case 'de':
        return loc.languageGerman;
      case 'fa':
        return loc.languageFarsi;
      case 'ar':
        return loc.languageArabic;
      case 'es':
        return loc.languageSpanish;
      case 'fr':
        return loc.languageFrench;
      case 'tr':
        return loc.languageTurkish;
      default:
        return code;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final cs = theme.colorScheme;
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: cs.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: 24, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    loc.onboardingTitle,
                    textAlign: TextAlign.center,
                    style: textTheme.headlineLarge
                        ?.copyWith(color: cs.onSurface),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    loc.onboardingSubtitle,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyLarge
                        ?.copyWith(color: cs.onSurface.withOpacity(0.7)),
                  ),
                  const SizedBox(height: 40),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: _nativeLanguageCodes.map((code) {
                      final selected = _selectedNativeLanguage == code ||
                          widget.currentLocale.languageCode == code;
                      return _LanguagePill(
                        label: _languageLabel(context, code),
                        selected: selected,
                        onTap: () async {
                          setState(() => _selectedNativeLanguage = code);
                          widget.onLocaleChanged(Locale(code));
                          await Future.delayed(const Duration(milliseconds: 120));
                          widget.onFinished();
                          if (context.mounted) {
                            Navigator.of(context)
                                .pushReplacementNamed('/sign-in-or-skip');
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: _LanguagePill(
                      label: _languageLabel(context, _learningLanguageCode),
                      selected: true,
                      dense: true,
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    loc.onboardingChangeLater,
                    style: textTheme.bodyMedium
                        ?.copyWith(color: cs.onSurface.withOpacity(0.6)),
                    textAlign: TextAlign.center,
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

class _LanguagePill extends StatelessWidget {
  const _LanguagePill({
    required this.label,
    required this.selected,
    required this.onTap,
    this.dense = false,
  });

  final String label;
  final bool selected;
  final bool dense;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedScale(
      scale: selected ? 1.03 : 1.0,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: dense ? 18 : 22,
            vertical: dense ? 12 : 14,
          ),
          decoration: BoxDecoration(
            color: selected
                ? cs.primary
                : cs.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? cs.primary : cs.outline,
              width: 1.2,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: cs.primary.withOpacity(0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    )
                  ]
                : null,
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: selected ? cs.onPrimary : cs.onSurface,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.subtitle});

  final String label;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: textTheme.titleMedium?.copyWith(
            color: cs.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: textTheme.bodyMedium
              ?.copyWith(color: cs.onSurface.withOpacity(0.6)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
