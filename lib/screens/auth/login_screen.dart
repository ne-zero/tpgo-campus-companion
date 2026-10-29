import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/auth_hero_image.dart';
import '../../widgets/auth_text_field.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/guest_access_card.dart';
import '../../widgets/social_login_button.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

// login page for tp go
// users can login using email/password, google, github, or guest access
//
// navigation to the main app is handled automatically by AuthGate
// after firebase auth state changes
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({
    super.key,
  });

  static const String routeName = '/login';

  @override
  ConsumerState<LoginScreen> createState() {
    return _LoginScreenState();
  }
}

class _LoginScreenState
    extends ConsumerState<LoginScreen> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  bool _isLoading = false;
  bool _hidePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  // changes firebase error codes into simple messages
  String _firebaseErrorMessage(
    FirebaseAuthException error,
  ) {
    if (error.code == 'invalid-email') {
      return 'Please enter a valid email address.';
    }

    if (error.code == 'invalid-credential') {
      return 'Invalid email or password.';
    }

    if (error.code == 'user-not-found') {
      return 'No account found with this email.';
    }

    if (error.code == 'wrong-password') {
      return 'Incorrect password.';
    }

    if (error.code == 'operation-not-allowed') {
      return 'This sign-in method is not enabled in Firebase.';
    }

    if (error.code ==
        'account-exists-with-different-credential') {
      return 'This email is already linked to another sign-in method.';
    }

    if (error.code == 'credential-already-in-use') {
      return 'This sign-in account is already linked to another Firebase user.';
    }

    if (error.code == 'popup-closed-by-user') {
      return 'Sign-in popup was closed.';
    }

    if (error.code == 'cancelled-popup-request') {
      return 'Sign-in was cancelled.';
    }

    if (error.code == 'network-request-failed') {
      return 'Network error. Please check your internet connection.';
    }

    return error.message ??
        'Authentication failed.';
  }

  // shows feedback messages to the user
  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
        .clearSnackBars();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Colors.red
            : const Color(0xFF2637FF),
      ),
    );
  }

  // normal email and password login
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      await ref
          .read(firebaseServiceProvider)
          .login(
            email:
                _emailController.text.trim(),
            password:
                _passwordController.text,
          );

      // do not navigate manually
      // AuthGate sees the firebase login and shows MainScreen
    } on FirebaseAuthException catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(
        _firebaseErrorMessage(error),
        isError: true,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Login failed. Please try again.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // google sign in
  Future<void> _loginWithGoogle() async {
    if (_isLoading) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      await ref
          .read(firebaseServiceProvider)
          .signInWithGoogle();

      // AuthGate handles navigation after firebase signs in
    } on FirebaseAuthException catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(
        _firebaseErrorMessage(error),
        isError: true,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Google login was cancelled or failed.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // github sign in
  Future<void> _loginWithGitHub() async {
    if (_isLoading) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      await ref
          .read(firebaseServiceProvider)
          .signInWithGitHub();

      // AuthGate handles navigation after firebase signs in
    } on FirebaseAuthException catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(
        _firebaseErrorMessage(error),
        isError: true,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'GitHub login was cancelled or failed.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // guest access using firebase anonymous login
  Future<void> _continueAsGuest() async {
    if (_isLoading) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      await ref
          .read(firebaseServiceProvider)
          .signInAsGuest();

      // AuthGate handles navigation after firebase signs in
    } on FirebaseAuthException catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(
        _firebaseErrorMessage(error),
        isError: true,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Guest access failed. Please try again.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String? _validateEmail(
    String? value,
  ) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'Please enter your email.';
    }

    final email =
        value.trim();

    if (!email.contains('@') ||
        !email.contains('.')) {
      return 'Please enter a valid email.';
    }

    return null;
  }

  String? _validatePassword(
    String? value,
  ) {
    if (value == null ||
        value.isEmpty) {
      return 'Please enter your password.';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters.';
    }

    return null;
  }

  Widget _buildLoginCard() {
    final theme =
        Theme.of(context);

    final colors =
        theme.colorScheme;

    final isDark =
        theme.brightness ==
            Brightness.dark;

    return Container(
      margin:
          const EdgeInsets.fromLTRB(
        18,
        0,
        18,
        24,
      ),
      padding:
          const EdgeInsets.fromLTRB(
        26,
        28,
        26,
        26,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius:
            BorderRadius.circular(34),
        border: isDark
            ? Border.all(
                color:
                    colors.outlineVariant,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withValues(
              alpha:
                  isDark ? 0.22 : 0.08,
            ),
            blurRadius: 24,
            offset:
                const Offset(
              0,
              12,
            ),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Align(
              alignment:
                  Alignment.centerLeft,
              child: Text(
                'Welcome back!',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight:
                      FontWeight.w900,
                  color:
                      colors.onSurface,
                ),
              ),
            ),

            const SizedBox(height: 8),

            Align(
              alignment:
                  Alignment.centerLeft,
              child: Text(
                'Log in to continue your smart campus journey.',
                style: TextStyle(
                  fontSize: 15,
                  color: colors
                      .onSurfaceVariant,
                  fontWeight:
                      FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 26),

            AuthTextField(
              controller:
                  _emailController,
              hintText: 'Email',
              icon:
                  Icons.mail_outline,
              validator:
                  _validateEmail,
              keyboardType:
                  TextInputType
                      .emailAddress,
            ),

            const SizedBox(height: 14),

            AuthTextField(
              controller:
                  _passwordController,
              hintText: 'Password',
              icon:
                  Icons.lock_outline,
              validator:
                  _validatePassword,
              keyboardType:
                  TextInputType
                      .visiblePassword,
              obscureText:
                  _hidePassword,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _hidePassword =
                        !_hidePassword;
                  });
                },
                icon: Icon(
                  _hidePassword
                      ? Icons
                          .visibility_outlined
                      : Icons
                          .visibility_off_outlined,
                  color: colors
                      .onSurfaceVariant,
                ),
              ),
            ),

            const SizedBox(height: 8),

            Align(
              alignment:
                  Alignment.centerRight,
              child: TextButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        Navigator.of(
                          context,
                        ).pushNamed(
                          ForgotPasswordScreen
                              .routeName,
                        );
                      },
                child: Text(
                  'Forgot password?',
                  style: TextStyle(
                    fontWeight:
                        FontWeight.w700,
                    color:
                        colors.primary,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            GradientButton(
              text: 'Log in',
              isLoading:
                  _isLoading,
              onPressed: _login,
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: Divider(
                    color:
                        colors.outlineVariant,
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 14,
                  ),
                  child: Text(
                    'or',
                    style: TextStyle(
                      color: colors
                          .onSurfaceVariant,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color:
                        colors.outlineVariant,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            SocialLoginButton(
              label:
                  'Continue with Google',
              imagePath:
                  'images/google.png',
              onPressed: _isLoading
                  ? null
                  : _loginWithGoogle,
            ),

            const SizedBox(height: 10),

            SocialLoginButton(
              label:
                  'Continue with GitHub',
              imagePath:
                  'images/github.png',
              onPressed: _isLoading
                  ? null
                  : _loginWithGitHub,
            ),

            const SizedBox(height: 22),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Text(
                  'Don’t have an account? ',
                  style: TextStyle(
                    color: colors
                        .onSurfaceVariant,
                  ),
                ),
                GestureDetector(
                  onTap: _isLoading
                      ? null
                      : () {
                          Navigator.of(
                            context,
                          ).pushNamed(
                            RegisterScreen
                                .routeName,
                          );
                        },
                  child: Text(
                    'Create account',
                    style: TextStyle(
                      color:
                          colors.primary,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            GuestAccessCard(
              onPressed: _isLoading
                  ? null
                  : _continueAsGuest,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    return Scaffold(
      backgroundColor:
          theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const AuthHeroImage(
              imagePath:
                  'images/tp_campus.jpg',
            ),
            Transform.translate(
              offset:
                  const Offset(0, -20),
              child:
                  _buildLoginCard(),
            ),
          ],
        ),
      ),
    );
  }
}