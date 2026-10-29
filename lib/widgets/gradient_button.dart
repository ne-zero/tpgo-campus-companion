import 'package:flutter/material.dart';

// reusable gradient button used across tp go
class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.height = 58,
    this.fontSize = 17,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double height;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF1835FF),
              Color(0xFFA736D8),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2637FF).withValues(alpha: 0.25),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  text,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w800,
                  ),
                ),
        ),
      ),
    );
  }
}