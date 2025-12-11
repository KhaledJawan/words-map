import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:word_map_app/l10n/app_localizations.dart';
import 'package:word_map_app/screens/words_list_init.dart';
import 'package:word_map_app/screens/words_list_screen.dart';
import 'package:word_map_app/services/app_state.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:word_map_app/features/lessons/lesson_completion_repository.dart';
import 'package:word_map_app/features/lessons/lesson_localization.dart';
import 'package:word_map_app/features/lessons/lessons_repository.dart';
import 'package:word_map_app/features/settings/settings_repository.dart';
import 'package:word_map_app/screens/category_detail_page.dart';

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
          const LessonsTab(),
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
  const LessonsTab({super.key});

  @override
  State<LessonsTab> createState() => _LessonsTabState();
}

class _LessonsTabState extends State<LessonsTab> {
  final Set<String> _completedLessonIds = {};
  bool _isLoading = true;
  final LessonCompletionRepository _completionRepo = LessonCompletionRepository();

  @override
  void initState() {
    super.initState();
    _loadCompletedLessons();
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
    final categories = LessonsRepository.categories;
    final loc = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          loc.lessonsTitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        ...categories.map(
          (category) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildCategoryCard(category, loc),
          ),
        ),
      ],
    );
  }

  void _markLessonCompletedLocally(String lessonId) {
    if (_completedLessonIds.add(lessonId)) {
      setState(() {});
    }
  }

  Widget _buildCategoryCard(LessonCategory category, AppLocalizations loc) {
    final theme = Theme.of(context);
    final hasLessons = category.lessons.isNotEmpty;
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CategoryDetailPage(
              category: category,
              completedLessonIds: _completedLessonIds,
              onLessonCompleted: _markLessonCompletedLocally,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizedCategoryTitle(category.id, loc),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (category.description != null) ...[
              const SizedBox(height: 4),
              Text(
                category.description!,
                style: theme.textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 14),
            if (!hasLessons)
              Text(
                localizedLessonsStatusComingSoon(loc),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                ),
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
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        _buildSectionCard(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.settingsLanguage,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
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
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
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
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
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
