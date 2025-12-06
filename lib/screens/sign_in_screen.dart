import 'dart:developer' as developer;
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart' hide generateNonce;
import 'package:word_map_app/services/app_state.dart';
import 'package:word_map_app/utils/crypto_utils.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  String? _errorText;
  bool _loading = false;
  String _selectedLanguage = 'en';

  bool _isAppleSupported() => Platform.isIOS || Platform.isMacOS;

  Future<UserCredential> signInWithGoogle() async {
    developer.log('Attempting Google Sign-In', name: 'SignInScreen');
    final googleUser = await GoogleSignIn(
      scopes: const ['email'],
      // Web client ID from google-services.json (client_type 3) for com.merlinict.wordmap
      serverClientId:
          '416969091812-vc4j03q7e77g8557f0ure6il3gvcnqf3.apps.googleusercontent.com',
    ).signIn();
    if (googleUser == null) {
      throw FirebaseAuthException(
          code: 'ERROR_ABORTED_BY_USER', message: 'Google Sign-In cancelled');
    }
    final googleAuth = await googleUser.authentication;

    if (googleAuth.accessToken == null || googleAuth.idToken == null) {
      throw FirebaseAuthException(
          code: 'NO_AUTH_TOKEN', message: 'Failed to obtain authentication tokens');
    }

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken!,
      idToken: googleAuth.idToken!,
    );
    developer.log('Google credentials obtained, signing into Firebase',
        name: 'SignInScreen');
    return FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<UserCredential> signInWithApple() async {
    developer.log('Attempting Apple Sign-In', name: 'SignInScreen');
    try {
      final rawNonce = generateNonce();
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName
        ],
        nonce: sha256ofString(rawNonce),
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      return FirebaseAuth.instance.signInWithCredential(oauthCredential);
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw FirebaseAuthException(
            code: 'ERROR_ABORTED_BY_USER', message: 'Apple Sign-In cancelled');
      }
      developer.log('Apple Sign-In failed: $e', name: 'SignInScreen', error: e);
      rethrow;
    } catch (e) {
      developer.log('Apple Sign-In failed: $e', name: 'SignInScreen', error: e);
      rethrow;
    }
  }

  Future<void> _handleAuth(Future<UserCredential> Function() action) async {
    setState(() {
      _loading = true;
      _errorText = null;
    });
    try {
      await action();
      if (!mounted) return;
      developer.log('Auth successful', name: 'SignInScreen');
      Navigator.of(context).pushReplacementNamed('/levels');
    } on FirebaseAuthException catch (e) {
      developer.log('Firebase auth error: ${e.code} - ${e.message}',
          name: 'SignInScreen', error: e);
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found for that email.';
          break;
        case 'wrong-password':
          message = 'Wrong password provided.';
          break;
        case 'email-already-in-use':
          message = 'An account already exists for that email.';
          break;
        default:
          message = e.message ?? 'An unknown authentication error occurred.';
      }
      setState(() => _errorText = message);
    } catch (e) {
      developer.log('General auth error: $e', name: 'SignInScreen', error: e);
      setState(() => _errorText = e.toString());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _handleAppleSignIn() async {
    await _handleAuth(() => signInWithApple());
  }

  Future<void> _handleGoogleSignIn() async {
    await _handleAuth(() => signInWithGoogle());
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    _selectedLanguage = appState.appLocale?.languageCode ?? _selectedLanguage;
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: 24, vertical: 24),
              child: ConstrainedBox(
                constraints:
                    BoxConstraints(minHeight: constraints.maxHeight - 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 24),
                    _LanguageToggleRow(
                      selected: _selectedLanguage,
                      onSelect: _loading
                          ? null
                          : (value) {
                              setState(() => _selectedLanguage = value);
                              context.read<AppState>().changeLocale(Locale(value));
                            },
                    ),
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: _loading
                          ? null
                          : () => Navigator.of(context)
                              .pushReplacementNamed('/levels'),
                      child: Text(
                        'Skip',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: cs.primary, fontWeight: FontWeight.w700),
                      ),
                    ),
                    SocialSignInRow(
                      onGoogle: _loading ? null : _handleGoogleSignIn,
                      onApple: _loading || !_isAppleSupported()
                          ? null
                          : _handleAppleSignIn,
                      showApple: _isAppleSupported(),
                    ),
                    if (_errorText != null) ...[
                      const SizedBox(height: 16),
                      _buildErrorBanner(context),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.map,
              color: cs.primary,
              size: 28,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'WordMap',
          textAlign: TextAlign.center,
          style: textTheme.headlineSmall?.copyWith(
            color: cs.onSurface,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Learn German vocabulary fast and easily.',
          textAlign: TextAlign.center,
          style: textTheme.bodyLarge?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorBanner(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _errorText ?? '',
        style: textTheme.bodyMedium?.copyWith(color: cs.onErrorContainer),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class SocialSignInRow extends StatelessWidget {
  const SocialSignInRow({
    super.key,
    required this.onGoogle,
    required this.onApple,
    required this.showApple,
  });

  final VoidCallback? onGoogle;
  final VoidCallback? onApple;
  final bool showApple;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Or continue with',
          style: textTheme.labelLarge
              ?.copyWith(color: cs.onSurface.withValues(alpha: 0.7)),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SocialIconButton(
              label: 'Google',
              icon: const Icon(Icons.g_mobiledata, size: 22),
              onPressed: onGoogle,
            ),
            if (showApple) ...[
              const SizedBox(width: 12),
              _SocialIconButton(
                label: 'Apple',
                icon: const Icon(Icons.apple, size: 20),
                onPressed: onApple,
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _LanguageToggleRow extends StatelessWidget {
  const _LanguageToggleRow({
    required this.selected,
    required this.onSelect,
  });

  final String selected;
  final ValueChanged<String>? onSelect;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LanguagePill(
          label: 'English',
          value: 'en',
          selected: selected == 'en',
          onTap: onSelect,
          cs: cs,
          textTheme: textTheme,
        ),
        const SizedBox(width: 12),
        _LanguagePill(
          label: 'فارسی',
          value: 'fa',
          selected: selected == 'fa',
          onTap: onSelect,
          cs: cs,
          textTheme: textTheme,
        ),
      ],
    );
  }
}

class _LanguagePill extends StatelessWidget {
  const _LanguagePill({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
    required this.cs,
    required this.textTheme,
  });

  final String label;
  final String value;
  final bool selected;
  final ValueChanged<String>? onTap;
  final ColorScheme cs;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? cs.primary : Colors.transparent,
      shape: const StadiumBorder(
        side: BorderSide(color: Colors.transparent),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap == null ? null : () => onTap!(value),
        child: Container(
          padding:
              const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? cs.primary : cs.outline.withValues(alpha: 0.7),
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: cs.primary.withValues(alpha: 0.18),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    )
                  ]
                : null,
          ),
          child: Text(
            label,
            style: textTheme.labelLarge?.copyWith(
              color: selected ? cs.onPrimary : cs.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialIconButton extends StatelessWidget {
  const _SocialIconButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final Widget icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return SizedBox(
      height: 44,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          side: BorderSide(color: cs.outline.withValues(alpha: 0.7)),
          foregroundColor: cs.onSurface,
          backgroundColor: cs.surface,
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const SizedBox(width: 8),
            Text(
              label,
              style: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
