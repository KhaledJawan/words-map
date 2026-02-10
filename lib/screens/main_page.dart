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
  const MainPage({super.key, this.initialBundle});

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
          return Scaffold(body: Center(child: Text(loc.loadWordsFailed)));
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
            child: IndexedStack(index: _currentIndex, children: tabs),
          ),
          bottomNavigationBar: Directionality(
            textDirection: TextDirection.ltr,
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: _selectTab,
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(LucideIcons.home),
                  label: loc.tabHome,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(LucideIcons.bookOpenCheck),
                  label: loc.tabLessons,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(LucideIcons.userCog),
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
  const LessonsTab({super.key, required this.allWords});

  final List<VocabWord> allWords;

  @override
  State<LessonsTab> createState() => _LessonsTabState();
}

class _LessonsTabData {
  const _LessonsTabData({required this.alphabet, required this.combinations});

  final AlphabetJsonLesson alphabet;
  final CombinationsJsonLesson combinations;
}

class _LessonsTabState extends State<LessonsTab> {
  final Set<String> _completedLessonIds = {};
  bool _isLoading = true;
  final LessonCompletionRepository _completionRepo =
      LessonCompletionRepository();
  Future<_LessonsTabData>? _lessonsFuture;
  AppLanguage? _loadedSourceLanguage;

  static const Map<AppLanguage, String> _lessonAssetBySourceLanguage = {
    AppLanguage.de: 'assets/lessons/lesson_de.json',
    AppLanguage.en: 'assets/lessons/lesson_en.json',
    AppLanguage.fa: 'assets/lessons/lesson_fa.json',
    AppLanguage.ps: 'assets/lessons/lesson_ps.json',
    AppLanguage.fr: 'assets/lessons/lesson_fr.json',
    AppLanguage.tr: 'assets/lessons/lesson_tr.json',
  };

  @override
  void initState() {
    super.initState();
    final sourceLanguage = context.read<AppState>().sourceWordLanguage;
    _loadedSourceLanguage = sourceLanguage;
    _lessonsFuture = _loadLessons(sourceLanguage);
    _loadCompletedLessons();
  }

  String _lessonAssetPathFor(AppLanguage sourceLanguage) {
    return _lessonAssetBySourceLanguage[sourceLanguage] ??
        'assets/lessons/lesson_de.json';
  }

  void _ensureLessonsFuture(AppLanguage sourceLanguage) {
    if (_loadedSourceLanguage == sourceLanguage && _lessonsFuture != null) {
      return;
    }
    _loadedSourceLanguage = sourceLanguage;
    _lessonsFuture = _loadLessons(sourceLanguage);
  }

  Future<_LessonsTabData> _loadLessons(AppLanguage sourceLanguage) async {
    final assetPath = _lessonAssetPathFor(sourceLanguage);
    final results = await Future.wait([
      AssetAlphabetJsonLessonRepository(
        assetPath: assetPath,
      ).loadLesson(),
      AssetCombinationsJsonLessonRepository(
        assetPath: assetPath,
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
    final appState = context.watch<AppState>();
    final lessonLanguage = appState.targetWordLanguage;
    final appLanguage = lessonLanguage;
    final sourceLanguage = appState.sourceWordLanguage;
    _ensureLessonsFuture(sourceLanguage);
    final lessonAssetPath = _lessonAssetPathFor(sourceLanguage);
    return Localizations.override(
      context: context,
      locale: lessonLanguage.locale,
      child: Builder(
        builder: (localizedContext) {
          final loc = AppLocalizations.of(localizedContext)!;
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
              final combinationsCompleted = _completedLessonIds.contains(
                combinations.id,
              );

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    loc.lessonsTitle,
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  _LessonCard(
                    badge: const Icon(Icons.abc),
                    title: _localizedAlphabetTitle(alphabet, appLanguage),
                    subtitle: _buildAlphabetSubtitle(alphabet, appLanguage),
                    gradientColors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withValues(
                        alpha: 0.78,
                      ),
                    ],
                    isCompleted: alphabetCompleted,
                    onTap: () async {
                      final result = await Navigator.of(context).push<bool>(
                        MaterialPageRoute(
                          builder: (_) => AlphabetJsonLessonPage(
                            assetPath: lessonAssetPath,
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
                      Theme.of(context).colorScheme.secondary.withValues(
                        alpha: 0.82,
                      ),
                    ],
                    isCompleted: combinationsCompleted,
                    onTap: () async {
                      final result = await Navigator.of(context).push<bool>(
                        MaterialPageRoute(
                          builder: (_) => CombinationsJsonLessonPage(
                            assetPath: lessonAssetPath,
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
        },
      ),
    );
  }

  String _localizedAlphabetTitle(AlphabetJsonLesson lesson, AppLanguage lang) {
    switch (lang) {
      case AppLanguage.fa:
        return lesson.titleFa.isNotEmpty
            ? lesson.titleFa
            : lesson.titleEn;
      case AppLanguage.ps:
        return lesson.titlePs.isNotEmpty
            ? lesson.titlePs
            : (lesson.titleFa.isNotEmpty
                  ? lesson.titleFa
                  : lesson.titleEn);
      case AppLanguage.en:
        return lesson.titleEn;
      case AppLanguage.fr:
        return lesson.titleEn;
      case AppLanguage.tr:
        return lesson.titleEn;
      case AppLanguage.de:
        return lesson.titleDe.isNotEmpty
            ? lesson.titleDe
            : lesson.titleEn;
    }
  }

  String _localizedCombinationsTitle(
    CombinationsJsonLesson lesson,
    AppLanguage lang,
  ) {
    switch (lang) {
      case AppLanguage.fa:
        return lesson.titleFa.isNotEmpty
            ? lesson.titleFa
            : lesson.titleEn;
      case AppLanguage.ps:
        return lesson.titlePs.isNotEmpty
            ? lesson.titlePs
            : (lesson.titleFa.isNotEmpty
                  ? lesson.titleFa
                  : lesson.titleEn);
      case AppLanguage.en:
        return lesson.titleEn;
      case AppLanguage.fr:
        return lesson.titleEn;
      case AppLanguage.tr:
        return lesson.titleEn;
      case AppLanguage.de:
        return lesson.titleDe.isNotEmpty
            ? lesson.titleDe
            : lesson.titleEn;
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
    if (lang == AppLanguage.de) {
      final parts = <String>[];
      if (level.isNotEmpty) parts.add(level);
      if (lettersCount > 0) parts.add('$lettersCount Buchstaben');
      return parts.isEmpty ? '' : parts.join(' • ');
    }
    final parts = <String>[];
    if (level.isNotEmpty) parts.add(level);
    if (lettersCount > 0) parts.add('$lettersCount letters');
    return parts.isEmpty ? '' : parts.join(' • ');
  }

  String _buildCombinationsSubtitle(
    CombinationsJsonLesson lesson,
    AppLanguage lang,
  ) {
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
    if (lang == AppLanguage.de) {
      final parts = <String>[];
      if (level.isNotEmpty) parts.add(level);
      if (rulesCount > 0) parts.add('$rulesCount Regeln');
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
            : lesson.levelEn;
      case AppLanguage.ps:
        return lesson.levelPs.isNotEmpty
            ? lesson.levelPs
            : (lesson.levelFa.isNotEmpty
                  ? lesson.levelFa
                  : lesson.levelEn);
      case AppLanguage.en:
        return lesson.levelEn;
      case AppLanguage.fr:
        return lesson.levelEn;
      case AppLanguage.tr:
        return lesson.levelEn;
      case AppLanguage.de:
        return lesson.levelDe.isNotEmpty
            ? lesson.levelDe
            : lesson.levelEn;
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
            : lesson.levelEn;
      case AppLanguage.ps:
        return lesson.levelPs.isNotEmpty
            ? lesson.levelPs
            : (lesson.levelFa.isNotEmpty
                  ? lesson.levelFa
                  : lesson.levelEn);
      case AppLanguage.en:
        return lesson.levelEn;
      case AppLanguage.fr:
        return lesson.levelEn;
      case AppLanguage.tr:
        return lesson.levelEn;
      case AppLanguage.de:
        return lesson.levelDe.isNotEmpty
            ? lesson.levelDe
            : lesson.levelEn;
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
                data: IconThemeData(color: onGradient, size: 26),
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
                padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 12),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    loc.settingsSelectLanguageTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(LucideIcons.globe),
                title: Text(AppLanguage.en.nativeName),
                trailing: current == AppLanguage.en
                    ? Icon(LucideIcons.check, color: theme.colorScheme.primary)
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
                    ? Icon(LucideIcons.check, color: theme.colorScheme.primary)
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
                    ? Icon(LucideIcons.check, color: theme.colorScheme.primary)
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
    final appState = context.read<AppState>();
    final uiLanguage = appState.appLanguage;
    final allOptions = const <AppLanguage>[
      AppLanguage.de,
      AppLanguage.en,
      AppLanguage.fr,
      AppLanguage.tr,
      AppLanguage.fa,
      AppLanguage.ps,
    ];
    AppLanguage source = appState.sourceWordLanguage;
    AppLanguage target = appState.targetWordLanguage;
    if (target == source) {
      target = allOptions.firstWhere((lang) => lang != source);
    }

    String copy({required String en, required String fa, required String ps}) {
      switch (uiLanguage) {
        case AppLanguage.fa:
          return fa;
        case AppLanguage.ps:
          return ps;
        case AppLanguage.en:
        case AppLanguage.fr:
        case AppLanguage.de:
        case AppLanguage.tr:
          return en;
      }
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            List<AppLanguage> targetOptions() =>
                allOptions.where((lang) => lang != source).toList();

            Widget languageDropdown({
              required String label,
              required String hint,
              required AppLanguage value,
              required List<AppLanguage> options,
              required ValueChanged<AppLanguage?> onChanged,
              required IconData icon,
            }) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<AppLanguage>(
                    value: value,
                    isExpanded: true,
                    icon: const Icon(LucideIcons.chevronsUpDown),
                    decoration: InputDecoration(
                      hintText: hint,
                      prefixIcon: Icon(icon),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.45),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: theme.dividerColor.withValues(alpha: 0.2),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: theme.colorScheme.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                    items: options
                        .map(
                          (lang) => DropdownMenuItem<AppLanguage>(
                            value: lang,
                            child: Text(lang.nativeName),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: onChanged,
                  ),
                ],
              );
            }

            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(
                      16,
                      0,
                      16,
                      16 + MediaQuery.of(sheetContext).viewInsets.bottom,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              LucideIcons.languages,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              copy(
                                en: 'Word Pair',
                                fa: 'جفت واژه',
                                ps: 'د لغت جوړه',
                              ),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          copy(
                            en: 'Set your learning and translation languages.',
                            fa: 'زبان یادگیری و زبان ترجمه را انتخاب کنید.',
                            ps: 'د زده کړې ژبه او د ژباړې ژبه وټاکئ.',
                          ),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withValues(
                              alpha: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        languageDropdown(
                          label: copy(
                            en: 'Learn In',
                            fa: 'زبان یادگیری',
                            ps: 'د زده کړې ژبه',
                          ),
                          hint: copy(
                            en: 'Language shown on word cards',
                            fa: 'زبان خود واژه‌ها',
                            ps: 'د لغتونو ژبه',
                          ),
                          value: source,
                          options: allOptions,
                          icon: LucideIcons.bookOpen,
                          onChanged: (next) {
                            if (next == null) return;
                            setSheetState(() {
                              source = next;
                              if (target == source) {
                                target = targetOptions().first;
                              }
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        languageDropdown(
                          label: copy(
                            en: 'Translate To',
                            fa: 'زبان معنی',
                            ps: 'د مانا ژبه',
                          ),
                          hint: copy(
                            en: 'Language used for meanings',
                            fa: 'زبان ترجمه‌ها',
                            ps: 'د ژباړې ژبه',
                          ),
                          value: target,
                          options: targetOptions(),
                          icon: LucideIcons.languages,
                          onChanged: (next) {
                            if (next == null) return;
                            setSheetState(() => target = next);
                          },
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.55),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                LucideIcons.sparkles,
                                size: 16,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${source.nativeName}  ->  ${target.nativeName}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () =>
                                    Navigator.of(sheetContext).pop(),
                                style: TextButton.styleFrom(
                                  minimumSize: const Size(0, 44),
                                  backgroundColor: theme
                                      .colorScheme
                                      .surfaceContainerHighest
                                      .withValues(alpha: 0.55),
                                  foregroundColor: theme.colorScheme.onSurface,
                                  shape: const StadiumBorder(),
                                ),
                                child: Text(
                                  copy(en: 'Cancel', fa: 'لغو', ps: 'لغوه'),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextButton.icon(
                                onPressed: () async {
                                  await appState.setWordLanguages([
                                    source,
                                    target,
                                  ]);
                                  if (!sheetContext.mounted) return;
                                  Navigator.of(sheetContext).pop();
                                },
                                style: TextButton.styleFrom(
                                  minimumSize: const Size(0, 44),
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  shape: const StadiumBorder(),
                                ),
                                icon: const Icon(LucideIcons.check, size: 16),
                                label: Text(
                                  copy(en: 'Apply', fa: 'اعمال', ps: 'پلي کول'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
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
        Widget tile({required ThemeMode value, required String title}) {
          return ListTile(
            leading: Icon(switch (value) {
              ThemeMode.system => LucideIcons.smartphone,
              ThemeMode.light => LucideIcons.sun,
              ThemeMode.dark => LucideIcons.moon,
            }),
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
                padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 12),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    loc.settingsTheme,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
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
    final languagePairTitle = switch (currentLanguage) {
      AppLanguage.fa => 'جفت واژه',
      AppLanguage.ps => 'د لغت جوړه',
      AppLanguage.en ||
      AppLanguage.de ||
      AppLanguage.tr ||
      AppLanguage.fr => 'Word Pair',
    };
    final languagePairSubtitle =
        '${appState.sourceWordLanguage.nativeName} -> ${appState.targetWordLanguage.nativeName}';
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
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
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
              title: Text(languagePairTitle),
              subtitle: Text(languagePairSubtitle),
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
              contentPadding: const EdgeInsetsDirectional.symmetric(
                horizontal: 16,
              ),
            ),
            SwitchListTile(
              value: _dailyReminder,
              onChanged: _loadingSwitches ? null : _onReminderChanged,
              title: Text(loc.settingsDailyReminder),
              secondary: const Icon(LucideIcons.alarmClock),
              contentPadding: const EdgeInsetsDirectional.symmetric(
                horizontal: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
