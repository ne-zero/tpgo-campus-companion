import 'package:flutter/material.dart';

import 'app_image_box.dart';

// reusable card for nearby campus places
// now tappable - shows a quick detail popup when pressed
class NearbyPlaceCard extends StatelessWidget {
  const NearbyPlaceCard({
    super.key,
    required this.imagePath,
    required this.badgeIcon,
    required this.badgeColor,
    required this.title,
    required this.subtitle,
    required this.secondTag,
    this.onTap,
  });

  final String imagePath;
  final IconData badgeIcon;
  final Color badgeColor;
  final String title;
  final String subtitle;
  final String secondTag;

  // called when the card is tapped
  final VoidCallback? onTap;

  Widget _buildTag(BuildContext context, String text, {bool green = true}) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: green
            ? (Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF193424)
                : const Color(0xFFE8F8EA))
            : Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: green ? const Color(0xFF168B3B) : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        width: 170,
        height: 220,
        margin: const EdgeInsets.only(right: 14, bottom: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AppImageBox(
                  imagePath: imagePath,
                  height: 105,
                  width: 170,
                  fit: BoxFit.cover,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                  ),
                ),
                Positioned(
                  left: 14,
                  top: 10,
                  child: Container(
                    height: 42,
                    width: 42,
                    decoration: BoxDecoration(
                      color: badgeColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      badgeIcon,
                      color: Colors.white,
                      size: 23,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w900,
                        fontSize: 13.5,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 11.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _buildTag(context, 'Open now'),
                        _buildTag(context, secondTag, green: false),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
