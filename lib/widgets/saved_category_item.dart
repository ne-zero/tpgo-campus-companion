import 'package:flutter/material.dart';

// category item used in the saved screen filter bar
class SavedCategoryItem extends StatelessWidget {
  const SavedCategoryItem({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        width: 88,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 31,
              color: isSelected
                  ? const Color(0xFF6B3DFF)
                  : Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 5),
            Container(
              height: 4,
              width: 22,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF6B3DFF)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}