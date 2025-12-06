import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:word_map_app/models/vocab_word.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  int _currentIndex = 0; // 0: Words, 1: Gramatik, 2: Profile

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
      barrierColor: Colors.black.withValues(alpha: 0.35),
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
                                  color: cs.onSurface.withValues(alpha: 0.75),
                                ),
                              ),
                            ],
                            if (word.example != null && word.example!.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Text(
                                word.example!,
                                textAlign: TextAlign.center,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: cs.onSurface.withValues(alpha: 0.6),
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

    return SafeArea(
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
            color: cs.shadow.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, -2),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          child,
        ],
      ),
    );
  }
}
