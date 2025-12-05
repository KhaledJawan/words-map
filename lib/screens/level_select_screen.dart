import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:word_map_app/services/app_state.dart';

class LevelSelectScreen extends StatelessWidget {
  const LevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose your level'),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding:
            const EdgeInsetsDirectional.symmetric(horizontal: 20, vertical: 24),
        itemBuilder: (context, index) {
          final level = appState.levels[index];
          final selected = level == appState.currentLevel;
          return InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () async {
              await appState.setCurrentLevel(level);
              if (!context.mounted) return;
              Navigator.of(context).pushReplacementNamed(
                '/words',
                arguments: level,
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: selected ? cs.primary : cs.surface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: selected ? cs.primary : cs.outline,
                  width: 1.1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      level,
                      style: textTheme.titleMedium?.copyWith(
                        color: selected ? cs.onPrimary : cs.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right,
                      color: selected ? cs.onPrimary : cs.onSurface),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemCount: appState.levels.length,
      ),
    );
  }
}
