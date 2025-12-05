import 'package:flutter/material.dart';
import 'package:word_map_app/models/vocab_word.dart';

class WordDetailScreen extends StatelessWidget {
  final VocabWord word;

  const WordDetailScreen({super.key, required this.word});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(word.word),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (word.image.isNotEmpty)
              Center(
                child: Image.asset(
                  'assets${word.image}',
                  height: 150,
                ),
              ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                title: const Text('Word'),
                subtitle: Text(word.word, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('Translation (FA)'),
                subtitle: Text(word.translation_fa, style: const TextStyle(fontSize: 18)),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('Translation (EN)'),
                subtitle: Text(word.translation_en, style: const TextStyle(fontSize: 18)),
              ),
            ),
            if (word.example != null && word.example!.isNotEmpty)
              Card(
                child: ListTile(
                  title: const Text('Example'),
                  subtitle: Text(word.example!, style: const TextStyle(fontSize: 16)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}