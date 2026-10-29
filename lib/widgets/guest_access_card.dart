import 'package:flutter/material.dart';

// guest access card for users who want to enter without an account
class GuestAccessCard extends StatelessWidget {
  const GuestAccessCard({
    super.key,
    required this.onPressed,
  });

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FD),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE3E5EE),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.account_circle_outlined,
            size: 42,
            color: Color(0xFF2637FF),
          ),
          const SizedBox(height: 8),
          const Text(
            'Just browsing TP Go?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E2346),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Use the app first without creating an account.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF707592),
              fontSize: 13.5,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onPressed,
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                  color: Color(0xFF555A78),
                  fontSize: 14,
                ),
                children: [
                  TextSpan(text: 'Continue with '),
                  TextSpan(
                    text: 'Guest Access',
                    style: TextStyle(
                      color: Color(0xFF2637FF),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}