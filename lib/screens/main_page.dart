// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:word_map_app/l10n/app_localizations.dart';
import 'package:word_map_app/models/vocab_word.dart';
import 'package:word_map_app/screens/words_list_init.dart';
import 'package:word_map_app/screens/words_list_screen.dart';
import 'package:word_map_app/services/app_state.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:word_map_app/features/lessons/alphabet_json/alphabet_json_lesson_models.dart';
import 'package:word_map_app/features/lessons/alphabet_json/alphabet_json_lesson_repository.dart';
import 'package:word_map_app/features/lessons/combinations_json/combinations_json_lesson_models.dart';
import 'package:word_map_app/features/lessons/combinations_json/combinations_json_lesson_repository.dart';
import 'package:word_map_app/features/lessons/lesson_completion_repository.dart';
import 'package:word_map_app/features/settings/settings_repository.dart';
import 'package:word_map_app/models/app_language.dart';
import 'package:word_map_app/screens/alphabet_json_lesson_page.dart';
import 'package:word_map_app/screens/combinations_json_lesson_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({
    super.key,
    this.initialBundle,
  });

  final WordsInitBundle? initialBundle;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late final Future<WordsInitBundle> _bundleFuture;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.initialBundle != null) {
      _bundleFuture = Future.value(widget.initialBundle!);
    } else {
      final appState = Provider.of<AppState>(context, listen: false);
      _bundleFuture = loadWordsInit(appState, context);
    }
  }

  void _selectTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return FutureBuilder<WordsInitBundle>(
      future: _bundleFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text(loc.loadWordsFailed),
            ),
          );
        }
        final bundle = snapshot.data!;
        final tabs = [
          WordsHomeTab(
            allWords: bundle.allWords,
            initialProgress: bundle.progress,
            initialLevel: bundle.lastLevel,
            initialScope: bundle.lastScope,
            initialCategoryTag: bundle.lastCategoryTag,
            levels: bundle.levels,
            repo: bundle.repo,
          ),
          LessonsTab(allWords: bundle.allWords),
          const ProfileTab(),
        ];
        return Scaffold(
          body: SafeArea(
            child: IndexedStack(
              index: _currentIndex,
              children: tabs,
            ),
          ),
          bottomNavigationBar: Directionality(
            textDirection: TextDirection.ltr,
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: _selectTab,
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(
                    LucideIcons.home,
                  ),
                  label: loc.tabHome,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(
                    LucideIcons.bookOpenCheck,
                  ),
                  label: loc.tabLessons,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(
                    LucideIcons.userCog,
                  ),
                  label: loc.tabProfile,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class LessonsTab extends StatefulWidget {
  const LessonsTab({
    super.key,
    required this.allWords,
  });

  final List<VocabWord> allWords;

  @override
  State<LessonsTab> createState() => _LessonsTabState();
}

class _LessonsTabData {
  const _LessonsTabData({
    required this.alphabet,
    required this.combinations,
  });

  final AlphabetJsonLesson alphabet;
  final CombinationsJsonLesson combinations;
}

class _LessonsTabState extends State<LessonsTab> {
  final Set<String> _completedLessonIds = {};
  bool _isLoading = true;
  final LessonCompletionRepository _completionRepo =
      LessonCompletionRepository();
  late final Future<_LessonsTabData> _lessonsFuture;

  static const String _alphabetLessonAssetPath =
      'assets/lessons/lesson_alphabet.json';
  static const String _combinationsLessonAssetPath =
      'assets/lessons/lesson_combinations.json';

  @override
  void initState() {
    super.initState();
    _lessonsFuture = _loadLessons();
    _loadCompletedLessons();
  }

  Future<_LessonsTabData> _loadLessons() async {
    final results = await Future.wait([
      AssetAlphabetJsonLessonRepository(
        assetPath: _alphabetLessonAssetPath,
      ).loadLesson(),
      AssetCombinationsJsonLessonRepository(
        assetPath: _combinationsLessonAssetPath,
      ).loadLesson(),
    ]);
    final alphabet = results[0] as AlphabetJsonLesson;
    final combinations = results[1] as CombinationsJsonLesson;
    return _LessonsTabData(alphabet: alphabet, combinations: combinations);
  }

  Future<void> _loadCompletedLessons() async {
    final completed = await _completionRepo.loadCompletedLessons();
    if (!mounted) return;
    setState(() {
      _completedLessonIds
        ..clear()
        ..addAll(completed);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final loc = AppLocalizations.of(context)!;
    final appLanguage = context.watch<AppState>().appLanguage;
    return FutureBuilder<_LessonsTabData>(
      future: _lessonsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text(loc.lessonsStatusComingSoon));
        }
        final data = snapshot.data;
        if (data == null) {
          return Center(child: Text(loc.lessonsStatusComingSoon));
        }

        final alphabet = data.alphabet;
        final combinations = data.combinations;
        final alphabetCompleted = _completedLessonIds.contains(alphabet.id);
        final combinationsCompleted =
            _completedLessonIds.contains(combinations.id);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              loc.lessonsTitle,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _LessonCard(
              badge: const Icon(Icons.abc),
              title: _localizedAlphabetTitle(alphabet, appLanguage),
              subtitle: _buildAlphabetSubtitle(alphabet, appLanguage),
              gradientColors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.78),
              ],
              isCompleted: alphabetCompleted,
              onTap: () async {
                final result = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => AlphabetJsonLessonPage(
                      assetPath: _alphabetLessonAssetPath,
                      allWords: widget.allWords,
                      initialLesson: alphabet,
                    ),
                  ),
                );
                if (result == true && _completedLessonIds.add(alphabet.id)) {
                  setState(() {});
                }
              },
            ),
            const SizedBox(height: 14),
            _LessonCard(
              badge: const Icon(Icons.link),
              title: _localizedCombinationsTitle(combinations, appLanguage),
              subtitle: _buildCombinationsSubtitle(combinations, appLanguage),
              gradientColors: [
                Theme.of(context).colorScheme.secondary,
                Theme.of(context).colorScheme.secondary.withValues(alpha: 0.82),
              ],
              isCompleted: combinationsCompleted,
              onTap: () async {
                final result = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => CombinationsJsonLessonPage(
                      assetPath: _combinationsLessonAssetPath,
                      allWords: widget.allWords,
                      initialLesson: combinations,
                    ),
                  ),
                );
                if (result == true &&
                    _completedLessonIds.add(combinations.id)) {
                  setState(() {});
                }
              },
            ),
          ],
        );
      },
    );
  }

  String _localizedAlphabetTitle(AlphabetJsonLesson lesson, AppLanguage lang) {
    switch (lang) {
      case AppLanguage.fa:
        return lesson.titleFa.isNotEmpty
            ? lesson.titleFa
            : (lesson.titleEn.isNotEmpty ? lesson.titleEn : lesson.titleDe);
      case AppLanguage.ps:
        return lesson.titlePs.isNotEmpty
            ? lesson.titlePs
            : (lesson.titleFa.isNotEmpty
                ? lesson.titleFa
                : (lesson.titleEn.isNotEmpty ? lesson.titleEn : lesson.titleDe));
      case AppLanguage.en:
        return lesson.titleEn.isNotEmpty
            ? lesson.titleEn
            : (lesson.titleFa.isNotEmpty ? lesson.titleFa : lesson.titleDe);
    }
  }

  String _localizedCombinationsTitle(CombinationsJsonLesson lesson, AppLanguage lang) {
    switch (lang) {
      case AppLanguage.fa:
        return lesson.titleFa.isNotEmpty
            ? lesson.titleFa
            : (lesson.titleEn.isNotEmpty ? lesson.titleEn : lesson.titleDe);
      case AppLanguage.ps:
        return lesson.titlePs.isNotEmpty
            ? lesson.titlePs
            : (lesson.titleFa.isNotEmpty
                ? lesson.titleFa
                : (lesson.titleEn.isNotEmpty ? lesson.titleEn : lesson.titleDe));
      case AppLanguage.en:
        return lesson.titleEn.isNotEmpty
            ? lesson.titleEn
            : (lesson.titleFa.isNotEmpty ? lesson.titleFa : lesson.titleDe);
    }
  }

  String _buildAlphabetSubtitle(AlphabetJsonLesson lesson, AppLanguage lang) {
    final lettersCount = lesson.alphabet?.letters.length ?? 0;
    final level = _localizedLessonLevel(lesson, lang);
    if (lang == AppLanguage.fa) {
      final parts = <String>[];
      if (level.isNotEmpty) parts.add(level);
      if (lettersCount > 0) parts.add('$lettersCount حرف');
      return parts.isEmpty ? '' : parts.join(' • ');
    }
    if (lang == AppLanguage.ps) {
      final parts = <String>[];
      if (level.isNotEmpty) parts.add(level);
      if (lettersCount > 0) parts.add('$lettersCount توري');
      return parts.isEmpty ? '' : parts.join(' • ');
    }
    final parts = <String>[];
    if (level.isNotEmpty) parts.add(level);
    if (lettersCount > 0) parts.add('$lettersCount letters');
    return parts.isEmpty ? '' : parts.join(' • ');
  }

  String _buildCombinationsSubtitle(CombinationsJsonLesson lesson, AppLanguage lang) {
    final rulesCount = lesson.combinations.length;
    final level = _localizedLessonLevelCombinations(lesson, lang);
    if (lang == AppLanguage.fa) {
      final parts = <String>[];
      if (level.isNotEmpty) parts.add(level);
      if (rulesCount > 0) parts.add('$rulesCount ترکیب');
      return parts.isEmpty ? '' : parts.join(' • ');
    }
    if (lang == AppLanguage.ps) {
      final parts = <String>[];
      if (level.isNotEmpty) parts.add(level);
      if (rulesCount > 0) parts.add('$rulesCount ترکیبونه');
      return parts.isEmpty ? '' : parts.join(' • ');
    }
    final parts = <String>[];
    if (level.isNotEmpty) parts.add(level);
    if (rulesCount > 0) parts.add('$rulesCount rules');
    return parts.isEmpty ? '' : parts.join(' • ');
  }

  String _localizedLessonLevel(AlphabetJsonLesson lesson, AppLanguage lang) {
    switch (lang) {
      case AppLanguage.fa:
        return lesson.levelFa.isNotEmpty
            ? lesson.levelFa
            : (lesson.levelEn.isNotEmpty ? lesson.levelEn : lesson.levelDe);
      case AppLanguage.ps:
        return lesson.levelPs.isNotEmpty
            ? lesson.levelPs
            : (lesson.levelFa.isNotEmpty
                ? lesson.levelFa
                : (lesson.levelEn.isNotEmpty ? lesson.levelEn : lesson.levelDe));
      case AppLanguage.en:
        return lesson.levelEn.isNotEmpty
            ? lesson.levelEn
            : (lesson.levelFa.isNotEmpty ? lesson.levelFa : lesson.levelDe);
    }
  }

  String _localizedLessonLevelCombinations(
    CombinationsJsonLesson lesson,
    AppLanguage lang,
  ) {
    switch (lang) {
      case AppLanguage.fa:
        return lesson.levelFa.isNotEmpty
            ? lesson.levelFa
            : (lesson.levelEn.isNotEmpty ? lesson.levelEn : lesson.levelDe);
      case AppLanguage.ps:
        return lesson.levelPs.isNotEmpty
            ? lesson.levelPs
            : (lesson.levelFa.isNotEmpty
                ? lesson.levelFa
                : (lesson.levelEn.isNotEmpty ? lesson.levelEn : lesson.levelDe));
      case AppLanguage.en:
        return lesson.levelEn.isNotEmpty
            ? lesson.levelEn
            : (lesson.levelFa.isNotEmpty ? lesson.levelFa : lesson.levelDe);
    }
  }
}

class _LessonCard extends StatelessWidget {
  const _LessonCard({
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.gradientColors,
    required this.isCompleted,
    required this.onTap,
  });

  final Widget badge;
  final String title;
  final String subtitle;
  final List<Color> gradientColors;
  final bool isCompleted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const onGradient = Colors.white;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: onGradient.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(18),
              ),
              alignment: Alignment.center,
              child: IconTheme(
                data: IconThemeData(
                  color: onGradient,
                  size: 26,
                ),
                child: badge,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: onGradient,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: onGradient.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              isCompleted ? LucideIcons.checkCircle2 : LucideIcons.chevronRight,
              color: onGradient,
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final _settingsRepo = SettingsRepository();
  bool _appNotifications = true;
  bool _dailyReminder = false;
  bool _loadingSwitches = true;

  @override
  void initState() {
    super.initState();
    _loadSwitchValues();
  }

  Future<void> _loadSwitchValues() async {
    final notifications = await _settingsRepo.loadAppNotifications();
    final reminder = await _settingsRepo.loadDailyReminder();
    if (!mounted) return;
    setState(() {
      _appNotifications = notifications;
      _dailyReminder = reminder;
      _loadingSwitches = false;
    });
  }

  void _onNotificationsChanged(bool value) {
    setState(() {
      _appNotifications = value;
    });
    _settingsRepo.setAppNotifications(value);
  }

  void _onReminderChanged(bool value) {
    setState(() {
      _dailyReminder = value;
    });
    _settingsRepo.setDailyReminder(value);
  }

  void _showLanguagePicker(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final appState = context.read<AppState>();
    final current = appState.appLanguage;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 12),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    loc.settingsSelectLanguageTitle,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(LucideIcons.globe),
                title: Text(AppLanguage.en.nativeName),
                trailing: current == AppLanguage.en
                    ? Icon(LucideIcons.check,
                        color: theme.colorScheme.primary)
                    : null,
                onTap: () {
                  appState.setLanguage(AppLanguage.en);
                  Navigator.of(sheetContext).pop();
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.globe),
                title: Text(AppLanguage.fa.nativeName),
                trailing: current == AppLanguage.fa
                    ? Icon(LucideIcons.check,
                        color: theme.colorScheme.primary)
                    : null,
                onTap: () {
                  appState.setLanguage(AppLanguage.fa);
                  Navigator.of(sheetContext).pop();
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.globe),
                title: Text(AppLanguage.ps.nativeName),
                trailing: current == AppLanguage.ps
                    ? Icon(LucideIcons.check,
                        color: theme.colorScheme.primary)
                    : null,
                onTap: () {
                  appState.setLanguage(AppLanguage.ps);
                  Navigator.of(sheetContext).pop();
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void _showWordLanguagesPicker(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final appState = context.read<AppState>();
    final messenger = ScaffoldMessenger.of(context);
    final initial = List<AppLanguage>.of(appState.wordLanguages);

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            final selected = List<AppLanguage>.of(initial);
            void setSelected(List<AppLanguage> next) {
              initial
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
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 6),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        loc.settingsSelectWordLanguagesTitle,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
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
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color
                              ?.withValues(alpha: 0.75),
                        ),
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

  void _showThemePicker(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final appState = context.read<AppState>();
    final current = appState.themeMode;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        Widget tile({
          required ThemeMode value,
          required String title,
        }) {
          return ListTile(
            leading: Icon(
              switch (value) {
                ThemeMode.system => LucideIcons.smartphone,
                ThemeMode.light => LucideIcons.sun,
                ThemeMode.dark => LucideIcons.moon,
              },
            ),
            title: Text(title),
            trailing: current == value
                ? Icon(LucideIcons.check, color: theme.colorScheme.primary)
                : null,
            onTap: () {
              appState.setThemeMode(value);
              Navigator.of(sheetContext).pop();
            },
          );
        }

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 12),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    loc.settingsTheme,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              tile(value: ThemeMode.system, title: loc.settingsThemeSystem),
              tile(value: ThemeMode.light, title: loc.settingsThemeLight),
              tile(value: ThemeMode.dark, title: loc.settingsThemeDark),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _section({
    required BuildContext context,
    required String title,
    required List<Widget> tiles,
  }) {
    final theme = Theme.of(context);
    final divider = Divider(
      height: 1,
      thickness: 1,
      color: theme.dividerColor.withValues(alpha: 0.12),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 4, bottom: 8),
          child: Text(
            title,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: 0.14),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < tiles.length; i++) ...[
                if (i > 0) divider,
                tiles[i],
              ],
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.watch<AppState>();
    final loc = AppLocalizations.of(context)!;
    final currentLanguage = appState.appLanguage;
    final currentTheme = appState.themeMode;
    final languageLabel = currentLanguage.nativeName;
    final wordLanguagesLabel = appState.wordLanguages.map((l) => l.nativeName).join(' + ');
    final themeLabel = switch (currentTheme) {
      ThemeMode.system => loc.settingsThemeSystem,
      ThemeMode.light => loc.settingsThemeLight,
      ThemeMode.dark => loc.settingsThemeDark,
    };

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      children: [
        Text(
          loc.settingsTitle,
          style:
              theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 20),
        _section(
          context: context,
          title: loc.settingsLanguage,
          tiles: [
            ListTile(
              leading: const Icon(LucideIcons.globe),
              title: Text(loc.settingsAppLanguageTitle),
              subtitle: Text(languageLabel),
              trailing: const Icon(LucideIcons.chevronRight),
              onTap: () => _showLanguagePicker(context),
            ),
            ListTile(
              leading: const Icon(LucideIcons.languages),
              title: Text(loc.settingsWordLanguagesTitle),
              subtitle: Text(wordLanguagesLabel),
              trailing: const Icon(LucideIcons.chevronRight),
              onTap: () => _showWordLanguagesPicker(context),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _section(
          context: context,
          title: loc.settingsTheme,
          tiles: [
            ListTile(
              leading: const Icon(LucideIcons.palette),
              title: Text(loc.settingsTheme),
              subtitle: Text(themeLabel),
              trailing: const Icon(LucideIcons.chevronRight),
              onTap: () => _showThemePicker(context),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _section(
          context: context,
          title: loc.settingsNotificationsTitle,
          tiles: [
            SwitchListTile(
              value: _appNotifications,
              onChanged: _loadingSwitches ? null : _onNotificationsChanged,
              title: Text(loc.settingsNotifications),
              secondary: const Icon(LucideIcons.bell),
              contentPadding:
                  const EdgeInsetsDirectional.symmetric(horizontal: 16),
            ),
            SwitchListTile(
              value: _dailyReminder,
              onChanged: _loadingSwitches ? null : _onReminderChanged,
              title: Text(loc.settingsDailyReminder),
              secondary: const Icon(LucideIcons.alarmClock),
              contentPadding:
                  const EdgeInsetsDirectional.symmetric(horizontal: 16),
            ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
