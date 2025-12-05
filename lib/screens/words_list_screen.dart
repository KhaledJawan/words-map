import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:word_map_app/models/vocab_word.dart';
import 'package:word_map_app/screens/language_onboarding_screen.dart';
import 'package:word_map_app/screens/level_select_screen.dart';
import 'package:word_map_app/screens/settings_screen.dart';
import 'package:word_map_app/screens/sign_in_or_skip_screen.dart';
import 'package:word_map_app/screens/sign_in_screen.dart';
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
  bool _loading = true;
  SortMode _sortMode = SortMode.defaultOrder;
  late String _currentLevel;

  @override
  void initState() {
    super.initState();
    _currentLevel = widget.level ?? '';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWords();
    });
  }

  Future<void> _loadWords() async {
    final appState = context.read<AppState>();
    final level = widget.level ?? appState.currentLevel;
    setState(() {
      _loading = true;
      _currentLevel = level;
    });

    final words = await loadWordsForLevel(level);
    for (final w in words) {
      w.isBookmarked = appState.isBookmarked(w);
      w.isViewed = appState.isViewed(w);
    }
    if (!mounted) return;
    setState(() {
      _words = words;
      _applySort();
      _loading = false;
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
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        final isBookmarked = context.watch<AppState>().isBookmarked(word);
        return Dialog(
          backgroundColor: cs.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsetsDirectional.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                    await context.read<AppState>().toggleBookmark(word);
                    if (mounted) {
                      setState(() => _applySort());
                    }
                    if (context.mounted) Navigator.of(context).pop();
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
    final actions = <_MenuAction>[
      _MenuAction(
        icon: Icons.layers,
        label: 'Levels',
        onTap: _openLevelSelect,
      ),
    ];

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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadWords,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding:
                    const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 120),
                child: _sorted.isEmpty
                    ? Padding(
                        padding: const EdgeInsetsDirectional.only(top: 32),
                        child: Text(
                          'No words found for this level.',
                          style: textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      )
                    : Wrap(
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
            ),
      floatingActionButton: _FabMenu(
        viewedCount: viewedCount,
        totalCount: _words.length,
        bookmarkedCount: bookmarkedCount,
        actions: actions,
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

class _FabMenu extends StatefulWidget {
  const _FabMenu({
    required this.viewedCount,
    required this.totalCount,
    required this.bookmarkedCount,
    required this.actions,
  });

  final int viewedCount;
  final int totalCount;
  final int bookmarkedCount;
  final List<_MenuAction> actions;

  @override
  State<_FabMenu> createState() => _FabMenuState();
}

class _FabMenuState extends State<_FabMenu>
    with SingleTickerProviderStateMixin {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Stack(
      children: [
        if (_open)
          Positioned.fill(
            child: GestureDetector(
              onTap: () => setState(() => _open = false),
              behavior: HitTestBehavior.opaque,
            ),
          ),
        Positioned(
          right: 20,
          bottom: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: _open
                    ? Column(
                        key: const ValueKey('menu-open'),
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          ..._buildMenuButtons(widget.actions),
                          const SizedBox(height: 12),
                          _StatChip(
                            label:
                                'Viewed ${widget.viewedCount}/${widget.totalCount}',
                          ),
                          const SizedBox(height: 6),
                          _StatChip(
                            label: 'Bookmarks ${widget.bookmarkedCount}',
                          ),
                          const SizedBox(height: 12),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
              FloatingActionButton(
                onPressed: () => setState(() => _open = !_open),
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                shape: const StadiumBorder(),
                child: AnimatedRotation(
                  duration: const Duration(milliseconds: 180),
                  turns: _open ? 0.125 : 0,
                  child: const Icon(Icons.add),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildMenuButtons(List<_MenuAction> actions) {
    final List<Widget> widgets = [];
    for (var i = 0; i < actions.length; i++) {
      final action = actions[i];
      widgets.add(
        _MiniButton(
          icon: action.icon,
          label: action.label,
          onTap: () {
            action.onTap();
            setState(() => _open = false);
          },
        ),
      );
      if (i != actions.length - 1) {
        widgets.add(const SizedBox(height: 8));
      }
    }
    return widgets;
  }
}

class _MiniButton extends StatelessWidget {
  const _MiniButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: cs.surface,
      shape: const StadiumBorder(),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
              horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: cs.onSurface),
              const SizedBox(width: 8),
              Text(
                label,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuAction {
  const _MenuAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
          horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.outline),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
