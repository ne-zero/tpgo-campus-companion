import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../models/campus_location.dart';
import '../models/saved_place.dart';
import '../providers/auth_provider.dart';
import '../providers/saved_provider.dart';
import '../utils/guest_guard.dart';
import 'app_image_box.dart';

Color _statusColor(String status) {
  if (status == 'Open') {
    return const Color(0xFF18B337);
  } else if (status == 'Busy') {
    return const Color(0xFFFF9800);
  }
  return const Color(0xFFE53935);
}

Color _crowdColor(String crowdLevel) {
  if (crowdLevel == 'Low') {
    return const Color(0xFF18B337);
  } else if (crowdLevel == 'Medium') {
    return const Color(0xFFFF9800);
  }
  return const Color(0xFFE53935);
}

Color _tagBackgroundColor(BuildContext context, String tag) {
  if (Theme.of(context).brightness == Brightness.dark) {
    if (tag.contains('Café') ||
        tag.contains('Vegetarian') ||
        tag.contains('Food')) {
      return const Color(0xFF24362B);
    } else if (tag.contains('Study') || tag.contains('Group')) {
      return const Color(0xFF3A2D24);
    } else if (tag.contains('Prayer')) {
      return const Color(0xFF30274A);
    } else if (tag.contains('Quiet') || tag.contains('Peaceful')) {
      return const Color(0xFF24334B);
    } else if (tag.contains('Renovation')) {
      return const Color(0xFF472B31);
    }
    return Theme.of(context).colorScheme.surfaceContainer;
  }

  if (tag.contains('Café') || tag.contains('Vegetarian') || tag.contains('Food')) {
    return const Color(0xFFEAF6DD);
  } else if (tag.contains('Study') || tag.contains('Group')) {
    return const Color(0xFFFFEEE2);
  } else if (tag.contains('Prayer')) {
    return const Color(0xFFF0E8FF);
  } else if (tag.contains('Quiet') || tag.contains('Peaceful')) {
    return const Color(0xFFEAF2FF);
  } else if (tag.contains('Renovation')) {
    return const Color(0xFFFFE8E8);
  }
  return Theme.of(context).colorScheme.surfaceContainer;
}

Color _tagTextColor(BuildContext context, String tag) {
  if (tag.contains('Café') || tag.contains('Vegetarian') || tag.contains('Food')) {
    return const Color(0xFF4A7B26);
  } else if (tag.contains('Study') || tag.contains('Group')) {
    return const Color(0xFFC46A28);
  } else if (tag.contains('Prayer')) {
    return const Color(0xFF6B3DFF);
  } else if (tag.contains('Quiet') || tag.contains('Peaceful')) {
    return const Color(0xFF2C6FB8);
  } else if (tag.contains('Renovation')) {
    return const Color(0xFFC62828);
  }
  return Theme.of(context).colorScheme.onSurfaceVariant;
}

void showLocationDetailSheet(
  BuildContext context,
  WidgetRef ref,
  CampusLocation location,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (bottomSheetContext) {
      return DraggableScrollableSheet(
        initialChildSize: 0.82,
        minChildSize: 0.58,
        maxChildSize: 0.96,
        expand: false,
        builder: (context, scrollController) {
          return _LocationDetailContent(
            location: location,
            scrollController: scrollController,
          );
        },
      );
    },
  );
}

class _LocationDetailContent extends ConsumerStatefulWidget {
  const _LocationDetailContent({
    required this.location,
    required this.scrollController,
  });

  final CampusLocation location;
  final ScrollController scrollController;

  @override
  ConsumerState<_LocationDetailContent> createState() =>
      _LocationDetailContentState();
}

class _LocationDetailContentState extends ConsumerState<_LocationDetailContent> {
  bool _isSaving = false;

  SavedPlace? _findSaved(List<SavedPlace> savedPlaces) {
    for (final saved in savedPlaces) {
      if (saved.title == widget.location.name) {
        return saved;
      }
    }
    return null;
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? const Color(0xFFE53935) : const Color(0xFF2637FF),
      ),
    );
  }

  Future<void> _toggleSave(SavedPlace? existing) async {
    if (!requireFullAccount(
      context,
      ref,
      message: 'Create a free account to save your favourite places.',
    )) {
      return;
    }

    final user = ref.read(firebaseServiceProvider).currentUser;
    if (user == null) return;

    setState(() => _isSaving = true);

    try {
      final firestoreService = ref.read(firestoreServiceProvider);

      if (existing != null) {
        await firestoreService.deleteSavedPlace(existing.id);
        _showMessage('Removed from saved places.');
      } else {
        await firestoreService.savePlace(
          userId: user.uid,
          title: widget.location.name,
          subtitle: widget.location.description,
          category: widget.location.category,
          note: '',
          imagePath: widget.location.imagePath,
          badgeIconCode: widget.location.icon.codePoint,
          badgeColorValue: widget.location.color.toARGB32(),
          walkTime: widget.location.distance,
          crowdText: widget.location.crowdLevel,
          tags: widget.location.tags,
        );
        _showMessage('Saved to your places.');
      }
    } on FirebaseException catch (error) {
      _showMessage(
        'Could not update saved places: ${error.message ?? error.code}',
        isError: true,
      );
    } catch (_) {
      _showMessage('Something went wrong. Please try again.', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color surface,
    required Color secondaryText,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 12),
        decoration: BoxDecoration(
          color: Color.alphaBlend(color.withValues(alpha: 0.10), surface),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 15, color: color),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: secondaryText,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.15,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final location = widget.location;
    final savedPlacesAsync = ref.watch(savedPlacesProvider);
    final savedPlaces = savedPlacesAsync.value ?? [];
    final existing = _findSaved(savedPlaces);
    final isSaved = existing != null;

    // ignore: unused_local_variable
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = Theme.of(context).colorScheme.surface;
    final primaryText = Theme.of(context).colorScheme.onSurface;
    final secondaryText = Theme.of(context).colorScheme.onSurfaceVariant;
    final divider = Theme.of(context).colorScheme.outlineVariant;

    final isUnavailable = location.status == 'Closed' ||
        location.status == 'Under Renovation';

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: ListView(
        controller: widget.scrollController,
        padding: EdgeInsets.zero,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(32)),
                child: AppImageBox(
                  imagePath: location.imagePath,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  borderRadius: BorderRadius.zero,
                  fallback: Container(
                    height: 250,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          location.color.withValues(alpha: 0.22),
                          location.color.withValues(alpha: 0.45),
                        ],
                      ),
                    ),
                    child: Icon(
                      location.icon,
                      color: location.color,
                      size: 82,
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(32)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.06),
                        Colors.black.withValues(alpha: 0.62),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    height: 5,
                    width: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.88),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 18,
                top: 30,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    location.category,
                    style: TextStyle(
                      color: location.color,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 16,
                top: 28,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    height: 38,
                    width: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: Theme.of(context).colorScheme.onSurface,
                      size: 21,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 20,
                bottom: 18,
                right: 20,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: location.color,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(location.icon, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        location.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 23,
                          height: 1.1,
                          fontWeight: FontWeight.w900,
                          shadows: [
                            Shadow(color: Colors.black45, blurRadius: 8),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isUnavailable) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEAEA),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFFC7C7)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Color(0xFFC62828),
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            location.status == 'Under Renovation'
                                ? 'Currently unavailable. This location is under renovation, so check again before planning a visit.'
                                : 'This location is currently closed. Check the status again before travelling there.',
                            style: const TextStyle(
                              color: Color(0xFF8E1C1C),
                              fontSize: 13,
                              height: 1.4,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                Text(
                  'About this place',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: primaryText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  location.description,
                  style: TextStyle(
                    fontSize: 14.5,
                    height: 1.55,
                    color: secondaryText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _buildInfoCard(
                      icon: location.status == 'Open'
                          ? Icons.check_circle_outline
                          : Icons.info_outline,
                      label: 'Status',
                      value: location.status,
                      color: _statusColor(location.status),
                      surface: surface,
                      secondaryText: secondaryText,
                    ),
                    const SizedBox(width: 9),
                    _buildInfoCard(
                      icon: Icons.groups_outlined,
                      label: 'Crowd',
                      value: location.crowdLevel,
                      color: _crowdColor(location.crowdLevel),
                      surface: surface,
                      secondaryText: secondaryText,
                    ),
                    const SizedBox(width: 9),
                    _buildInfoCard(
                      icon: Icons.directions_walk_rounded,
                      label: 'Walk',
                      value: location.distance,
                      color: const Color(0xFF596BFF),
                      surface: surface,
                      secondaryText: secondaryText,
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Text(
                  'Useful tags',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: primaryText,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: location.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _tagBackgroundColor(context, tag),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          color: _tagTextColor(context, tag),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 22),
                Container(height: 1, color: divider),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: secondaryText,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Status and crowd information may change during the day. '
                        'Use the map pin and details here as a quick campus guide.',
                        style: TextStyle(
                          color: secondaryText,
                          fontSize: 12.5,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed:
                              _isSaving ? null : () => _toggleSave(existing),
                          icon: _isSaving
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Icon(
                                  isSaved
                                      ? Icons.bookmark_rounded
                                      : Icons.bookmark_border_rounded,
                                ),
                          label: Text(
                            isSaved ? 'Saved place' : 'Save this place',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSaved
                                ? const Color(0xFFF0EAFF)
                                : const Color(0xFF2637FF),
                            foregroundColor: isSaved
                                ? const Color(0xFF6B3DFF)
                                : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      height: 56,
                      width: 56,
                      child: OutlinedButton(
                        onPressed: () {
                          SharePlus.instance.share(
                            ShareParams(
                              text:
                                  'Check out ${location.name} on TP Go!\n\n'
                                  '${location.description}\n\n'
                                  '📍 ${location.distance} • ${location.crowdLevel} crowd • ${location.status}',
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          side: BorderSide(color: divider),
                        ),
                        child: const Icon(
                          Icons.share_outlined,
                          color: Color(0xFF596BFF),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
