import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:word_map_app/services/app_state.dart';
import 'package:word_map_app/ui/ios_card.dart';

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
        physics: const BouncingScrollPhysics(),
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
              child: IosCard(
                padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: 20, vertical: 16),
                color: Colors.white,
                enableShadow: true,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        level,
                        style: textTheme.titleMedium?.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.black87),
                  ],
                ),
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
