import 'dart:async';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:word_map_app/models/vocab_word.dart';
import 'package:word_map_app/models/word_progress.dart';
import 'package:word_map_app/services/app_state.dart';
import 'package:word_map_app/services/progress_repository.dart';
import 'package:word_map_app/services/vocab_loader.dart';
import 'package:word_map_app/version_checker.dart';
import 'package:word_map_app/widgets/word_detail_soft_card.dart';
import 'package:word_map_app/widgets/word_tile.dart';

enum SortMode { defaultOrder, alphabetical, bookmarkedFirst, unviewedFirst }

class WordsListScreen extends StatefulWidget {
  const WordsListScreen({super.key, this.level});

  final String? level;

  @override
  State<WordsListScreen> createState() => _WordsListScreenState();
}

class _WordsListScreenState extends State<WordsListScreen> {
  late Future<_InitBundle> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _loadInitial();
  }

  Future<_InitBundle> _loadInitial() async {
    final appState = Provider.of<AppState>(context, listen: false);
    final repo = ProgressRepository();
    final levels = appState.levels;
    final progress = await repo.loadProgress();
    final lastLevel =
        await repo.loadLastLevel() ?? widget.level ?? appState.currentLevel;

    final List<VocabWord> allWords = [];
    for (final level in levels) {
      final words = await loadWordsForLevel(level);
      for (final w in words) {
        final p = progress[w.id];
        if (p != null) {
          w.isBookmarked = p.bookmarked;
          w.isViewed = p.learned;
        } else {
          w.isBookmarked = appState.isBookmarked(w);
          w.isViewed = appState.isViewed(w);
        }
      }
      allWords.addAll(words);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      VersionChecker.checkForUpdate(context);
    });

    return _InitBundle(
      allWords: allWords,
      progress: progress,
      lastLevel: lastLevel,
      levels: levels,
      repo: repo,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return FutureBuilder<_InitBundle>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData) {
          return Scaffold(
            body: Center(
              child: Text(
                'Failed to load words',
                style: textTheme.titleMedium,
              ),
            ),
          );
        }
        final data = snapshot.data!;
        return WordsContent(
          allWords: data.allWords,
          initialProgress: data.progress,
          initialLevel: data.lastLevel,
          levels: data.levels,
          repo: data.repo,
        );
      },
    );
  }
}

class WordsContent extends StatefulWidget {
  const WordsContent({
    super.key,
    required this.allWords,
    required this.initialProgress,
    required this.initialLevel,
    required this.levels,
    required this.repo,
  });

  final List<VocabWord> allWords;
  final Map<String, WordProgress> initialProgress;
  final String initialLevel;
  final List<String> levels;
  final ProgressRepository repo;

  @override
  State<WordsContent> createState() => _WordsContentState();
}

class _WordsContentState extends State<WordsContent> {
  late Map<String, WordProgress> _progress;
  late Map<String, List<VocabWord>> _wordsByLevel;
  late String _currentLevel;
  List<VocabWord> _visibleWords = [];
  SortMode _sortMode = SortMode.defaultOrder;
  Timer? _saveDebounce;

  @override
  void initState() {
    super.initState();
    _progress = Map.of(widget.initialProgress);
    _wordsByLevel = _groupByLevel(widget.allWords);
    _currentLevel =
        widget.initialLevel.isNotEmpty ? widget.initialLevel : widget.levels.first;
    _setVisibleForLevel(_currentLevel);
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    super.dispose();
  }

  Map<String, List<VocabWord>> _groupByLevel(List<VocabWord> words) {
    final Map<String, List<VocabWord>> grouped = {};
    for (final w in words) {
      final level = w.level ?? 'unknown';
      grouped.putIfAbsent(level, () => []);
      grouped[level]!.add(w);
    }
    return grouped;
  }

  void _setVisibleForLevel(String level) {
    final list = _wordsByLevel[level] ?? [];
    _visibleWords = List.of(list);
    _applySort();
  }

  void _applySort() {
    final list = List<VocabWord>.of(_visibleWords);
    switch (_sortMode) {
      case SortMode.defaultOrder:
        _visibleWords = list;
        break;
      case SortMode.alphabetical:
        list.sort((a, b) => a.de.compareTo(b.de));
        _visibleWords = list;
        break;
      case SortMode.bookmarkedFirst:
        list.sort((a, b) {
          final aVal = a.isBookmarked ? 0 : 1;
          final bVal = b.isBookmarked ? 0 : 1;
          return aVal.compareTo(bVal);
        });
        _visibleWords = list;
        break;
      case SortMode.unviewedFirst:
        list.sort((a, b) {
          final aVal = a.isViewed ? 1 : 0;
          final bVal = b.isViewed ? 1 : 0;
          return aVal.compareTo(bVal);
        });
        _visibleWords = list;
        break;
    }
    setState(() {});
  }

  void _changeLevel(String level) {
    if (level == _currentLevel) return;
    setState(() {
      _currentLevel = level;
      _setVisibleForLevel(level);
    });
    widget.repo.saveLastLevel(level);
  }

  void _toggleBookmark(VocabWord word) {
    setState(() {
      word.isBookmarked = !word.isBookmarked;
      final existing = _progress[word.id];
      _progress[word.id] = (existing ?? WordProgress(wordId: word.id))
          .copyWith(bookmarked: word.isBookmarked);
    });
    _debouncedSave();
  }

  void _markLearned(VocabWord word) {
    if (word.isViewed) return;
    setState(() {
      word.isViewed = true;
      final existing = _progress[word.id];
      _progress[word.id] = (existing ?? WordProgress(wordId: word.id))
          .copyWith(learned: true);
    });
    _debouncedSave();
  }

  void _debouncedSave() {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 400), () {
      widget.repo.saveProgress(_progress);
    });
  }

  Future<void> _refreshAll() async {
    setState(() {
      _setVisibleForLevel(_currentLevel);
    });
  }

  Future<void> _onWordTapped(VocabWord word) async {
    _markLearned(word);
    if (!mounted) return;
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'word-detail',
      barrierColor: Colors.black.withOpacity(0.25),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, animation, secondaryAnimation) {
        bool bookmarkedLocal = word.isBookmarked;
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Scaffold(
              backgroundColor: Colors.transparent,
              body: Stack(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.of(context).maybePop(),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(color: Colors.black.withOpacity(0.05)),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: WordDetailSoftCard(
                        word: word.de,
                        translation: word.translationFa.isNotEmpty
                            ? word.translationFa
                            : word.translationEn,
                        example: word.example,
                        extra: [
                          if (word.level != null) word.level,
                          if (word.category != null) word.category,
                        ].whereType<String>().join(' • '),
                        isBookmarked: bookmarkedLocal,
                        onToggleBookmark: () {
                          setSheetState(() {
                            bookmarkedLocal = !bookmarkedLocal;
                          });
                          _toggleBookmark(word);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final appState = context.watch<AppState>();
    final viewedCount =
        _visibleWords.where((w) => w.isViewed || w.isVisited).length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leadingWidth: 104,
        leading: Padding(
          padding: const EdgeInsetsDirectional.only(start: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              constraints:
                  const BoxConstraints(minWidth: 44, minHeight: 44),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFF8C00),
                shape: BoxShape.circle,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$viewedCount',
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_visibleWords.length}',
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.8),
                      fontSize: textTheme.bodySmall?.fontSize != null
                          ? textTheme.bodySmall!.fontSize! - 1
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        title: TextButton.icon(
          onPressed: () => _showLevelPicker(context, appState),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: const StadiumBorder(),
            backgroundColor: const Color(0xFFFF8C00),
            minimumSize: const Size(0, 44),
          ),
          icon: const Icon(LucideIcons.layers, color: Colors.white),
          label: Text(
            _currentLevel,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: (textTheme.titleMedium?.fontSize ?? 16) + 4,
              color: Colors.white,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: GestureDetector(
              onTap: () {
                _showProfileSheet(context);
              },
              child: Container(
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8C00),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.circleUserRound,
                    size: 26, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: _buildWordsTab(textTheme),
    );
  }

  Future<void> _showLevelPicker(BuildContext context, AppState appState) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            top: 24,
          ),
          child: _LevelGrid(
            levels: widget.levels,
            selectedLevel: _currentLevel,
            onSelect: (level) async {
              Navigator.of(context).pop();
              _changeLevel(level);
            },
          ),
        );
      },
    );
  }

  Future<void> _showProfileSheet(BuildContext context) async {
    final cs = Theme.of(context).colorScheme;
    final appState = context.read<AppState>();
    final user = FirebaseAuth.instance.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              top: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Text(
                    'Profile',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _LangChipBorderless(
                      label: 'English',
                      selected: (appState.appLocale?.languageCode ?? 'en') == 'en',
                      onTap: () {
                        appState.changeLocale(const Locale('en'));
                        Navigator.of(context).maybePop();
                      },
                    ),
                    const SizedBox(width: 12),
                    _LangChipBorderless(
                      label: 'فارسی',
                      selected: (appState.appLocale?.languageCode ?? 'en') == 'fa',
                      onTap: () {
                        appState.changeLocale(const Locale('fa'));
                        Navigator.of(context).maybePop();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Dark mode'),
                  value: isDark,
                  onChanged: (val) {
                    appState.setThemeMode(val ? ThemeMode.dark : ThemeMode.light);
                  },
                  secondary: const Icon(LucideIcons.moon),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(LucideIcons.refreshCw),
                  title: const Text('Reset progress'),
                  onTap: () async {
                    await appState.resetProgress();
                    setState(() {
                      for (final w in _wordsByLevel.values.expand((e) => e)) {
                        w.isBookmarked = false;
                        w.isViewed = false;
                      }
                      _progress.clear();
                      _setVisibleForLevel(_currentLevel);
                    });
                    if (mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Progress reset')),
                      );
                    }
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(user == null ? LucideIcons.logIn : LucideIcons.logOut),
                  title: Text(user == null ? 'Sign in' : 'Sign out'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    if (user == null) {
                      if (mounted) Navigator.of(context).pushNamed('/sign-in');
                    } else {
                      await FirebaseAuth.instance.signOut();
                      if (mounted) setState(() {});
                    }
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWordsTab(TextTheme textTheme) {
    if (_visibleWords.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refreshAll,
        child: ListView(
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
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
      onRefresh: _refreshAll,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 120),
        child: _WordList(
          words: _visibleWords,
          onTap: _onWordTapped,
          onBookmarkToggle: _toggleBookmark,
        ),
      ),
    );
  }

  Widget _buildProfileTab(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final appState = context.watch<AppState>();
    final user = FirebaseAuth.instance.currentUser;
    final photoUrl = user?.photoURL;
    final displayName = user?.displayName ?? 'Guest';
    final email = user?.email;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ColoredBox(
      color: Colors.white,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: cs.surface,
                        border: Border.all(color: cs.outlineVariant),
                      ),
                      child: ClipOval(
                        child: photoUrl != null
                            ? Image.network(photoUrl, fit: BoxFit.cover)
                            : Icon(LucideIcons.user, size: 32, color: cs.onSurfaceVariant),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      displayName,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    if (email != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: textTheme.bodyMedium?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.65),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _LangChipBorderless(
                    label: 'English',
                    selected: (appState.appLocale?.languageCode ?? 'en') == 'en',
                    onTap: () => appState.changeLocale(const Locale('en')),
                  ),
                  const SizedBox(width: 12),
                  _LangChipBorderless(
                    label: 'فارسی',
                    selected: (appState.appLocale?.languageCode ?? 'en') == 'fa',
                    onTap: () => appState.changeLocale(const Locale('fa')),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _MiniActionChip(
                      label: 'Dark mode',
                      child: Switch(
                        value: isDark,
                        onChanged: (val) {
                          appState.setThemeMode(val ? ThemeMode.dark : ThemeMode.light);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MiniActionChip(
                      label: 'Reset',
                      child: IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: Icon(LucideIcons.refreshCw, color: cs.onSurfaceVariant),
                        onPressed: () async {
                          await appState.resetProgress();
                          setState(() {
                            for (final w in _wordsByLevel.values.expand((e) => e)) {
                              w.isBookmarked = false;
                              w.isViewed = false;
                            }
                            _progress.clear();
                            _setVisibleForLevel(_currentLevel);
                          });
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Progress reset')),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Center(
                child: TextButton.icon(
                  onPressed: () async {
                    if (user == null) {
                      if (context.mounted) {
                        Navigator.of(context).pushNamed('/sign-in');
                      }
                    } else {
                      await FirebaseAuth.instance.signOut();
                      if (mounted) setState(() {});
                    }
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: cs.onSurface.withValues(alpha: 0.7),
                  ),
                  icon: Icon(
                    user == null ? LucideIcons.logIn : LucideIcons.logOut,
                    size: 20,
                  ),
                  label: Text(user == null ? 'Sign in' : 'Sign out'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LangChipBorderless extends StatelessWidget {
  const _LangChipBorderless({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        shape: const StadiumBorder(),
        backgroundColor: selected ? cs.primary.withValues(alpha: 0.12) : Colors.transparent,
        foregroundColor: selected ? cs.primary : cs.onSurface,
      ),
      child: Text(
        label,
        style: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MiniActionChip extends StatelessWidget {
  const _MiniActionChip({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface,
        shape: BoxShape.circle,
      ),
      child: child,
    );
  }
}

class _WordList extends StatelessWidget {
  const _WordList({
    super.key,
    required this.words,
    required this.onTap,
    required this.onBookmarkToggle,
  });

  final List<VocabWord> words;
  final ValueChanged<VocabWord> onTap;
  final ValueChanged<VocabWord> onBookmarkToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 3,
      children: List.generate(words.length, (index) {
        final word = words[index];
        return WordTile(
          word: word,
          index: index,
          onTap: () => onTap(word),
          onLongPress: () => onBookmarkToggle(word),
        );
      }),
    );
  }
}

class _LevelGrid extends StatelessWidget {
  final List<String> levels;
  final String selectedLevel;
  final ValueChanged<String> onSelect;

  const _LevelGrid({
    required this.levels,
    required this.selectedLevel,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Choose your level",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: levels.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 2.4,
          ),
          itemBuilder: (context, index) {
            final level = levels[index];
            final isSelected = level == selectedLevel;

            return GestureDetector(
              onTap: () => onSelect(level),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? cs.primary
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? cs.primary
                        : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  level,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ).copyWith(
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _InitBundle {
  final List<VocabWord> allWords;
  final Map<String, WordProgress> progress;
  final String lastLevel;
  final List<String> levels;
  final ProgressRepository repo;

  _InitBundle({
    required this.allWords,
    required this.progress,
    required this.lastLevel,
    required this.levels,
    required this.repo,
  });
}
