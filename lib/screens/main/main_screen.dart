import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/navigation_provider.dart';
import 'ai_tips_screen.dart';
import 'explore_screen.dart';
import 'home_screen.dart';
import 'saved_screen.dart';

// main screen controls the four main pages
// uses flutter's standard BottomNavigationBar from the lab
class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  static const String routeName = '/main';

  static const List<Widget> _screens = [
    HomeScreen(),
    ExploreScreen(),
    SavedScreen(),
    AiTipsScreen(),
  ];

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final selectedIndex =
        ref.watch(selectedTabProvider);

    final theme =
        Theme.of(context);

    final colors =
        theme.colorScheme;

    final isDark =
        theme.brightness ==
            Brightness.dark;

    return Scaffold(
      extendBody: true,

      backgroundColor:
          theme.scaffoldBackgroundColor,

      body: IndexedStack(
        index: selectedIndex,
        children: _screens,
      ),

      bottomNavigationBar: SafeArea(
        minimum:
            const EdgeInsets.fromLTRB(
          18,
          0,
          18,
          12,
        ),
        child: Material(
          elevation: 0,
          color: isDark
              ? const Color(
                  0xFF151F33,
                )
              : Colors.white,
          borderRadius:
              BorderRadius.circular(
            28,
          ),
          clipBehavior:
              Clip.antiAlias,
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(
                28,
              ),
              border: Border.all(
                color: isDark
                    ? const Color(
                        0xFF303B55,
                      )
                    : const Color(
                        0xFFE5E8F0,
                      ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withValues(
                    alpha:
                        isDark
                            ? 0.30
                            : 0.10,
                  ),
                  blurRadius: 24,
                  spreadRadius: 1,
                  offset:
                      const Offset(
                    0,
                    8,
                  ),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex:
                  selectedIndex,

              onTap: (index) {
                ref
                    .read(
                      selectedTabProvider
                          .notifier,
                    )
                    .setTab(index);
              },

              type:
                  BottomNavigationBarType
                      .fixed,

              backgroundColor:
                  Colors.transparent,

              elevation: 0,

              showSelectedLabels: true,
              showUnselectedLabels: true,

              selectedFontSize: 11,
              unselectedFontSize: 10.5,

              selectedItemColor:
                  colors.primary,

              unselectedItemColor:
                  isDark
                      ? const Color(
                          0xFF8C96AE,
                        )
                      : const Color(
                          0xFF7A829A,
                        ),

              items: [
                BottomNavigationBarItem(
                  icon: _NavIcon(
                    icon:
                        Icons.home_outlined,
                    isSelected:
                        selectedIndex == 0,
                    isDark: isDark,
                  ),
                  activeIcon: _NavIcon(
                    icon:
                        Icons.home_rounded,
                    isSelected: true,
                    isDark: isDark,
                  ),
                  label: 'Home',
                ),

                BottomNavigationBarItem(
                  icon: _NavIcon(
                    icon: Icons
                        .explore_outlined,
                    isSelected:
                        selectedIndex == 1,
                    isDark: isDark,
                  ),
                  activeIcon: _NavIcon(
                    icon:
                        Icons.explore_rounded,
                    isSelected: true,
                    isDark: isDark,
                  ),
                  label: 'Explore',
                ),

                BottomNavigationBarItem(
                  icon: _NavIcon(
                    icon: Icons
                        .bookmark_border_rounded,
                    isSelected:
                        selectedIndex == 2,
                    isDark: isDark,
                  ),
                  activeIcon: _NavIcon(
                    icon: Icons
                        .bookmark_rounded,
                    isSelected: true,
                    isDark: isDark,
                  ),
                  label: 'Saved',
                ),

                BottomNavigationBarItem(
                  icon: _NavIcon(
                    icon: Icons
                        .auto_awesome_outlined,
                    isSelected:
                        selectedIndex == 3,
                    isDark: isDark,
                  ),
                  activeIcon: _NavIcon(
                    icon: Icons
                        .auto_awesome_rounded,
                    isSelected: true,
                    isDark: isDark,
                  ),
                  label: 'AI Tips',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// only changes how the standard nav item's icon looks
// navigation itself is still handled by BottomNavigationBar
class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.icon,
    required this.isSelected,
    required this.isDark,
  });

  final IconData icon;
  final bool isSelected;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final primary =
        Theme.of(context)
            .colorScheme
            .primary;

    if (!isSelected) {
      return Padding(
        padding:
            const EdgeInsets.only(
          top: 5,
        ),
        child: Icon(
          icon,
          size: 23,
        ),
      );
    }

    return Container(
      margin:
          const EdgeInsets.only(
        top: 4,
      ),
      padding:
          const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: primary.withValues(
          alpha: isDark ? 0.20 : 0.10,
        ),
        borderRadius:
            BorderRadius.circular(
          18,
        ),
      ),
      child: Icon(
        icon,
        size: 24,
      ),
    );
  }
}