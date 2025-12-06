import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:word_map_app/models/vocab_word.dart';
import 'package:word_map_app/screens/level_select_screen.dart';
import 'package:word_map_app/screens/settings_screen.dart';
import 'package:word_map_app/services/app_state.dart';
import 'package:word_map_app/services/vocab_loader.dart';
import 'package:word_map_app/widgets/word_tile.dart';

enum SortMode { defaultOrder, alphabetical, bookmarkedFirst, unviewedFirst }

class WordsListScreen extends StatefulWidget {
  const WordsListScreen({super.key, this.level});

  final String? level;

  @override
  State<WordsListScreen> createState() => _WordsListScreenState();
}

class _WordsListScreenState extends State<WordsListScreen> {
  List<VocabWord> _words = [];
  List<VocabWord> _sorted = [];
  SortMode _sortMode = SortMode.defaultOrder;
  late String _currentLevel;

  @override
  void initState() {
    super.initState();
    _currentLevel = widget.level ?? '';
    _loadWords();
  }

  Future<void> _loadWords() async {
    final appState = context.read<AppState>();
    final level = widget.level ?? appState.currentLevel;
    final words = await loadWordsForLevel(level);
    for (final w in words) {
      w.isBookmarked = appState.isBookmarked(w);
      w.isViewed = appState.isViewed(w);
    }
    if (!mounted) return;
    setState(() {
      _words = words;
      _applySort();
      _currentLevel = level;
    });
  }

  void _applySort() {
    final List<VocabWord> list = List.of(_words);
    switch (_sortMode) {
      case SortMode.defaultOrder:
        _sorted = list;
        break;
      case SortMode.alphabetical:
        list.sort((a, b) => a.de.compareTo(b.de));
        _sorted = list;
        break;
      case SortMode.bookmarkedFirst:
        list.sort((a, b) {
          final aVal = a.isBookmarked ? 0 : 1;
          final bVal = b.isBookmarked ? 0 : 1;
          return aVal.compareTo(bVal);
        });
        _sorted = list;
        break;
      case SortMode.unviewedFirst:
        list.sort((a, b) {
          final aVal = a.isViewed ? 1 : 0;
          final bVal = b.isViewed ? 1 : 0;
          return aVal.compareTo(bVal);
        });
        _sorted = list;
        break;
    }
  }

  Future<void> _onWordTapped(VocabWord word) async {
    final appState = context.read<AppState>();
    word.isViewed = true;
    await appState.markViewed(word);
    setState(() => _applySort());
    if (!mounted) return;
    await _showWordOverlay(word);
  }

  void _toggleBookmark(VocabWord word) async {
    await context.read<AppState>().toggleBookmark(word);
    if (!mounted) return;
    setState(() => _applySort());
  }

  Future<void> _showWordOverlay(VocabWord word) async {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Word details',
      barrierColor: Colors.black.withOpacity(0.35),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.95, end: 1.0)
                  .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutBack)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Material(
                  color: cs.surface,
                  elevation: 8,
                  borderRadius: BorderRadius.circular(28),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.all(20),
                    child: Builder(
                      builder: (dialogContext) {
                        final isBookmarked = dialogContext.watch<AppState>().isBookmarked(word);
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Align(
                              alignment: AlignmentDirectional.centerEnd,
                              child: IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => Navigator.of(dialogContext).pop(),
                              ),
                            ),
                            Text(
                              word.de,
                              textAlign: TextAlign.center,
                              style: textTheme.headlineSmall?.copyWith(color: cs.onSurface),
                            ),
                            const SizedBox(height: 12),
                            if (word.translationFa.isNotEmpty)
                              Text(
                                word.translationFa,
                                textAlign: TextAlign.center,
                                style: textTheme.titleMedium?.copyWith(
                                  fontFamily: 'Vazirmatn',
                                  color: cs.onSurface,
                                ),
                              ),
                            if (word.translationEn.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                word.translationEn,
                                textAlign: TextAlign.center,
                                style: textTheme.bodyLarge?.copyWith(
                                  color: cs.onSurface.withOpacity(0.75),
                                ),
                              ),
                            ],
                            if (word.example != null && word.example!.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Text(
                                word.example!,
                                textAlign: TextAlign.center,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: cs.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ],
                            const SizedBox(height: 20),
                            FilledButton.icon(
                              onPressed: () async {
                                await dialogContext.read<AppState>().toggleBookmark(word);
                                if (mounted) {
                                  setState(() => _applySort());
                                }
                                if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: cs.surface,
                                foregroundColor: cs.onSurface,
                                side: BorderSide(color: cs.outline),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                              icon: Icon(
                                isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                              ),
                              label: Text(isBookmarked ? 'Bookmarked' : 'Bookmark'),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final viewedCount =
        _words.where((w) => w.isViewed || w.isVisited).length;
    final bookmarkedCount = _words.where((w) => w.isBookmarked).length;

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 120,
        leading: Padding(
          padding: const EdgeInsetsDirectional.only(start: 12),
          child: Center(
            child: Container(
              padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: cs.outline),
              ),
              child: Text(
                'Viewed $viewedCount/${_words.length}',
                style: textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
            ),
          ),
        ),
        title: Text('$_currentLevel Vocabulary'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortSheet,
          ),
        ],
      ),
      body: _buildWordsTab(textTheme),
      floatingActionButton: FloatingActionButton(
        onPressed: _showFabMenu,
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        shape: const StadiumBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildWordsTab(TextTheme textTheme) {
    if (_sorted.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadWords,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 120),
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 32),
              child: Text(
                'No words found for this level.',
                style: textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadWords,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 120),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: List.generate(_sorted.length, (index) {
            final word = _sorted[index];
            return WordTile(
              word: word,
              index: index,
              onTap: () => _onWordTapped(word),
              onLongPress: () => _toggleBookmark(word),
            );
          }),
        ),
      ),
    );
  }

  void _toggleTheme() {
    final appState = context.read<AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    appState.setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
  }

  void _openLevelSelect() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LevelSelectScreen()),
    );
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  void _showFabMenu() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.layers),
                title: const Text('Levels'),
                onTap: () {
                  Navigator.pop(context);
                  _openLevelSelect();
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                  _openSettings();
                },
              ),
              ListTile(
                leading: const Icon(Icons.dark_mode),
                title: const Text('Dark mode'),
                onTap: () {
                  Navigator.pop(context);
                  _toggleTheme();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSortSheet() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Default order'),
                onTap: () {
                  setState(() {
                    _sortMode = SortMode.defaultOrder;
                    _applySort();
                  });
                  Navigator.pop(context);
                },
                trailing: _sortMode == SortMode.defaultOrder
                    ? const Icon(Icons.check)
                    : null,
              ),
              ListTile(
                title: const Text('Alphabetical'),
                onTap: () {
                  setState(() {
                    _sortMode = SortMode.alphabetical;
                    _applySort();
                  });
                  Navigator.pop(context);
                },
                trailing: _sortMode == SortMode.alphabetical
                    ? const Icon(Icons.check)
                    : null,
              ),
              ListTile(
                title: const Text('Bookmarked first'),
                onTap: () {
                  setState(() {
                    _sortMode = SortMode.bookmarkedFirst;
                    _applySort();
                  });
                  Navigator.pop(context);
                },
                trailing: _sortMode == SortMode.bookmarkedFirst
                    ? const Icon(Icons.check)
                    : null,
              ),
              ListTile(
                title: const Text('Unviewed first'),
                onTap: () {
                  setState(() {
                    _sortMode = SortMode.unviewedFirst;
                    _applySort();
                  });
                  Navigator.pop(context);
                },
                trailing: _sortMode == SortMode.unviewedFirst
                    ? const Icon(Icons.check)
                    : null,
              ),
            ],
          ),
        );
      },
    );
  }
}
