import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/campus_location.dart';
import '../../providers/auth_provider.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../utils/guest_guard.dart';
import '../../widgets/app_image_box.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/home_stat_item.dart';
import '../../widgets/location_detail_sheet.dart';
import '../../widgets/nearby_place_card.dart';
import 'book_facility_screen.dart';
import 'my_bookings_screen.dart';
import 'profile_screen.dart';

// home page for tp go
// shows campus image, quick overview, ai recommendation and nearby places
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Widget _buildHeroSection(BuildContext context) {
    return Stack(
      children: [
        // main campus hero image
        const AppImageBox(
          imagePath: 'images/tp_campus.jpg',
          height: 260,
          width: double.infinity,
          fit: BoxFit.fitWidth,
          fallback: Icon(
            Icons.school_outlined,
            color: Color(0xFF2637FF),
            size: 50,
          ),
        ),

        // notification icon
        Positioned(
          right: 18,
          top: 36,
          child: Stack(
            children: [
              Icon(
                Icons.notifications_none,
                size: 30,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              Positioned(
                right: 3,
                top: 3,
                child: Container(
                  height: 9,
                  width: 9,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),

        // profile picture button
        Positioned(
          right: 28,
          top: 72,
          child: InkWell(
            borderRadius: BorderRadius.circular(40),
            onTap: () {
              Navigator.of(context).pushNamed(ProfileScreen.routeName);
            },
            child: Container(
              height: 72,
              width: 72,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'images/profile.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.person,
                      size: 38,
                      color: Color(0xFF2637FF),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAtAGlanceCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 22),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'At a glance',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const HomeStatItem(
                icon: Icons.restaurant,
                backgroundColor: Color(0xFFFFECEC),
                iconColor: Colors.red,
                title: 'Food and Drinks',
                number: '5',
                subtitle: 'open now',
              ),
              Container(
                height: 82,
                width: 1,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              const HomeStatItem(
                icon: Icons.menu_book_rounded,
                backgroundColor: Color(0xFFEAF1FF),
                iconColor: Color(0xFF286BFF),
                title: 'Study spots',
                number: '4',
                subtitle: 'quiet now',
              ),
              Container(
                height: 82,
                width: 1,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              const HomeStatItem(
                icon: Icons.mosque,
                backgroundColor: Color(0xFFF1ECFF),
                iconColor: Color(0xFF6B3DFF),
                title: 'Prayer spots',
                number: '3',
                subtitle: 'low crowd',
              ),
              Container(
                height: 82,
                width: 1,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              const HomeStatItem(
                icon: Icons.business,
                backgroundColor: Color(0xFFEAF8EF),
                iconColor: Color(0xFF169447),
                title: 'Facilities',
                number: '',
                subtitle: 'All services',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsRow(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                // booking needs a real account since it writes a booking
                // record tied to the user's uid
                if (!requireFullAccount(
                  context,
                  ref,
                  message: 'Create a free account to book campus facilities.',
                )) {
                  return;
                }
                Navigator.of(context).pushNamed(BookFacilityScreen.routeName);
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).colorScheme.surfaceContainer
                      : const Color(0xFFEAF1FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.event_available,
                      color: Color(0xFF286BFF),
                      size: 28,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Book a Facility',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 13.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Pay with NETS QR',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                Navigator.of(context).pushNamed(MyBookingsScreen.routeName);
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).colorScheme.surfaceContainer
                      : const Color(0xFFF1ECFF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.receipt_long,
                      color: Color(0xFF6B3DFF),
                      size: 28,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'My Bookings',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 13.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'View your bookings',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(BuildContext context, WidgetRef ref, CampusLocation location) {
    final colors = Theme.of(context).colorScheme;
    final isDark =
    Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 22, 18, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? colors.surfaceContainer : const Color(0xFFEFF4FF),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '✦  AI SMART RECOMMENDATION',
                  style: TextStyle(
                    color: Color(0xFF5C35FF),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  location.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  location.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? colors.onSurfaceVariant : const Color(0xFF4F5774),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECE9FF),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.directions_walk,
                        size: 17,
                        color: isDark ? const Color(0xFF302A52) : const Color(0xFFECE9FF),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        location.distance,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: isDark ? const Color(0xFFD8D4FF) : const Color(0xFF1E2346),
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F8E9),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.groups,
                        size: 17,
                        color: Color(0xFF14943D),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${location.crowdLevel} crowd',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF14943D),
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                GradientButton(
                  text: 'View details  →',
                  height: 46,
                  fontSize: 14,
                  onPressed: () {
                    showLocationDetailSheet(context, ref, location);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          AppImageBox(
            imagePath: location.imagePath,
            height: 200,
            width: 132,
            fit: BoxFit.cover,
            borderRadius: BorderRadius.circular(24),
            fallback: Icon(location.icon, color: location.color, size: 40),
          ),
        ],
      ),
    );
  }

  Widget _buildDots() {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 8,
            width: 22,
            decoration: BoxDecoration(
              color: const Color(0xFF2637FF),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            height: 8,
            width: 8,
            decoration: const BoxDecoration(
              color: Color(0xFFD8DCEB),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            height: 8,
            width: 8,
            decoration: const BoxDecoration(
              color: Color(0xFFD8DCEB),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyHeader(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 12),
      child: Row(
        children: [
          Icon(
            Icons.location_on_outlined,
            size: 30,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Discover nearby places',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Explore what’s around you',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(selectedTabProvider.notifier).setTab(TabIndex.explore);
            },
            child: const Text(
              'View all  →',
              style: TextStyle(
                color: Color(0xFF2637FF),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // shown when a nearby place card is tapped
  void _showQuickDetail(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String tag,
    required IconData icon,
    required Color color,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      height: 52,
                      width: 52,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'For full details, saving, and directions, visit the Explore tab.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNearbyList(BuildContext context) {
    return SizedBox(
      height: 255,
      child: ListView(
        padding: const EdgeInsets.only(left: 22, bottom: 8),
        scrollDirection: Axis.horizontal,
        children: [
          NearbyPlaceCard(
            imagePath: 'images/sprouts.png',
            badgeIcon: Icons.local_cafe,
            badgeColor: const Color(0xFFC56E60),
            title: 'Sprouts (Student Cafe)',
            subtitle: 'Student Club Centre',
            secondTag: 'Cafe',
            onTap: () {
              _showQuickDetail(
                context,
                title: 'Sprouts (Student Cafe)',
                subtitle: 'Student Club Centre',
                tag: 'Cafe',
                icon: Icons.local_cafe,
                color: const Color(0xFFC56E60),
              );
            },
          ),
          NearbyPlaceCard(
            imagePath: 'images/gym.png',
            badgeIcon: Icons.fitness_center,
            badgeColor: const Color(0xFFFF5B18),
            title: 'Gym & Fitness Centre',
            subtitle: 'Sports & Recreation',
            secondTag: 'Not crowded',
            onTap: () {
              _showQuickDetail(
                context,
                title: 'Gym & Fitness Centre',
                subtitle: 'Sports & Recreation',
                tag: 'Not crowded',
                icon: Icons.fitness_center,
                color: const Color(0xFFFF5B18),
              );
            },
          ),
          NearbyPlaceCard(
            imagePath: 'images/pixel_garden.png',
            badgeIcon: Icons.chair,
            badgeColor: const Color(0xFFFFB000),
            title: 'Pixel Garden',
            subtitle: 'Student Lounge',
            secondTag: 'Good for groups',
            onTap: () {
              _showQuickDetail(
                context,
                title: 'Pixel Garden',
                subtitle: 'Student Lounge',
                tag: 'Good for groups',
                icon: Icons.chair,
                color: const Color(0xFFFFB000),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAiBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 10, 18, 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).colorScheme.surfaceContainer
            : const Color(0xFFEFF4FF),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const AppImageBox(
            imagePath: 'images/robot.png',
            height: 72,
            width: 72,
            fit: BoxFit.contain,
            fallback: Icon(
              Icons.smart_toy_outlined,
              color: Color(0xFF2637FF),
              size: 42,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Not sure where to go?',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Let AI Tips suggest the perfect spot for you.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(firebaseServiceProvider).currentUser;
    final locationsAsync = ref.watch(campusLocationsProvider);
    final locations = locationsAsync.value ?? [];

    // picks a location to feature - prefers a low-crowd one so the
    // "AI recommendation" framing actually makes sense, falls back to
    // the first location if none are low-crowd yet
    CampusLocation? featuredLocation;
    if (locations.isNotEmpty) {
      featuredLocation = locations.firstWhere(
        (location) => location.crowdLevel == 'Low',
        orElse: () => locations.first,
      );
    }

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _buildHeroSection(context),
        Transform.translate(
          offset: const Offset(0, -18),
          child: _buildAtAGlanceCard(context),
        ),
        _buildQuickActionsRow(context, ref),
        Transform.translate(
          offset: const Offset(0, -8),
          child: Column(
            children: [
              if (featuredLocation != null)
                _buildRecommendationCard(context, ref, featuredLocation),
              _buildDots(),
              _buildNearbyHeader(context, ref),
              _buildNearbyList(context),
              _buildAiBanner(context),
              if (user?.isAnonymous == true)
                Padding(
                  padding: EdgeInsets.fromLTRB(22, 0, 22, 24),
                  child: Text(
                    'You are using Guest Access.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 110,),
            ],
          ),
        ),
      ],
    );
  }
}