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
          bottomNavigationBar: BottomNavigationBar(
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
      case AppLanguage.en:
        return lesson.titleEn.isNotEmpty
            ? lesson.titleEn
            : (lesson.titleDe.isNotEmpty ? lesson.titleDe : lesson.titleFa);
      case AppLanguage.de:
        return lesson.titleDe.isNotEmpty
            ? lesson.titleDe
            : (lesson.titleEn.isNotEmpty ? lesson.titleEn : lesson.titleFa);
    }
  }

  String _localizedCombinationsTitle(CombinationsJsonLesson lesson, AppLanguage lang) {
    switch (lang) {
      case AppLanguage.fa:
        return lesson.titleFa.isNotEmpty
            ? lesson.titleFa
            : (lesson.titleEn.isNotEmpty ? lesson.titleEn : lesson.titleDe);
      case AppLanguage.en:
        return lesson.titleEn.isNotEmpty
            ? lesson.titleEn
            : (lesson.titleDe.isNotEmpty ? lesson.titleDe : lesson.titleFa);
      case AppLanguage.de:
        return lesson.titleDe.isNotEmpty
            ? lesson.titleDe
            : (lesson.titleEn.isNotEmpty ? lesson.titleEn : lesson.titleFa);
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
      case AppLanguage.en:
        return lesson.levelEn.isNotEmpty
            ? lesson.levelEn
            : (lesson.levelDe.isNotEmpty ? lesson.levelDe : lesson.levelFa);
      case AppLanguage.de:
        return lesson.levelDe.isNotEmpty
            ? lesson.levelDe
            : (lesson.levelEn.isNotEmpty ? lesson.levelEn : lesson.levelFa);
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
      case AppLanguage.en:
        return lesson.levelEn.isNotEmpty
            ? lesson.levelEn
            : (lesson.levelDe.isNotEmpty ? lesson.levelDe : lesson.levelFa);
      case AppLanguage.de:
        return lesson.levelDe.isNotEmpty
            ? lesson.levelDe
            : (lesson.levelEn.isNotEmpty ? lesson.levelEn : lesson.levelFa);
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
    final onGradient = ThemeData.estimateBrightnessForColor(gradientColors.first) ==
            Brightness.dark
        ? Colors.white
        : Colors.black;
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

  void _onLanguageChanged(String? code) {
    if (code == null) return;
    final appState = context.read<AppState>();
    if (appState.appLocale?.languageCode == code) return;
    if (code == 'fa') {
      appState.changeLocale(const Locale('fa'));
    } else {
      appState.changeLocale(const Locale('en'));
    }
  }

  void _onThemeChanged(ThemeMode? mode) {
    if (mode == null) return;
    final appState = context.read<AppState>();
    if (appState.themeMode == mode) return;
    appState.setThemeMode(mode);
  }

  Widget _buildSectionCard(Widget child) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.watch<AppState>();
    final loc = AppLocalizations.of(context)!;
    final languageCode = appState.appLocale?.languageCode ?? 'en';
    final currentTheme = appState.themeMode;
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      children: [
        Text(
          loc.settingsTitle,
          style:
              theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        _buildSectionCard(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.settingsLanguage,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                loc.settingsLanguageDescription,
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              RadioListTile<String>(
                value: 'en',
                groupValue: languageCode,
                title: Text(loc.settingsLanguageEnglish),
                onChanged: _onLanguageChanged,
              ),
              RadioListTile<String>(
                value: 'fa',
                groupValue: languageCode,
                title: Text(loc.settingsLanguageFarsi),
                onChanged: _onLanguageChanged,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildSectionCard(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.settingsTheme,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                loc.settingsThemeDescription,
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              RadioListTile<ThemeMode>(
                value: ThemeMode.system,
                groupValue: currentTheme,
                title: Text(loc.settingsThemeSystem),
                onChanged: _onThemeChanged,
              ),
              RadioListTile<ThemeMode>(
                value: ThemeMode.light,
                groupValue: currentTheme,
                title: Text(loc.settingsThemeLight),
                onChanged: _onThemeChanged,
              ),
              RadioListTile<ThemeMode>(
                value: ThemeMode.dark,
                groupValue: currentTheme,
                title: Text(loc.settingsThemeDark),
                onChanged: _onThemeChanged,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildSectionCard(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.settingsNotificationsTitle,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                loc.settingsNotificationsDescription,
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                value: _appNotifications,
                onChanged: _loadingSwitches ? null : _onNotificationsChanged,
                title: Text(loc.settingsNotifications),
              ),
              SwitchListTile(
                value: _dailyReminder,
                onChanged: _loadingSwitches ? null : _onReminderChanged,
                title: Text(loc.settingsDailyReminder),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
