import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/saved_place.dart';
import '../../providers/auth_provider.dart';
import '../../providers/saved_provider.dart';
import '../../utils/guest_guard.dart';
import '../../widgets/saved_category_item.dart';
import '../../widgets/saved_place_card.dart';
import 'profile_screen.dart';

// saved screen for tp go
// users can view, filter, edit and delete saved places
class SavedScreen
    extends ConsumerStatefulWidget {
  const SavedScreen({
    super.key,
  });

  @override
  ConsumerState<SavedScreen>
      createState() {
    return _SavedScreenState();
  }
}

class _SavedScreenState
    extends ConsumerState<SavedScreen> {
  String _selectedCategory = 'All';

  final List<Map<String, dynamic>>
      _categories = const [
    {
      'label': 'All',
      'value': 'All',
      'icon':
          Icons.bookmark_border,
    },
    {
      'label': 'Study + Food',
      'value': 'StudyFood',
      'icon':
          Icons.auto_awesome,
    },
    {
      'label': 'Study Spots',
      'value': 'Study',
      'icon':
          Icons.menu_book_rounded,
    },
    {
      'label': 'Food & Drinks',
      'value': 'Food',
      'icon':
          Icons.local_cafe_outlined,
    },
    {
      'label': 'Prayer Spaces',
      'value': 'Prayer',
      'icon':
          Icons.mosque_outlined,
    },
    {
      'label': 'Facilities',
      'value': 'Facilities',
      'icon':
          Icons.business_outlined,
    },
    {
      'label': 'Sports',
      'value': 'Sports',
      'icon': Icons
          .sports_basketball_outlined,
    },
  ];

  void _selectCategory(
    String category,
  ) {
    setState(() {
      _selectedCategory =
          category;
    });
  }

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    if (!mounted) {
      return;
    }

    final colors =
        Theme.of(context)
            .colorScheme;

    ScaffoldMessenger.of(context)
        .clearSnackBars();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError
                ? colors.error
                : colors.primary,
      ),
    );
  }

  // CREATE is done from Explore

  // DELETE
  Future<void> _deletePlace(
    SavedPlace place,
  ) async {
    try {
      await ref
          .read(
            firestoreServiceProvider,
          )
          .deleteSavedPlace(
            place.id,
          );

      ref.invalidate(
        savedPlacesCountProvider,
      );

      _showMessage(
        'Removed "${place.title}" from saved places.',
      );
    } on FirebaseException catch (
        error) {
      _showMessage(
        'Could not remove place: '
        '${error.message ?? error.code}',
        isError: true,
      );
    } catch (_) {
      _showMessage(
        'Something went wrong. Please try again.',
        isError: true,
      );
    }
  }

  // READ ONE
  Future<void> _openSavedPlace(
    String id,
  ) async {
    try {
      final place = await ref
          .read(
            firestoreServiceProvider,
          )
          .getSavedPlace(id);

      if (!mounted) {
        return;
      }

      if (place == null) {
        _showMessage(
          'This saved place could not be found.',
          isError: true,
        );

        return;
      }

      await _showEditSheet(
        place,
      );
    } on FirebaseException catch (
        error) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Could not load place: '
        '${error.message ?? error.code}',
        isError: true,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Something went wrong. Please try again.',
        isError: true,
      );
    }
  }

  // UPDATE
  Future<void> _showEditSheet(
    SavedPlace place,
  ) async {
    final formKey =
        GlobalKey<FormState>();

    final noteController =
        TextEditingController(
      text: place.note,
    );

    String selectedCategory =
        place.category;

    final categoryOptions =
        _categories
            .map(
              (category) =>
                  category['value']
                      as String,
            )
            .where(
              (value) =>
                  value != 'All' &&
                  value !=
                      'StudyFood',
            )
            .toList();

    final result =
        await showModalBottomSheet<
            Map<String, dynamic>>(
      context: context,
      backgroundColor:
          Theme.of(context)
              .colorScheme
              .surface,
      isScrollControlled: true,
      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top:
              Radius.circular(28),
        ),
      ),
      builder: (
        bottomSheetContext,
      ) {
        return StatefulBuilder(
          builder: (
            context,
            setSheetState,
          ) {
            final colors =
                Theme.of(context)
                    .colorScheme;

            return Padding(
              padding:
                  EdgeInsets.only(
                left: 22,
                right: 22,
                top: 18,
                bottom:
                    MediaQuery.of(
                          context,
                        )
                        .viewInsets
                        .bottom +
                    24,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize:
                      MainAxisSize
                          .min,
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      place.title,
                      style:
                          TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight
                                .w900,
                        color: colors
                            .onSurface,
                      ),
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    Text(
                      'Category',
                      style:
                          TextStyle(
                        fontWeight:
                            FontWeight
                                .w800,
                        color: colors
                            .onSurface,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    DropdownButtonFormField<
                        String>(
                      initialValue:
                          selectedCategory,
                      items:
                          categoryOptions
                              .map(
                        (
                          label,
                        ) {
                          return DropdownMenuItem<
                              String>(
                            value:
                                label,
                            child:
                                Text(
                              label,
                            ),
                          );
                        },
                      ).toList(),
                      onChanged:
                          (
                        value,
                      ) {
                        if (value ==
                            null) {
                          return;
                        }

                        setSheetState(
                          () {
                            selectedCategory =
                                value;
                          },
                        );
                      },
                      decoration:
                          const InputDecoration(
                        border:
                            OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(
                          horizontal:
                              14,
                          vertical:
                              10,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    Text(
                      'Note',
                      style:
                          TextStyle(
                        fontWeight:
                            FontWeight
                                .w800,
                        color: colors
                            .onSurface,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    TextFormField(
                      controller:
                          noteController,
                      maxLines: 3,
                      decoration:
                          const InputDecoration(
                        hintText:
                            'e.g. good for group study, quiet after 5pm',
                        border:
                            OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(
                      height: 22,
                    ),

                    Row(
                      children: [
                        Expanded(
                          child:
                              OutlinedButton(
                            onPressed:
                                () {
                              Navigator.of(
                                bottomSheetContext,
                              ).pop({
                                'action':
                                    'delete',
                              });
                            },
                            style:
                                OutlinedButton
                                    .styleFrom(
                              foregroundColor:
                                  Colors
                                      .red,
                              side:
                                  const BorderSide(
                                color:
                                    Colors
                                        .red,
                              ),
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                vertical:
                                    14,
                              ),
                            ),
                            child:
                                const Text(
                              'Delete',
                            ),
                          ),
                        ),

                        const SizedBox(
                          width: 12,
                        ),

                        Expanded(
                          child:
                              ElevatedButton(
                            onPressed:
                                () {
                              if (!formKey
                                  .currentState!
                                  .validate()) {
                                return;
                              }

                              Navigator.of(
                                bottomSheetContext,
                              ).pop({
                                'action':
                                    'save',
                                'category':
                                    selectedCategory,
                                'note':
                                    noteController
                                        .text
                                        .trim(),
                              });
                            },
                            child:
                                const Text(
                              'Save changes',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    noteController.dispose();

    if (result == null) {
      return;
    }

    if (result['action'] ==
        'delete') {
      await _deletePlace(
        place,
      );

      return;
    }

    if (result['action'] ==
        'save') {
      try {
        await ref
            .read(
              firestoreServiceProvider,
            )
            .updateSavedPlace(
              id: place.id,
              category:
                  result['category']
                      as String,
              note:
                  result['note']
                      as String,
            );

        if (!mounted) {
          return;
        }

        _showMessage(
          'Saved place updated.',
        );
      } on FirebaseException catch (
          error) {
        if (!mounted) {
          return;
        }

        _showMessage(
          'Could not update: '
          '${error.message ?? error.code}',
          isError: true,
        );
      } catch (_) {
        if (!mounted) {
          return;
        }

        _showMessage(
          'Something went wrong. Please try again.',
          isError: true,
        );
      }
    }
  }

  void _retrySavedPlaces() {
    ref.invalidate(
      savedPlacesProvider,
    );

    ref.invalidate(
      savedPlacesCountProvider,
    );

    ref.invalidate(
      studyFoodSavedPlacesProvider,
    );

    if (_selectedCategory !=
            'All' &&
        _selectedCategory !=
            'StudyFood') {
      ref.invalidate(
        savedPlacesByCategoryProvider(
          _selectedCategory,
        ),
      );
    }
  }

  Widget _buildHeader(
    BuildContext context,
  ) {
    final colors =
        Theme.of(context)
            .colorScheme;

    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        22,
        18,
        22,
        10,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  'Saved',
                  style:
                      TextStyle(
                    fontSize: 44,
                    fontWeight:
                        FontWeight
                            .w900,
                    color: colors
                        .onSurface,
                    letterSpacing:
                        -1,
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                Text(
                  'Your favorite places and spots\nsaved for later.',
                  style:
                      TextStyle(
                    fontSize: 16,
                    height: 1.35,
                    fontWeight:
                        FontWeight
                            .w500,
                    color: colors
                        .onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          InkWell(
            borderRadius:
                BorderRadius.circular(
              42,
            ),
            onTap: () {
              Navigator.of(context)
                  .pushNamed(
                ProfileScreen
                    .routeName,
              );
            },
            child: Container(
              height: 78,
              width: 78,
              padding:
                  const EdgeInsets.all(
                4,
              ),
              decoration:
                  BoxDecoration(
                color:
                    colors.surface,
                shape:
                    BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withValues(
                      alpha: 0.10,
                    ),
                    blurRadius: 16,
                    offset:
                        const Offset(
                      0,
                      6,
                    ),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'images/profile.png',
                  fit:
                      BoxFit.cover,
                  errorBuilder: (
                    context,
                    error,
                    stackTrace,
                  ) {
                    return Icon(
                      Icons.person,
                      size: 40,
                      color: colors
                          .primary,
                    );
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
    final colors =
        Theme.of(context)
            .colorScheme;

    return Container(
      margin:
          const EdgeInsets.fromLTRB(
        22,
        16,
        22,
        28,
      ),
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius:
            BorderRadius.circular(
          28,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withValues(
              alpha: 0.07,
            ),
            blurRadius: 18,
            offset:
                const Offset(
              0,
              8,
            ),
          ),
        ],
      ),
      child: SizedBox(
        height: 92,
        child:
            ListView.separated(
          scrollDirection:
              Axis.horizontal,
          itemCount:
              _categories.length,
          separatorBuilder:
              (
            context,
            index,
          ) {
            return const SizedBox(
              width: 10,
            );
          },
          itemBuilder:
              (
            context,
            index,
          ) {
            final category =
                _categories[index];

            final label =
                category['label']
                    as String;

            final value =
                category['value']
                    as String;

            final icon =
                category['icon']
                    as IconData;

            return SavedCategoryItem(
              label: label,
              icon: icon,
              isSelected:
                  _selectedCategory ==
                      value,
              onTap: () {
                _selectCategory(
                  value,
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
  }) {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        22,
        8,
        22,
        16,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 22,
          fontWeight:
              FontWeight.w900,
          color: Theme.of(context)
              .colorScheme
              .onSurface,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final colors =
        Theme.of(context)
            .colorScheme;

    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        22,
        40,
        22,
        40,
      ),
      child: Column(
        children: [
          Icon(
            Icons
                .bookmark_border_rounded,
            size: 64,
            color: colors
                .onSurfaceVariant,
          ),

          const SizedBox(
            height: 14,
          ),

          Text(
            'No saved places yet',
            style: TextStyle(
              fontSize: 17,
              fontWeight:
                  FontWeight.w800,
              color:
                  colors.onSurface,
            ),
          ),

          const SizedBox(
            height: 6,
          ),

          Text(
            'Tap the bookmark icon on any place in Explore to save it here.',
            textAlign:
                TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              color: colors
                  .onSurfaceVariant,
              fontWeight:
                  FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _selectedCategoryLabel() {
    for (final category
        in _categories) {
      if (category['value'] ==
          _selectedCategory) {
        return category['label']
            as String;
      }
    }

    return _selectedCategory;
  }

  Widget _buildSavedList(
    List<SavedPlace> places,
  ) {
    if (places.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        _buildSectionHeader(
          title:
              _selectedCategory ==
                      'All'
                  ? 'All saved places'
                  : _selectedCategoryLabel(),
        ),

        for (final place in places)
          SavedPlaceCard(
            imagePath:
                place.imagePath,
            badgeIcon:
                place.badgeIcon,
            badgeColor:
                place.badgeColor,
            title: place.title,
            subtitle:
                place.subtitle,
            walkTime:
                place.walkTime,
            crowdText:
                place.crowdText,
            tags: place.tags,
            onTap: () {
              _openSavedPlace(
                place.id,
              );
            },
            onQuickRemove: () {
              _deletePlace(
                place,
              );
            },
          ),
      ],
    );
  }

  Widget _buildGuestPrompt() {
    final colors =
        Theme.of(context)
            .colorScheme;

    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        22,
        30,
        22,
        40,
      ),
      child: Column(
        children: [
          Icon(
            Icons
                .lock_outline_rounded,
            size: 56,
            color: colors
                .onSurfaceVariant,
          ),

          const SizedBox(
            height: 14,
          ),

          Text(
            'Saving places needs an account',
            style: TextStyle(
              fontSize: 17,
              fontWeight:
                  FontWeight.w800,
              color:
                  colors.onSurface,
            ),
          ),

          const SizedBox(
            height: 6,
          ),

          Text(
            'Guest access lets you browse the app, but saving places is only available with a full account.',
            textAlign:
                TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              color: colors
                  .onSurfaceVariant,
              fontWeight:
                  FontWeight.w500,
            ),
          ),

          const SizedBox(
            height: 18,
          ),

          ElevatedButton(
            onPressed: () {
              requireFullAccount(
                context,
                ref,
                message:
                    'Create a free account to start saving places.',
              );
            },
            child: const Text(
              'Create an account',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    Object error,
  ) {
    final colors =
        Theme.of(context)
            .colorScheme;

    final errorText =
        error.toString();

    final requiresIndex =
        errorText.contains(
          'FAILED_PRECONDITION',
        ) ||
        errorText
            .toLowerCase()
            .contains(
              'requires an index',
            );

    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 22,
        vertical: 40,
      ),
      child: Column(
        children: [
          Icon(
            requiresIndex
                ? Icons
                    .storage_outlined
                : Icons
                    .cloud_off_outlined,
            size: 48,
            color: colors
                .onSurfaceVariant,
          ),

          const SizedBox(
            height: 14,
          ),

          Text(
            requiresIndex
                ? 'Firestore index required'
                : 'Could not load saved places',
            textAlign:
                TextAlign.center,
            style: TextStyle(
              color:
                  colors.onSurface,
              fontWeight:
                  FontWeight.w900,
              fontSize: 17,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          Text(
            requiresIndex
                ? 'This query needs a Firestore composite index. Create the index requested by Firebase, then retry.'
                : 'Please check your connection and try again.',
            textAlign:
                TextAlign.center,
            style: TextStyle(
              color: colors
                  .onSurfaceVariant,
              fontWeight:
                  FontWeight.w500,
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          // useful while debugging
          SelectableText(
            errorText,
            textAlign:
                TextAlign.center,
            style: TextStyle(
              fontSize: 10.5,
              color: colors
                  .onSurfaceVariant,
            ),
          ),

          const SizedBox(
            height: 18,
          ),

          ElevatedButton.icon(
            onPressed:
                _retrySavedPlaces,
            icon: const Icon(
              Icons.refresh,
            ),
            label:
                const Text(
              'Retry',
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final user = ref
        .watch(
          firebaseServiceProvider,
        )
        .currentUser;

    final isGuest =
        user == null ||
        user.isAnonymous;

    final savedPlacesAsync =
        _selectedCategory ==
                'All'
            ? ref.watch(
                savedPlacesProvider,
              )
            : _selectedCategory ==
                    'StudyFood'
                ? ref.watch(
                    studyFoodSavedPlacesProvider,
                  )
                : ref.watch(
                    savedPlacesByCategoryProvider(
                      _selectedCategory,
                    ),
                  );

    final savedCountAsync =
        ref.watch(
      savedPlacesCountProvider,
    );

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          _retrySavedPlaces();

          await Future<void>
              .delayed(
            const Duration(
              milliseconds: 500,
            ),
          );
        },
        child: ListView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          padding:
              EdgeInsets.zero,
          children: [
            _buildHeader(
              context,
            ),

            _buildCategoryBar(),

            if (!isGuest)
              Padding(
                padding:
                    const EdgeInsets
                        .fromLTRB(
                  22,
                  0,
                  22,
                  14,
                ),
                child: Align(
                  alignment:
                      Alignment
                          .centerLeft,
                  child: Container(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 13,
                      vertical: 8,
                    ),
                    decoration:
                        BoxDecoration(
                      color: Theme.of(
                        context,
                      )
                          .colorScheme
                          .primary
                          .withValues(
                            alpha: 0.10,
                          ),
                      borderRadius:
                          BorderRadius
                              .circular(
                        14,
                      ),
                    ),
                    child: Text(
                      '${savedCountAsync.value ?? 0} places saved',
                      style:
                          TextStyle(
                        color: Theme.of(
                          context,
                        )
                            .colorScheme
                            .primary,
                        fontWeight:
                            FontWeight
                                .w800,
                        fontSize:
                            12.5,
                      ),
                    ),
                  ),
                ),
              ),

            if (isGuest)
              _buildGuestPrompt()
            else
              savedPlacesAsync.when(
                data: (
                  savedPlaces,
                ) {
                  return _buildSavedList(
                    savedPlaces,
                  );
                },
                loading: () {
                  return const Padding(
                    padding:
                        EdgeInsets
                            .symmetric(
                      vertical: 60,
                    ),
                    child: Center(
                      child:
                          CircularProgressIndicator(),
                    ),
                  );
                },
                error: (
                  error,
                  stackTrace,
                ) {
                  return _buildErrorState(
                    error,
                  );
                },
              ),

            const SizedBox(
              height: 28,
            ),
          ],
        ),
      ),
    );
  }
}