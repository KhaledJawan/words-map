import 'package:flutter/material.dart';

class GrammatikScreen extends StatelessWidget {
  const GrammatikScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gramatik'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Coming soon',
            style: textTheme.headlineSmall?.copyWith(
              color: cs.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
