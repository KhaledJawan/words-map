import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:word_map_app/models/vocab_word.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:word_map_app/services/app_state.dart';
import 'package:word_map_app/services/vocab_loader.dart';
import 'package:word_map_app/version_checker.dart';
import 'package:word_map_app/widgets/word_detail_overlay.dart';
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
  int _currentIndex = 0; // 0: Words, 1: Gramatik, 2: Profile

  @override
  void initState() {
    super.initState();
    _currentLevel = widget.level ?? '';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      VersionChecker.checkForUpdate(context);
    });
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
    showWordDetailOverlay(
      context,
      word: word.de,
      translation: word.translationFa.isNotEmpty
          ? word.translationFa
          : word.translationEn,
      example: word.example,
      extra: [
        if (word.level != null) word.level,
        if (word.category != null) word.category,
      ].whereType<String>().join(' • '),
      isBookmarked: word.isBookmarked,
      onToggleBookmark: () async {
        await context.read<AppState>().toggleBookmark(word);
        if (mounted) {
          setState(() {
            _applySort();
          });
        }
      },
    );
  }

  void _toggleBookmark(VocabWord word) async {
    await context.read<AppState>().toggleBookmark(word);
    if (!mounted) return;
    setState(() => _applySort());
  }


  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final viewedCount =
        _words.where((w) => w.isViewed || w.isVisited).length;

    return Scaffold(
      appBar: _currentIndex == 0
          ? AppBar(
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$viewedCount',
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_words.length}',
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface.withValues(alpha: 0.5),
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
              title: Text('$_currentLevel Vocabulary'),
              centerTitle: true,
            )
          : null,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildWordsTab(textTheme),
          _buildComingSoon(context, 'Gramatik'),
          _buildProfileTab(context),
        ],
      ),
      bottomNavigationBar: _BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }

  Widget _buildWordsTab(TextTheme textTheme) {
    if (_sorted.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadWords,
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
      onRefresh: _loadWords,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 120),
        child: Wrap(
          spacing: 8,
          runSpacing: 4,
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

  Widget _buildComingSoon(BuildContext context, String label) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.hourglass_empty, size: 48, color: cs.outline),
          const SizedBox(height: 12),
          Text(
            '$label - Coming soon',
            style: textTheme.titleMedium?.copyWith(color: cs.onSurface),
          ),
        ],
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
                            : Icon(Icons.person, size: 44, color: cs.onSurfaceVariant),
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
                        icon: Icon(Icons.restart_alt, color: cs.onSurfaceVariant),
                        onPressed: () async {
                          await appState.resetProgress();
                          setState(() {
                            for (final w in _words) {
                              w.isBookmarked = false;
                              w.isViewed = false;
                            }
                            _applySort();
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
                    user == null ? Icons.login : Icons.logout,
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

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? cs.surfaceContainerHighest : cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 6,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: cs.primary,
        unselectedItemColor: cs.onSurfaceVariant,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Words'),
          BottomNavigationBarItem(icon: Icon(Icons.text_snippet), label: 'Gramatik'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
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
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 32, maxWidth: 48),
            child: Align(
              alignment: Alignment.centerRight,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
