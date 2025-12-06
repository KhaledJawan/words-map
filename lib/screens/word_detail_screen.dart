import 'package:flutter/material.dart';
import 'package:word_map_app/widgets/word_detail_card.dart';

class WordDetailScreen extends StatelessWidget {
  final String word;
  final String translation;
  final String? example;
  final String? extra;

  const WordDetailScreen({
    super.key,
    required this.word,
    required this.translation,
    this.example,
    this.extra,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF141E30), Color(0xFF243B55)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: WordDetailGlassCard(
                word: word,
                translation: translation,
                example: example,
                extra: extra,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
