import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignInOrSkipScreen extends StatelessWidget {
  const SignInOrSkipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isSignedIn = FirebaseAuth.instance.currentUser != null;

    return Scaffold(
      backgroundColor: cs.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: 24, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Connect your account',
                    textAlign: TextAlign.center,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Sign in to sync and recover your history. You can also continue without an account.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyLarge?.copyWith(
                      color: cs.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 36),
                  ElevatedButton(
                    onPressed: () =>
                        Navigator.of(context).pushNamed('/sign-in'),
                    child: const Text('Sign in'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context)
                        .pushReplacementNamed('/levels'),
                    child: const Text('Skip and start'),
                  ),
                  if (isSignedIn) ...[
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Navigator.of(context)
                          .pushReplacementNamed('/levels'),
                      child: const Text('Already signed in? Continue'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
