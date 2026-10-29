import 'package:flutter/material.dart';

// reusable row used in profile settings sections
class ProfileMenuTile extends StatelessWidget {
  const ProfileMenuTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailingText,
    this.showDivider = true,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final String? trailingText;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 22,
            vertical: 7,
          ),
          leading: Icon(
            icon,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            size: 28,
          ),
          title: Text(
            title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 15.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (trailingText != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    trailingText!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 28,
              ),
            ],
          ),
        ),
        if (showDivider)
          Padding(
            padding: EdgeInsets.only(left: 78, right: 22),
            child: Divider(
              height: 0,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
      ],
    );
  }
}