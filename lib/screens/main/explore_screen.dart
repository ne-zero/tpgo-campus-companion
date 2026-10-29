import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/campus_location.dart';
import '../../models/saved_place.dart';
import '../../providers/auth_provider.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/saved_provider.dart';
import '../../utils/guest_guard.dart';
import '../../widgets/app_image_box.dart';
import '../../widgets/campus_map.dart';
import '../../widgets/location_detail_sheet.dart';
import 'profile_screen.dart';

// explore page for tp go
// browses campus locations, now read live from firestore instead of a
// hardcoded list. category chips actually filter the results now.
class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() {
    return _ExploreScreenState();
  }
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  String _selectedCategory = 'All';

  final Map<String, IconData> _categoryIcons = const {
    'All': Icons.grid_view_rounded,
    'Food': Icons.local_cafe_outlined,
    'Study': Icons.menu_book_rounded,
    'Prayer': Icons.mosque_outlined,
    'Sports': Icons.sports_basketball_outlined,
    'Facilities': Icons.business_outlined,
  };

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  Color _tagBackgroundColor(String tag) {
    if (Theme.of(context).brightness == Brightness.dark) {
      if (tag.contains('Café') || tag.contains('Vegetarian')) {
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
    }
    return Theme.of(context).colorScheme.surfaceContainer;
  }

  Color _tagTextColor(String tag) {
    if (tag.contains('Café') || tag.contains('Vegetarian')) {
      return const Color(0xFF4A7B26);
    } else if (tag.contains('Study')) {
      return const Color(0xFFC46A28);
    } else if (tag.contains('Prayer')) {
      return const Color(0xFF6B3DFF);
    } else if (tag.contains('Quiet') || tag.contains('Peaceful')) {
      return const Color(0xFF2C6FB8);
    }
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? const Color(0xFFE53935) : const Color(0xFF2637FF),
      ),
    );
  }

  SavedPlace? _findSaved(CampusLocation location, List<SavedPlace> savedPlaces) {
    for (final saved in savedPlaces) {
      if (saved.title == location.name) {
        return saved;
      }
    }
    return null;
  }

  // CREATE or DELETE, depending on whether this location is already saved
  Future<void> _toggleSave(CampusLocation location, SavedPlace? existing) async {
    if (!requireFullAccount(
      context,
      ref,
      message: 'Create a free account to save your favourite places.',
    )) {
      return;
    }

    final user = ref.read(firebaseServiceProvider).currentUser;

    if (user == null) {
      _showMessage('Please log in to save places.', isError: true);
      return;
    }

    final firestoreService = ref.read(firestoreServiceProvider);

    try {
      if (existing != null) {
        await firestoreService.deleteSavedPlace(existing.id);
        _showMessage('Removed from saved places.');
      } else {
        await firestoreService.savePlace(
          userId: user.uid,
          title: location.name,
          subtitle: location.description,
          category: location.category,
          note: '',
          imagePath: location.imagePath,
          badgeIconCode: location.icon.codePoint,
          badgeColorValue: location.color.toARGB32(),
          walkTime: location.distance,
          crowdText: location.crowdLevel,
          tags: location.tags,
        );
        _showMessage('Saved to your places.');
      }
    } on FirebaseException catch (error) {
      _showMessage(
        'Could not update saved places: ${error.message ?? error.code}',
        isError: true,
      );
    } catch (error) {
      _showMessage('Something went wrong. Please try again.', isError: true);
    }
  }

  // detail popup - shows the full location info and lets the user
  // save/unsave right from here

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Explore',
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onSurface, letterSpacing: -1),
                ),
                SizedBox(height: 8),
                Text(
                  'Discover places, services and\nspaces around campus.',
                  style: TextStyle(fontSize: 16, height: 1.35, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(42),
            onTap: () {
              Navigator.of(context).pushNamed(ProfileScreen.routeName);
            },
            child: Container(
              height: 78,
              width: 78,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.10), blurRadius: 16, offset: const Offset(0, 6)),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'images/profile.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.person, size: 40, color: Color(0xFF2637FF));
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBar() {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(22, 12, 22, 18),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 18, offset: const Offset(0, 8)),
        ],
      ),
      child: SizedBox(
        height: 92,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: locationCategories.length,
          separatorBuilder: (context, index) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            final label = locationCategories[index];
            final icon = _categoryIcons[label] ?? Icons.place;
            final isSelected = _selectedCategory == label;

            return InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () {
                _selectCategory(label);
              },
              child: Container(
                width: 86,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colors.primary.withValues(
                          alpha: isDark ? 0.24 : 0.12,
                        )
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 30,
                      color: isSelected
                          ? colors.primary
                          : colors.onSurfaceVariant,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                        color: isSelected
                            ? colors.primary
                            : colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      height: 4,
                      width: 22,
                      decoration: BoxDecoration(
                        color: isSelected ? colors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // real interactive map, replaces the old static explore_map.png
  Widget _buildMapSection(List<CampusLocation> locations) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 18, offset: const Offset(0, 8)),
        ],
      ),
      child: CampusMap(locations: locations, height: 260),
    );
  }

  Widget _buildTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(color: _tagBackgroundColor(tag), borderRadius: BorderRadius.circular(14)),
      child: Text(tag, style: TextStyle(color: _tagTextColor(tag), fontSize: 10.5, fontWeight: FontWeight.w800)),
    );
  }

  Widget _buildLocationCard(CampusLocation location, List<SavedPlace> savedPlaces) {
    final existing = _findSaved(location, savedPlaces);
    final isSaved = existing != null;

    return GestureDetector(
      onTap: () {
        showLocationDetailSheet(context, ref, location);
      },
      child: Container(
        width: 168,
        margin: const EdgeInsets.only(right: 14, bottom: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 16, offset: const Offset(0, 8)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AppImageBox(
                  imagePath: location.imagePath,
                  height: 112,
                  width: 168,
                  fit: BoxFit.cover,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(18), topRight: Radius.circular(18)),
                  fallback: Icon(location.icon, color: location.color, size: 42),
                ),
                Positioned(
                  left: 12,
                  top: 10,
                  child: Container(
                    height: 42,
                    width: 42,
                    decoration: BoxDecoration(color: location.color, shape: BoxShape.circle),
                    child: Icon(location.icon, color: Colors.white, size: 22),
                  ),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: GestureDetector(
                    onTap: () {
                      _toggleSave(location, existing);
                    },
                    child: Container(
                      height: 28,
                      width: 28,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.90),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Icon(
                        isSaved ? Icons.bookmark : Icons.bookmark_border,
                        size: 20,
                        color: isSaved ? const Color(0xFF6B3DFF) : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 11, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onSurface),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    location.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.directions_walk, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        location.distance,
                        style: TextStyle(fontSize: 11.5, color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: location.tags.map((tag) => _buildTag(tag)).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final savedPlacesAsync = ref.watch(savedPlacesProvider);
    final savedPlaces = savedPlacesAsync.value ?? [];

    // uses the plain stream for "All", or the advanced filter query
    // (getCampusLocationsByCategory) when a specific category is picked
    final locationsAsync = _selectedCategory == 'All'
        ? ref.watch(campusLocationsProvider)
        : ref.watch(categoryFilteredLocationsProvider(_selectedCategory));

    // the map always shows every pin, even when a category chip is
    // selected, so the user keeps full campus context
    final allLocations = ref.watch(campusLocationsProvider).value ?? [];

    return SafeArea(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildHeader(context),
          _buildCategoryBar(),
          _buildMapSection(allLocations),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 28, 22, 14),
            child: Text(
              _selectedCategory == 'All' ? 'Nearby places' : _selectedCategory,
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
          locationsAsync.when(
            data: (locations) {
              if (locations.isEmpty) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 40, horizontal: 22),
                  child: Text(
                    'No places found in this category yet.',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600),
                  ),
                );
              }

              return SizedBox(
                height: 340,
                child: ListView.builder(
                  padding: const EdgeInsets.only(left: 22, bottom: 8),
                  scrollDirection: Axis.horizontal,
                  itemCount: locations.length,
                  itemBuilder: (context, index) {
                    return _buildLocationCard(locations[index], savedPlaces);
                  },
                ),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stackTrace) => Padding(
              padding: EdgeInsets.symmetric(vertical: 40, horizontal: 22),
              child: Text(
                'Could not load places. Please check your connection.',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
