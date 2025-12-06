import 'package:flutter/material.dart';

class IosPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const IosPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(label),
    );
  }
}

class IosSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const IosSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
