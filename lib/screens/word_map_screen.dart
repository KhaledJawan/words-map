// Invalidate cache
import 'dart:ui';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:word_map_app/widgets/word_tile.dart';
import '../models/vocab_word.dart';
import '../services/vocab_loader.dart';
import '../services/app_state.dart';
import '../widgets/float_box_panel.dart';

class WordMapScreen extends StatefulWidget {
  const WordMapScreen({
    super.key,
    this.initialLevel,
    this.currentLocale,
    this.onLocaleChanged,
  });

  final String? initialLevel;
  final Locale? currentLocale;
  final ValueChanged<Locale>? onLocaleChanged;

  @override
  State<WordMapScreen> createState() => _WordMapScreenState();
}

class _WordMapScreenState extends State<WordMapScreen> {
  List<VocabWord> _words = [];
  bool _loading = true;
  bool _menuOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWords();
    });
  }

  Future<void> _loadWords() async {
    final appState = context.read<AppState>();
    setState(() {
      _loading = true;
    });
    final words = await loadWordsForLevel(appState.currentLevel);
    for (final word in words) {
      word.isBookmarked = appState.isBookmarked(word);
    }
    if (mounted) {
      setState(() {
        _words = words;
        _loading = false;
      });
    }
  }

  Future<void> _showWordDialog(VocabWord word) async {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final textTheme = theme.textTheme;

    setState(() {
      word.isVisited = true;
    });

    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Word details',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
            child: ScaleTransition(
              scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
              child: AlertDialog(
                backgroundColor: cs.surface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              title: Hero(
                  tag: 'word-${word.id}',
                  child: Material(
                    color: Colors.transparent,
                    child: Text(word.de,
                        textAlign: TextAlign.center,
                        style: textTheme.headlineSmall
                            ?.copyWith(color: cs.onSurface)),
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
                        style: textTheme.bodyLarge
                            ?.copyWith(color: cs.onSurface.withOpacity(0.8)),
                      ),
                    ],
                  ],
                ),
                actionsAlignment: MainAxisAlignment.center,
                actions: [
                  FilledButton.icon(
                    onPressed: () {
                      context.read<AppState>().toggleBookmark(word);
                      Navigator.of(context).pop();
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: cs.surface,
                      foregroundColor: cs.onSurface,
                      side: BorderSide(color: cs.outline),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                    icon: Icon(
                      context.watch<AppState>().isBookmarked(word)
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                    ),
                    label: Text(
                      context.watch<AppState>().isBookmarked(word)
                          ? 'Bookmarked'
                          : 'Bookmark',
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Level ${appState.currentLevel}'),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                final tileWidth = 140.0;
                final tileHeight = 72.0;
                final columns = 10;
                final rows = (_words.length / columns).ceil();
                final gridWidth =
                    columns * (tileWidth + 16) + 32; // include padding
                final gridHeight = rows * (tileHeight + 16) + 32;

                return Stack(
                  children: [
                    Positioned.fill(
                      child: InteractiveViewer(
                        minScale: 0.6,
                        maxScale: 2.5,
                        boundaryMargin: const EdgeInsets.all(240),
                        child: Center(
                          child: SizedBox(
                            width: gridWidth,
                            height: gridHeight,
                            child: GridView.builder(
                              padding:
                                  const EdgeInsetsDirectional.all(16),
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                mainAxisExtent: tileHeight,
                              ),
                              itemCount: _words.length,
                              itemBuilder: (context, index) {
                                final word = _words[index];
                                return WordTile(
                                  word: word,
                                  index: index,
                                  onTap: () => _showWordDialog(word),
                                  onLongPress: () => appState.toggleBookmark(word),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    _FloatingMenu(
                      open: _menuOpen,
                      onToggle: () => setState(() => _menuOpen = !_menuOpen),
                      onProfile: () => _showProfileHint(context),
                      onToggleTheme: _toggleTheme,
                      onSelectLevel: () => _showLevelPicker(context),
                    ),
                  ],
                );
              },
            ),
    );
  }

  void _showLevelPicker(BuildContext context) {
    final appState = context.read<AppState>();
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView.builder(
          itemCount: appState.levels.length,
          itemBuilder: (context, index) {
            final level = appState.levels[index];
            return ListTile(
              title: Text(level),
              onTap: () {
                appState.setCurrentLevel(level);
                _loadWords();
                Navigator.pop(context);
              },
              trailing: appState.currentLevel == level
                  ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                  : null,
            );
          },
        );
      },
    );
  }

  void _toggleTheme() {
    final appState = context.read<AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    appState.setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
  }

  void _showProfileHint(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile screen coming soon.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _FloatingMenu extends StatelessWidget {
  const _FloatingMenu({
    required this.open,
    required this.onToggle,
    required this.onProfile,
    required this.onToggleTheme,
    required this.onSelectLevel,
  });

  final bool open;
  final VoidCallback onToggle;
  final VoidCallback onProfile;
  final VoidCallback onToggleTheme;
  final VoidCallback onSelectLevel;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final actions = [
      _MenuAction(label: 'Profile', icon: Icons.person, onTap: onProfile),
      _MenuAction(label: 'Dark mode', icon: Icons.dark_mode, onTap: onToggleTheme),
      _MenuAction(label: 'Levels', icon: Icons.layers, onTap: onSelectLevel),
    ];

    return Positioned(
      right: 20,
      bottom: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: open
                ? Padding(
                    key: const ValueKey('menu-open'),
                    padding: const EdgeInsetsDirectional.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: actions
                          .map(
                            (action) => Padding(
                              padding:
                                  const EdgeInsetsDirectional.only(bottom: 10),
                              child: _MiniActionButton(action: action),
                            ),
                          )
                          .toList(),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          FloatingActionButton(
            onPressed: onToggle,
            backgroundColor: cs.primary,
            foregroundColor: cs.onPrimary,
            elevation: 4,
            shape: const StadiumBorder(),
            child: AnimatedRotation(
              duration: const Duration(milliseconds: 200),
              turns: open ? 0.125 : 0,
              child: const Icon(Icons.add),
            ),
          ),
        ],
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

class _MiniActionButton extends StatelessWidget {
  const _MiniActionButton({required this.action});

  final _MenuAction action;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedScale(
      duration: const Duration(milliseconds: 160),
      scale: 1.0,
      child: Material(
        color: cs.surface,
        borderRadius: BorderRadius.circular(999),
        elevation: 1,
        child: InkWell(
          onTap: action.onTap,
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
                horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(action.icon, size: 18, color: cs.onSurface),
                const SizedBox(width: 10),
                Text(
                  action.label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
