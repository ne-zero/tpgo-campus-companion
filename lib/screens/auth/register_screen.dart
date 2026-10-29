import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/auth_hero_image.dart';
import '../../widgets/auth_text_field.dart';
import '../../widgets/gradient_button.dart';
import 'login_screen.dart';

// signup page for tp go
// users create an account using firebase email and password
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  static const String routeName = '/register';

  @override
  ConsumerState<RegisterScreen> createState() {
    return _RegisterScreenState();
  }
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  bool _hidePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // shows feedback messages
  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xFF2637FF),
      ),
    );
  }

  // makes firebase errors easier to understand
  String _firebaseErrorMessage(FirebaseAuthException error) {
    if (error.code == 'email-already-in-use') {
      return 'This email is already registered.';
    } else if (error.code == 'invalid-email') {
      return 'Please enter a valid email.';
    } else if (error.code == 'weak-password') {
      return 'Password is too weak.';
    } else if (error.code == 'operation-not-allowed') {
      return 'Email/password sign-up is not enabled in Firebase.';
    }

    return error.message ?? 'Registration failed.';
  }

  // creates firebase account
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(firebaseServiceProvider).register(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      if (!mounted) return;

      _showMessage('Account created successfully! Please check your email for verification.');
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      _showMessage(
        _firebaseErrorMessage(error),
        isError: true,
      );
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        'Registration failed. Please try again.',
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

  // validates name input
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your name.';
    }

    if (value.trim().length < 2) {
      return 'Name is too short.';
    }

    return null;
  }

  // validates email input
  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email.';
    }

    if (!value.contains('@')) {
      return 'Please enter a valid email.';
    }

    return null;
  }

  // validates password input
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password.';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters.';
    }

    return null;
  }

  // checks confirm password matches password
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password.';
    }

    if (value != _passwordController.text) {
      return 'Passwords do not match.';
    }

    return null;
  }

  Widget _buildRegisterCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 24),
      padding: const EdgeInsets.fromLTRB(26, 28, 26, 26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(34),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Create account',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF070B55),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Sign up to save your campus preferences.',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF707592),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 26),

            AuthTextField(
              controller: _nameController,
              hintText: 'Full name',
              icon: Icons.person_outline,
              validator: _validateName,
              keyboardType: TextInputType.name,
            ),

            const SizedBox(height: 14),

            AuthTextField(
              controller: _emailController,
              hintText: 'Email',
              icon: Icons.mail_outline,
              validator: _validateEmail,
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 14),

            AuthTextField(
              controller: _passwordController,
              hintText: 'Password',
              icon: Icons.lock_outline,
              validator: _validatePassword,
              keyboardType: TextInputType.visiblePassword,
              obscureText: _hidePassword,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _hidePassword = !_hidePassword;
                  });
                },
                icon: Icon(
                  _hidePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: const Color(0xFF6D718F),
                ),
              ),
            ),

            const SizedBox(height: 14),

            AuthTextField(
              controller: _confirmPasswordController,
              hintText: 'Confirm password',
              icon: Icons.lock_reset_outlined,
              validator: _validateConfirmPassword,
              keyboardType: TextInputType.visiblePassword,
              obscureText: _hidePassword,
            ),

            const SizedBox(height: 24),

            GradientButton(
              text: 'Create account',
              isLoading: _isLoading,
              onPressed: _register,
            ),

            const SizedBox(height: 22),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Already have an account? ',
                  style: TextStyle(
                    color: Color(0xFF555A78),
                  ),
                ),
                GestureDetector(
                  onTap: _isLoading
                      ? null
                      : () {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            LoginScreen.routeName,
                            (route) => false,
                          );
                        },
                  child: const Text(
                    'Log in',
                    style: TextStyle(
                      color: Color(0xFF2637FF),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const AuthHeroImage(
              imagePath: 'images/tp_campus.jpg',
            ),
            Transform.translate(
              offset: const Offset(0, -20),
              child: _buildRegisterCard(),
            ),
          ],
        ),
      ),
    );
  }
}