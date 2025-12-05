import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

import 'screens/sign_in_screen.dart';
import 'screens/words_list_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({
    super.key,
    required this.currentLocale,
    required this.onLocaleChanged,
    required this.initialLevel,
  });

  final Locale currentLocale;
  final ValueChanged<Locale> onLocaleChanged;
  final String initialLevel;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        developer.log(
          'AuthGate snapshot - connectionState: ${snapshot.connectionState}, data: ${snapshot.data}',
          name: 'AuthGate',
        );

        // Handle connection states
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Handle errors
        if (snapshot.hasError) {
          developer.log('AuthGate error: ${snapshot.error}',
              name: 'AuthGate', error: snapshot.error);
          return Scaffold(
            body: Center(
              child: Text('Authentication error: ${snapshot.error}'),
            ),
          );
        }

        // Check if user is authenticated
        final user = snapshot.data;
        if (user == null) {
          return const SignInScreen();
        }

        developer.log('User authenticated: ${user.email}', name: 'AuthGate');
        return WordsListScreen(level: initialLevel);
      },
    );
  }
}
