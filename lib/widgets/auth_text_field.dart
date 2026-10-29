import 'package:flutter/material.dart';

// reusable text field for authentication forms
class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icon,
    required this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final String? Function(String?) validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: TextStyle(
        color: colors.onSurface,
        fontWeight: FontWeight.w600,
      ),
      cursorColor: colors.primary,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: colors.onSurfaceVariant.withValues(alpha: 0.75),
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(
          icon,
          color: colors.onSurfaceVariant,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: isDark
            ? colors.surfaceContainer
            : const Color(0xFFF7F7FB),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: colors.outlineVariant,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: colors.outlineVariant,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: colors.primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
