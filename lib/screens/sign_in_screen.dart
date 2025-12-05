import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:word_map_app/l10n/app_localizations.dart';
import 'package:word_map_app/widgets/or_divider.dart';
import 'package:word_map_app/widgets/social_sign_in_button.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _errorText;
  bool _loading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      developer.log('Firebase auth error: ${e.code} - ${e.message}', name: 'SignInScreen', error: e);
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
      setState(() => _errorText = 'An unknown error occurred.');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  bool _isAppleSupported() {
    final platform = Theme.of(context).platform;
    return platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
  }

  Future<void> _submitEmailSignIn() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await _handleAuth(() => FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text));
  }

  Future<void> _submitEmailSignUp() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await _handleAuth(() => FirebaseAuth.instance
        .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text));
  }

  Future<void> _handleForgotPassword() async {
    // Placeholder for actual reset flow.
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('TODO: Implement password reset flow.'),
    ));
  }

  Future<void> _handleAppleSignIn() async {
    await _handleAuth(() async {
      developer.log('Attempting Apple Sign-In', name: 'SignInScreen');
      try {
        // For now, show a placeholder message
        throw FirebaseAuthException(
          code: 'APPLE_SIGNIN_NOT_IMPLEMENTED',
          message: 'Apple Sign-In will be implemented with native integration.',
        );
      } catch (e) {
        developer.log('Apple Sign-In error: $e',
            name: 'SignInScreen', error: e);
        rethrow;
      }
    });
  }

  Future<void> _handleGoogleSignIn() async {
    await _handleAuth(() async {
      developer.log('Attempting Google Sign-In', name: 'SignInScreen');
      try {
        final googleUser = await GoogleSignIn(
          serverClientId:
              '334590881340-ov46308avn8gccjb4tqd1fvh6m6jc4mt.apps.googleusercontent.com',
        ).signIn();
        if (googleUser == null) {
          developer.log('Google Sign-In cancelled by user',
              name: 'SignInScreen');
          throw FirebaseAuthException(
              code: 'ERROR_ABORTED_BY_USER',
              message: 'Google Sign-In cancelled');
        }
        developer.log('Google user signed in: ${googleUser.email}',
            name: 'SignInScreen');
        final googleAuth = await googleUser.authentication;

        if (googleAuth.accessToken == null || googleAuth.idToken == null) {
          throw FirebaseAuthException(
              code: 'NO_AUTH_TOKEN',
              message: 'Failed to obtain authentication tokens');
        }

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken!,
          idToken: googleAuth.idToken!,
        );
        developer.log(
            'Google credentials obtained, signing into Firebase',
            name: 'SignInScreen');
        return FirebaseAuth.instance.signInWithCredential(credential);
      } catch (e) {
        developer.log('Google Sign-In failed: $e',
            name: 'SignInScreen', error: e);
        rethrow;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsetsDirectional.symmetric(horizontal: 24, vertical: 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 560, minHeight: constraints.maxHeight * 0.8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeOut,
                    padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: 24, vertical: 28),
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: cs.outline.withOpacity(0.6)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildHeader(context),
                        const SizedBox(height: 24),
                        _buildForm(context),
                        const SizedBox(height: 28),
                        _buildSocialSignIn(context),
                        const SizedBox(height: 24),
                        _buildSignUpCta(context),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: AlignmentDirectional.center,
          child: Container(
            padding: const EdgeInsetsDirectional.symmetric(
                horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: cs.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: cs.outline.withOpacity(0.5)),
            ),
            child: Icon(Icons.lock_outline, color: cs.onSurface, size: 20),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          loc.authConnectTitle,
          textAlign: TextAlign.center,
          style: textTheme.headlineSmall?.copyWith(
            color: cs.onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Sign in to sync and back up your progress.',
          textAlign: TextAlign.center,
          style: textTheme.bodyLarge?.copyWith(
            color: cs.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildForm(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            enabled: !_loading,
            decoration: InputDecoration(
              labelText: loc.authEmail,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty || !value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            autofillHints: const [AutofillHints.password],
            enabled: !_loading,
            decoration: InputDecoration(
              labelText: loc.authPassword,
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                onPressed: !_loading ? () => setState(() => _obscurePassword = !_obscurePassword) : null,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty || value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(
              onPressed: _loading ? null : _handleForgotPassword,
              child: Text(loc.authForgotPassword),
            ),
          ),
          if (_errorText != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _errorText!,
                style: textTheme.bodyMedium?.copyWith(color: cs.onErrorContainer),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _loading ? null : _submitEmailSignIn,
              child: _loading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : Text('Sign in with email'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialSignIn(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Column(
      children: [
        OrDivider(label: loc.authOrSeparator),
        const SizedBox(height: 24),
        _GoogleSignInButton(
          onPressed: _loading ? null : _handleGoogleSignIn,
        ),
        if (_isAppleSupported()) ...[
          const SizedBox(height: 12),
          SocialSignInButton(
            label: loc.authSignInWithApple,
            icon: const Icon(Icons.apple, size: 24),
            onPressed: _loading ? null : _handleAppleSignIn,
          ),
        ],
      ],
    );
  }

  Widget _buildSignUpCta(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return TextButton(
      onPressed: _loading ? null : _submitEmailSignUp,
      child: Text(
        loc.authNoAccountCta,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _GoogleSignInButton extends StatelessWidget {
  const _GoogleSignInButton({this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    return SocialSignInButton(
      label: AppLocalizations.of(context)!.authSignInWithGoogle,
      icon: Image.asset(
        'assets/google/btn_google_light_normal.png',
        height: 24,
        width: 24,
      ),
      onPressed: onPressed,
      backgroundColor: isDark ? cs.surface : Colors.white,
      foregroundColor: isDark ? cs.onSurface : const Color(0xFF3C4043),
      borderColor: isDark ? cs.outline : const Color(0xFFDADCE0),
    );
  }
}
