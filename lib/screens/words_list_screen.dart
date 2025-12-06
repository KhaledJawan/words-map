import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:word_map_app/models/vocab_word.dart';
import 'package:word_map_app/services/app_state.dart';
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
  List<VocabWord> _words = [];
  List<VocabWord> _sorted = [];
  SortMode _sortMode = SortMode.defaultOrder;
  late String _currentLevel;

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
    appState.markViewed(word);
    setState(() {});
    if (!mounted) return;
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'word-detail',
      barrierColor: Colors.black.withOpacity(0.25),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, animation, secondaryAnimation) {
        return GestureDetector(
          onTap: () => Navigator.of(context).maybePop(),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              children: [
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(color: Colors.black.withOpacity(0.05)),
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
                      isBookmarked: word.isBookmarked,
                      onToggleBookmark: () async {
                        await context.read<AppState>().toggleBookmark(word);
                        if (mounted) setState(() {});
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
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

  void _toggleBookmark(VocabWord word) async {
    await context.read<AppState>().toggleBookmark(word);
    if (!mounted) return;
    setState(() => _applySort());
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final appState = context.watch<AppState>();
    final viewedCount =
        _words.where((w) => w.isViewed || w.isVisited).length;

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 104,
        leading: Padding(
          padding: const EdgeInsetsDirectional.only(start: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              constraints:
                  const BoxConstraints(minWidth: 42, minHeight: 42),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: cs.surfaceVariant.withValues(alpha: 0.45),
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
        title: TextButton.icon(
          onPressed: () => _showLevelPicker(context, appState),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: const StadiumBorder(),
            backgroundColor: cs.surfaceVariant.withValues(alpha: 0.2),
          ),
          icon: Icon(LucideIcons.layers, color: cs.onSurface),
          label: Text(
            _currentLevel,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: (textTheme.titleMedium?.fontSize ?? 16) + 4,
              color: cs.onSurface,
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.circleUserRound, size: 30),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => Scaffold(
                    appBar: AppBar(
                      title: const Text('Profile'),
                      centerTitle: true,
                    ),
                    body: _buildProfileTab(context),
                  ),
                ),
              );
            },
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
            levels: appState.levels,
            selectedLevel: _currentLevel,
            onSelect: (level) async {
              Navigator.of(context).pop();
              if (level == _currentLevel) return;
              await appState.setCurrentLevel(level);
              setState(() => _currentLevel = level);
              await _loadWords();
            },
          ),
        );
      },
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
          runSpacing: 3,
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
                    ? Icon(LucideIcons.check)
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
                    ? Icon(LucideIcons.check)
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
                    ? Icon(LucideIcons.check)
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
                    ? Icon(LucideIcons.check)
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
          Icon(LucideIcons.hourglass, size: 48, color: cs.outline),
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
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
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
