import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import 'app_image_box.dart';

// reusable saved place card used in the saved screen
// now interactive: tapping the card opens the edit/delete sheet,
// tapping the bookmark icon removes the place straight away
class SavedPlaceCard extends StatelessWidget {
  const SavedPlaceCard({
    super.key,
    required this.imagePath,
    required this.badgeIcon,
    required this.badgeColor,
    required this.title,
    required this.subtitle,
    required this.walkTime,
    required this.crowdText,
    required this.tags,
    required this.onTap,
    required this.onQuickRemove,
  });

  final String imagePath;
  final IconData badgeIcon;
  final Color badgeColor;
  final String title;
  final String subtitle;
  final String walkTime;
  final String crowdText;
  final List<String> tags;

  // opens the detail sheet where the user can edit or delete
  final VoidCallback onTap;

  // removes the saved place immediately, without opening the sheet
  final VoidCallback onQuickRemove;

  Color _tagBackgroundColor(BuildContext context, String tag) {
    if (Theme.of(context).brightness == Brightness.dark) {
      if (tag.contains('Café') ||
          tag.contains('Vegetarian') ||
          tag.contains('Lounge')) {
        return const Color(0xFF24362B);
      } else if (tag.contains('Study')) {
        return const Color(0xFF3A2D24);
      } else if (tag.contains('Prayer')) {
        return const Color(0xFF30274A);
      } else if (tag.contains('Quiet') || tag.contains('Peaceful')) {
        return const Color(0xFF24334B);
      }
      return Theme.of(context).colorScheme.surfaceContainer;
    }

    if (tag.contains('Café') || tag.contains('Vegetarian')) {
      return const Color(0xFFEAF6DD);
    } else if (tag.contains('Study')) {
      return const Color(0xFFFFEEE2);
    } else if (tag.contains('Prayer')) {
      return const Color(0xFFF0E8FF);
    } else if (tag.contains('Quiet') || tag.contains('Peaceful')) {
      return const Color(0xFFEAF2FF);
    } else if (tag.contains('Lounge')) {
      return const Color(0xFFEAF6DD);
    }

    return Theme.of(context).colorScheme.surfaceContainer;
  }

  Color _tagTextColor(BuildContext context, String tag) {
    if (tag.contains('Café') || tag.contains('Vegetarian')) {
      return const Color(0xFF4A7B26);
    } else if (tag.contains('Study')) {
      return const Color(0xFFC46A28);
    } else if (tag.contains('Prayer')) {
      return const Color(0xFF6B3DFF);
    } else if (tag.contains('Quiet') || tag.contains('Peaceful')) {
      return const Color(0xFF2C6FB8);
    } else if (tag.contains('Lounge')) {
      return const Color(0xFF4A7B26);
    }

    return Theme.of(context).colorScheme.onSurfaceVariant;
  }

  Widget _buildSmallInfoChip(BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(BuildContext context, String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: _tagBackgroundColor(context, tag),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Text(
        tag,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: _tagTextColor(context, tag),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 190,
        margin: const EdgeInsets.fromLTRB(22, 0, 22, 14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.055),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                AppImageBox(
                  imagePath: imagePath,
                  height: 190,
                  width: 132,
                  fit: BoxFit.cover,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(22),
                    bottomLeft: Radius.circular(22),
                  ),
                  fallback: Icon(
                    badgeIcon,
                    color: badgeColor,
                    size: 42,
                  ),
                ),
                Positioned(
                  left: 13,
                  top: 13,
                  child: Container(
                    height: 43,
                    width: 43,
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
                padding: const EdgeInsets.fromLTRB(14, 14, 12, 12),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 34),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 7,
                            runSpacing: 7,
                            children: [
                              _buildSmallInfoChip(context,
                                icon: Icons.directions_walk,
                                text: walkTime,
                              ),
                              _buildSmallInfoChip(context,
                                icon: Icons.groups,
                                text: crowdText,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 7,
                            runSpacing: 7,
                            children: tags.map((tag) {
                              return _buildTag(context, tag);
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    // tapping this removes the saved place immediately
                    // separate GestureDetector so it doesn't trigger onTap
                    Positioned(
                      right: 2,
                      top: 2,
                      child: GestureDetector(
                        onTap: onQuickRemove,
                        child: const Icon(
                          Icons.bookmark,
                          size: 30,
                          color: Color(0xFF6B3DFF),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 1,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: () {
                          SharePlus.instance.share(
                            ShareParams(
                              text: 'Check out $title on TP Go!\n\n$subtitle\n\n📍 $walkTime • $crowdText crowd',
                            ),
                          );
                        },
                        child: Icon(
                          Icons.share_outlined,
                          size: 24,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
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
