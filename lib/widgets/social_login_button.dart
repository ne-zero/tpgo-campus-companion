import 'package:flutter/material.dart';

// reusable social login button for google and github
class SocialLoginButton extends StatelessWidget {
  const SocialLoginButton({
    super.key,
    required this.label,
    required this.imagePath,
    required this.onPressed,
  });

  final String label;
  final String imagePath;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF25283D),
          side: const BorderSide(
            color: Color(0xFFE3E5EE),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              height: 24,
              width: 24,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.login,
                  size: 24,
                );
              },
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}