import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';

// forgot password page for sending firebase reset email
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  static const routeName = '/forgot-password';

  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() {
    return _ForgotPasswordScreenState();
  }
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // checks if email is empty or invalid
  // uses the same simple @ check as the other auth screens
  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email.';
    }

    if (!value.contains('@')) {
      return 'Please enter a valid email.';
    }

    return null;
  }

  // converts firebase errors into easier messages
  String _friendlyError(Object error) {
    if (error is FirebaseAuthException) {
      if (error.code == 'invalid-email') {
        return 'Please enter a valid email address.';
      } else if (error.code == 'user-not-found') {
        return 'No account was found with this email.';
      } else if (error.code == 'too-many-requests') {
        return 'Too many requests. Please wait a while before trying again.';
      } else if (error.code == 'network-request-failed') {
        return 'Network error. Please check your internet connection.';
      } else if (error.message != null) {
        return error.message!;
      }
    }

    return 'Something went wrong. Please try again.';
  }

  // shows success or error message
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? const Color(0xFFE53935)
            : const Color(0xFF2637FF),
      ),
    );
  }

  // sends the reset password email through firebase
  Future<void> _sendResetEmail() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final firebaseService = ref.read(firebaseServiceProvider);

      await firebaseService.sendPasswordResetEmail(
        _emailController.text,
      );

      if (!mounted) {
        return;
      }

      _showSnackBar('Password reset email sent. Please check your inbox.');

      await Future.delayed(const Duration(milliseconds: 700));

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showSnackBar(
        _friendlyError(error),
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

  Widget _buildTopImage() {
    return SizedBox(
      height: 245,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'images/tp_campus.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFFEAF2FF),
                  child: const Icon(
                    Icons.school_rounded,
                    color: Color(0xFF2637FF),
                    size: 80,
                  ),
                );
              },
            ),
          ),

          // soft fade so the image blends into the page
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.10),
                    Colors.white.withValues(alpha: 0.40),
                    const Color(0xFFF6F7FB),
                  ],
                ),
              ),
            ),
          ),

          // small back button only, no text covering the image
          Positioned(
            left: 20,
            top: 18,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: Color(0xFF080C3F),
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      validator: _validateEmail,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Color(0xFF080C3F),
      ),
      decoration: InputDecoration(
        hintText: 'Email',
        hintStyle: const TextStyle(
          color: Color(0xFF9CA3B8),
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: const Icon(
          Icons.email_outlined,
          color: Color(0xFF7B829E),
        ),
        filled: true,
        fillColor: const Color(0xFFF7F7FB),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFFE1E4EF),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFF2637FF),
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFFE53935),
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFFE53935),
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildResetButton() {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF2637FF),
              Color(0xFFB72DEB),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2637FF).withValues(alpha: 0.25),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _sendResetEmail,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Send reset email',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildMainCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(22, 0, 22, 0),
      padding: const EdgeInsets.fromLTRB(28, 30, 28, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Container(
              height: 78,
              width: 78,
              decoration: const BoxDecoration(
                color: Color(0xFFEDEBFF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_reset_rounded,
                color: Color(0xFF2637FF),
                size: 42,
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Reset your password',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Color(0xFF080C3F),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Enter your email and we’ll send you a link to create a new password.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                fontWeight: FontWeight.w600,
                color: Color(0xFF606780),
              ),
            ),
            const SizedBox(height: 26),
            _buildEmailField(),
            const SizedBox(height: 22),
            _buildResetButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomText() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 30),
      child: Column(
        children: [
          const Text(
            'Remembered your password?',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF606780),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          TextButton(
            onPressed: _isLoading
                ? null
                : () {
                    Navigator.of(context).pop();
                  },
            child: const Text(
              'Back to Login',
              style: TextStyle(
                color: Color(0xFF2637FF),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTopImage(),

              // moves the card up slightly so it still matches the login style
              Transform.translate(
                offset: const Offset(0, -36),
                child: _buildMainCard(),
              ),

              // removes the extra gap caused by the card being moved up
              Transform.translate(
                offset: const Offset(0, -36),
                child: _buildBottomText(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}