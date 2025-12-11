import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:word_map_app/l10n/app_localizations.dart';
import 'package:word_map_app/screens/words_list_init.dart';
import 'package:word_map_app/screens/words_list_screen.dart';
import 'package:word_map_app/services/app_state.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:word_map_app/features/lessons/lessons_repository.dart';
import 'package:word_map_app/screens/category_detail_page.dart';
import 'package:word_map_app/screens/lesson_detail_page.dart';

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
            items: const [
              BottomNavigationBarItem(
                icon: Icon(
                  LucideIcons.home,
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  LucideIcons.bookOpenCheck,
                ),
                label: 'Lessons',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  LucideIcons.userCog,
                ),
                label: 'Profile',
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
  final LessonsRepository _repository = LessonsRepository();
  final Set<String> _completedLessonIds = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCompletedLessons();
  }

  Future<void> _loadCompletedLessons() async {
    final states = await _repository.loadCompletionStates();
    if (!mounted) return;
    setState(() {
      _completedLessonIds
        ..clear()
        ..addAll(
          states.entries.where((entry) => entry.value).map((entry) => entry.key),
        );
      _isLoading = false;
    });
  }

  bool _isCompleted(LessonItem lesson) => _completedLessonIds.contains(lesson.id);
  bool _isCompletedById(String lessonId) => _completedLessonIds.contains(lessonId);

  Future<void> _openLesson(LessonItem lesson) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => LessonDetailPage(lesson: lesson),
      ),
    );
    if (result == true) {
      await _loadCompletedLessons();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final categories = LessonsRepository.categories;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildCategoryCard(category),
        );
      },
    );
  }

  Widget _buildCategoryCard(LessonCategory category) {
    final theme = Theme.of(context);
    final hasLessons = category.lessons.isNotEmpty;
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CategoryDetailPage(
              category: category,
              isCompleted: (lessonId) => _isCompletedById(lessonId),
              onLessonTap: _openLesson,
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
              category.title,
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
                'Coming soon',
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

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      children: [
        Text(
          'Profile',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: Colors.grey.shade200,
              child: const Icon(LucideIcons.user, size: 40),
              ),
              const SizedBox(height: 12),
              Text(
                'WordMap learner',
                style: textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'vip-user@wordmap.app',
                style: textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Settings',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Column(
            children: const [
              ListTile(
                leading: Icon(LucideIcons.languages),
                title: Text('Language'),
                subtitle: Text('English / فارسی'),
              ),
              Divider(height: 1),
              ListTile(
                leading: Icon(LucideIcons.moon),
                title: Text('Theme'),
                subtitle: Text('Light / Dark'),
              ),
              Divider(height: 1),
              ListTile(
                leading: Icon(LucideIcons.bell),
                title: Text('Notifications'),
                subtitle: Text('Reminders, word streaks'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
