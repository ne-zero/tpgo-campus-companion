import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';
import '../../providers/biometric_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/notification_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/admin_config.dart';
import '../../utils/guest_guard.dart';
import '../../widgets/profile_menu_tile.dart';
import '../../widgets/profile_stat_item.dart';
import 'manage_locations_screen.dart';

// actions returned by the account preferences bottom sheet
enum _AccountAction {
  changeEmail,
  changePassword,
  resetPassword,
}

// stores values returned by the feedback dialog
class _FeedbackResult {
  const _FeedbackResult({
    required this.rating,
    required this.message,
  });

  final int rating;
  final String message;
}

// stores app preference choices until the sheet is fully closed
class _AppPreferencesResult {
  const _AppPreferencesResult({
    required this.themeMode,
    required this.accentColor,
    required this.biometricEnabled,
  });

  final ThemeMode themeMode;
  final Color accentColor;
  final bool biometricEnabled;
}

// profile page for tp go
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({
    super.key,
  });

  static const String routeName = '/profile';

  void _showMessage(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
        .clearSnackBars();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Colors.red
            : const Color(0xFF2637FF),
      ),
    );
  }

  String _firebaseErrorMessage(
    FirebaseAuthException error,
  ) {
    if (error.code ==
        'requires-recent-login') {
      return 'Please log out and log in again before making this change.';
    }

    if (error.code == 'invalid-email') {
      return 'Please enter a valid email address.';
    }

    if (error.code ==
        'email-already-in-use') {
      return 'This email is already being used.';
    }

    if (error.code == 'no-email') {
      return 'This account does not have an email address.';
    }

    if (error.code == 'no-user') {
      return 'No user is currently logged in.';
    }

    if (error.code == 'guest-account') {
      return error.message ??
          'This feature is not available for guest accounts.';
    }

    if (error.code ==
        'no-password-provider') {
      return error.message ??
          'This account does not have a password to change.';
    }

    if (error.code == 'wrong-password' ||
        error.code ==
            'invalid-credential') {
      return 'Your current password is incorrect.';
    }

    if (error.code == 'weak-password') {
      return 'Your new password is too weak. Use at least 6 characters.';
    }

    return error.message ??
        'Something went wrong.';
  }

  // appearance, accent colour and biometric settings
  // choices stay local while the sheet is open, then are applied only
  // after the modal has fully closed to avoid theme rebuild crashes
  Future<void> _showAppPreferences(
    BuildContext context,
    WidgetRef ref,
  ) async {
    if (!requireFullAccount(
      context,
      ref,
      message:
          'Create a free account to personalise your app theme.',
    )) {
      return;
    }

    ThemeMode selectedThemeMode =
        ref.read(themeModeProvider);

    Color selectedAccentColor =
        ref.read(accentColorProvider);

    bool selectedBiometric =
        ref.read(biometricEnabledProvider);

    final biometricAvailable =
        ref.read(biometricAvailableProvider).value ?? false;

    final result =
        await showModalBottomSheet<_AppPreferencesResult>(
      context: context,
      backgroundColor:
          Theme.of(context).colorScheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final colors =
                Theme.of(context).colorScheme;

            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  22,
                  18,
                  22,
                  24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Appearance',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Choose how TP Go! looks on your device.',
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 18),
                    for (final entry in {
                      ThemeMode.light: 'Light',
                      ThemeMode.dark: 'Dark',
                      ThemeMode.system: 'Match device setting',
                    }.entries)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          entry.value,
                          style: TextStyle(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        trailing:
                            selectedThemeMode == entry.key
                                ? Icon(
                                    Icons.check_circle,
                                    color: selectedAccentColor,
                                  )
                                : Icon(
                                    Icons.circle_outlined,
                                    color: colors.onSurfaceVariant,
                                  ),
                        onTap: () {
                          setSheetState(() {
                            selectedThemeMode = entry.key;
                          });
                        },
                      ),
                    const SizedBox(height: 8),
                    Divider(color: colors.outlineVariant),
                    const SizedBox(height: 8),
                    Text(
                      'Accent Colour',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 14,
                      runSpacing: 14,
                      children: AppTheme
                          .accentPresets.entries
                          .map((entry) {
                        final selected =
                            selectedAccentColor.toARGB32() ==
                                entry.value.toARGB32();

                        return GestureDetector(
                          onTap: () {
                            setSheetState(() {
                              selectedAccentColor = entry.value;
                            });
                          },
                          child: Column(
                            children: [
                              Container(
                                height: 44,
                                width: 44,
                                decoration: BoxDecoration(
                                  color: entry.value,
                                  shape: BoxShape.circle,
                                  border: selected
                                      ? Border.all(
                                          color: colors.onSurface,
                                          width: 3,
                                        )
                                      : null,
                                ),
                                child: selected
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 20,
                                      )
                                    : null,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                entry.key,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Divider(color: colors.outlineVariant),
                    const SizedBox(height: 8),
                    if (biometricAvailable)
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Biometric app lock',
                          style: TextStyle(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(
                          'Require fingerprint when TP Go! is opened again.',
                          style: TextStyle(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        value: selectedBiometric,
                        onChanged: (value) {
                          setSheetState(() {
                            selectedBiometric = value;
                          });
                        },
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Biometric unlock is not available on this device.',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(bottomSheetContext).pop(
                            _AppPreferencesResult(
                              themeMode: selectedThemeMode,
                              accentColor: selectedAccentColor,
                              biometricEnabled: selectedBiometric,
                            ),
                          );
                        },
                        child: const Text('Apply Changes'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (result == null || !context.mounted) {
      return;
    }

    // wait for the modal exit animation before rebuilding MaterialApp
    await Future<void>.delayed(
      const Duration(milliseconds: 300),
    );

    if (!context.mounted) {
      return;
    }

    if (ref.read(themeModeProvider) != result.themeMode) {
      ref
          .read(themeModeProvider.notifier)
          .setThemeMode(result.themeMode);
    }

    if (ref.read(accentColorProvider).toARGB32() !=
        result.accentColor.toARGB32()) {
      ref
          .read(accentColorProvider.notifier)
          .setAccentColor(result.accentColor);
    }

    if (ref.read(biometricEnabledProvider) !=
        result.biometricEnabled) {
      await ref
          .read(biometricEnabledProvider.notifier)
          .setEnabled(result.biometricEnabled);
    }
  }

  // edit profile dialog only gathers the value
  // firebase update happens after the dialog closes
  Future<void> _showEditProfileDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final user = ref
        .read(firebaseServiceProvider)
        .currentUser;

    if (user == null ||
        user.isAnonymous) {
      requireFullAccount(
        context,
        ref,
        message:
            'Create a free account to edit your profile.',
      );

      return;
    }

    final formKey =
        GlobalKey<FormState>();

    final controller =
        TextEditingController(
      text: user.displayName ?? '',
    );

    final String? newName =
        await showDialog<String>(
      context: context,
      builder: (
        dialogContext,
      ) {
        return AlertDialog(
          title:
              const Text('Edit Profile'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              textCapitalization:
                  TextCapitalization.words,
              decoration:
                  const InputDecoration(
                labelText:
                    'Display name',
                prefixIcon: Icon(
                  Icons.person_outline,
                ),
              ),
              validator: (
                value,
              ) {
                if (value == null ||
                    value
                        .trim()
                        .isEmpty) {
                  return 'Please enter your name.';
                }

                if (value
                        .trim()
                        .length <
                    2) {
                  return 'Name must be at least 2 characters.';
                }

                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop();
              },
              child:
                  const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (!formKey
                    .currentState!
                    .validate()) {
                  return;
                }

                Navigator.of(
                  dialogContext,
                ).pop(
                  controller.text
                      .trim(),
                );
              },
              child:
                  const Text('Save'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (newName == null) {
      return;
    }

    // dialog is now completely gone
    try {
      await ref
          .read(firebaseServiceProvider)
          .updateDisplayName(
            newName,
          );

      if (!context.mounted) {
        return;
      }

      _showMessage(
        context,
        'Profile updated.',
      );
    } on FirebaseAuthException catch (
        error) {
      if (!context.mounted) {
        return;
      }

      _showMessage(
        context,
        _firebaseErrorMessage(
          error,
        ),
        isError: true,
      );
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      _showMessage(
        context,
        'Could not update profile.',
        isError: true,
      );
    }
  }

  void _showPaymentInfo(
    BuildContext context,
  ) {
    showDialog(
      context: context,
      builder: (
        dialogContext,
      ) {
        return AlertDialog(
          title: const Text(
            'Payment & Subscription',
          ),
          content: const Text(
            'TP Go! does not have a subscription plan. Payments are made '
            'per-booking through NETS QR when you book a campus facility. '
            'Check "My Bookings" from the home screen to see your booking '
            'and payment history.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop();
              },
              child:
                  const Text('Got it'),
            ),
          ],
        );
      },
    );
  }

  void _showLanguageSelector(
    BuildContext context,
    WidgetRef ref,
  ) {
    final languages = [
      'English',
      'Bahasa Melayu',
      '中文',
      'தமிழ்',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor:
          Theme.of(context)
              .colorScheme
              .surface,
      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (
        bottomSheetContext,
      ) {
        return Consumer(
          builder: (
            context,
            sheetRef,
            child,
          ) {
            final selected =
                sheetRef.watch(
              languageProvider,
            );

            final colors =
                Theme.of(context)
                    .colorScheme;

            return SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets
                        .fromLTRB(
                  22,
                  18,
                  22,
                  24,
                ),
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      'Language',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight
                                .w900,
                        color: colors
                            .onSurface,
                      ),
                    ),

                    const SizedBox(
                      height: 6,
                    ),

                    Text(
                      'This currently saves your preferred language only. '
                      'The app content remains English until full localisation is added.',
                      style:
                          TextStyle(
                        fontSize: 12.5,
                        color: colors
                            .onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    for (final language
                        in languages)
                      ListTile(
                        contentPadding:
                            EdgeInsets
                                .zero,
                        title: Text(
                          language,
                          style:
                              TextStyle(
                            color: colors
                                .onSurface,
                            fontWeight:
                                FontWeight
                                    .w700,
                          ),
                        ),
                        trailing:
                            selected ==
                                    language
                                ? Icon(
                                    Icons
                                        .check_circle,
                                    color: colors
                                        .primary,
                                  )
                                : Icon(
                                    Icons
                                        .circle_outlined,
                                    color: colors
                                        .onSurfaceVariant,
                                  ),
                        onTap: () {
                          sheetRef
                              .read(
                                languageProvider
                                    .notifier,
                              )
                              .setLanguage(
                                language,
                              );
                        },
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // feedback dialog only gathers values
  // firestore write runs afterwards
  Future<void> _showFeedbackDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final formKey =
        GlobalKey<FormState>();

    final controller =
        TextEditingController();

    int rating = 5;

    final _FeedbackResult? result =
        await showDialog<
            _FeedbackResult>(
      context: context,
      builder: (
        dialogContext,
      ) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              title: const Text(
                'Send Feedback',
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .center,
                      children:
                          List.generate(
                        5,
                        (
                          index,
                        ) {
                          final star =
                              index + 1;

                          return IconButton(
                            onPressed:
                                () {
                              setDialogState(
                                () {
                                  rating =
                                      star;
                                },
                              );
                            },
                            icon: Icon(
                              star <=
                                      rating
                                  ? Icons.star
                                  : Icons
                                      .star_border,
                              color:
                                  const Color(
                                0xFFFFB000,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    TextFormField(
                      controller:
                          controller,
                      maxLines: 3,
                      decoration:
                          const InputDecoration(
                        hintText:
                            'Tell us what you think...',
                      ),
                      validator: (
                        value,
                      ) {
                        if (value ==
                                null ||
                            value
                                .trim()
                                .isEmpty) {
                          return 'Please enter your feedback.';
                        }

                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(
                      dialogContext,
                    ).pop();
                  },
                  child: const Text(
                    'Cancel',
                  ),
                ),

                ElevatedButton(
                  onPressed: () {
                    if (!formKey
                        .currentState!
                        .validate()) {
                      return;
                    }

                    Navigator.of(
                      dialogContext,
                    ).pop(
                      _FeedbackResult(
                        rating:
                            rating,
                        message:
                            controller
                                .text
                                .trim(),
                      ),
                    );
                  },
                  child:
                      const Text(
                    'Submit',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();

    if (result == null) {
      return;
    }

    try {
      final user = ref
          .read(
            firebaseServiceProvider,
          )
          .currentUser;

      await FirebaseFirestore
          .instance
          .collection(
            'feedback',
          )
          .add({
        'userId':
            user?.uid ?? 'guest',
        'rating':
            result.rating,
        'message':
            result.message,
        'submittedAt':
            Timestamp.now(),
      });

      if (!context.mounted) {
        return;
      }

      _showMessage(
        context,
        'Thanks for your feedback!',
      );
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      _showMessage(
        context,
        'Could not send feedback.',
        isError: true,
      );
    }
  }

  void _showAboutDialog(
    BuildContext context,
  ) {
    showDialog(
      context: context,
      builder: (
        dialogContext,
      ) {
        return AlertDialog(
          title:
              const Text('About TP Go!'),
          content: const Column(
            mainAxisSize:
                MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [
              Text(
                'TP Go! v1.2.0',
                style: TextStyle(
                  fontWeight:
                      FontWeight
                          .w800,
                ),
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                'A smart campus assistant for Temasek Polytechnic students - '
                'discover places, save favourites, book facilities, and get '
                'AI-powered campus recommendations.',
              ),
              SizedBox(
                height: 12,
              ),
              Text(
                'Built with Flutter, Firebase, and Riverpod.',
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop();
              },
              child:
                  const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendPasswordReset(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      await ref
          .read(
            firebaseServiceProvider,
          )
          .sendResetEmailForCurrentUser();

      if (!context.mounted) {
        return;
      }

      _showMessage(
        context,
        'Password reset email sent.',
      );
    } on FirebaseAuthException catch (
        error) {
      if (!context.mounted) {
        return;
      }

      _showMessage(
        context,
        _firebaseErrorMessage(
          error,
        ),
        isError: true,
      );
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      _showMessage(
        context,
        'Failed to send password reset email.',
        isError: true,
      );
    }
  }

  // returns the new email from the dialog
  Future<void> _showChangeEmailDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final formKey =
        GlobalKey<FormState>();

    final controller =
        TextEditingController();

    final String? newEmail =
        await showDialog<String>(
      context: context,
      builder: (
        dialogContext,
      ) {
        return AlertDialog(
          title:
              const Text('Change Email'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              keyboardType:
                  TextInputType
                      .emailAddress,
              decoration:
                  const InputDecoration(
                labelText:
                    'New email',
                prefixIcon: Icon(
                  Icons.email_outlined,
                ),
              ),
              validator: (
                value,
              ) {
                if (value == null ||
                    value
                        .trim()
                        .isEmpty) {
                  return 'Please enter your new email.';
                }

                if (!value
                        .contains('@') ||
                    !value
                        .contains('.')) {
                  return 'Please enter a valid email.';
                }

                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop();
              },
              child:
                  const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () {
                if (!formKey
                    .currentState!
                    .validate()) {
                  return;
                }

                Navigator.of(
                  dialogContext,
                ).pop(
                  controller.text
                      .trim(),
                );
              },
              child:
                  const Text(
                'Send Link',
              ),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (newEmail == null) {
      return;
    }

    try {
      await ref
          .read(firebaseServiceProvider)
          .changeEmail(
            newEmail,
          );

      if (!context.mounted) {
        return;
      }

      _showMessage(
        context,
        'Email change verification sent. Check your new email.',
      );
    } on FirebaseAuthException catch (
        error) {
      if (!context.mounted) {
        return;
      }

      _showMessage(
        context,
        _firebaseErrorMessage(
          error,
        ),
        isError: true,
      );
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      _showMessage(
        context,
        'Failed to change email.',
        isError: true,
      );
    }
  }

  // password dialog returns current + new password
  Future<void> _showChangePasswordDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final formKey =
        GlobalKey<FormState>();

    final currentController =
        TextEditingController();

    final newController =
        TextEditingController();

    final confirmController =
        TextEditingController();

    final List<String>? values =
        await showDialog<
            List<String>>(
      context: context,
      builder: (
        dialogContext,
      ) {
        return AlertDialog(
          title: const Text(
            'Change Password',
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                TextFormField(
                  controller:
                      currentController,
                  obscureText: true,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Current password',
                    prefixIcon: Icon(
                      Icons.lock_outline,
                    ),
                  ),
                  validator: (
                    value,
                  ) {
                    if (value == null ||
                        value.isEmpty) {
                      return 'Please enter your current password.';
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: 14,
                ),

                TextFormField(
                  controller:
                      newController,
                  obscureText: true,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'New password',
                    prefixIcon: Icon(
                      Icons.lock_reset,
                    ),
                  ),
                  validator: (
                    value,
                  ) {
                    if (value == null ||
                        value.isEmpty) {
                      return 'Please enter a new password.';
                    }

                    if (value.length <
                        6) {
                      return 'Password must be at least 6 characters.';
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: 14,
                ),

                TextFormField(
                  controller:
                      confirmController,
                  obscureText: true,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Confirm new password',
                    prefixIcon: Icon(
                      Icons.lock_reset,
                    ),
                  ),
                  validator: (
                    value,
                  ) {
                    if (value == null ||
                        value.isEmpty) {
                      return 'Please confirm your new password.';
                    }

                    if (value !=
                        newController.text) {
                      return 'Passwords do not match.';
                    }

                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop();
              },
              child:
                  const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () {
                if (!formKey
                    .currentState!
                    .validate()) {
                  return;
                }

                Navigator.of(
                  dialogContext,
                ).pop([
                  currentController.text,
                  newController.text,
                ]);
              },
              child: const Text(
                'Change Password',
              ),
            ),
          ],
        );
      },
    );

    currentController.dispose();
    newController.dispose();
    confirmController.dispose();

    if (values == null) {
      return;
    }

    try {
      await ref
          .read(firebaseServiceProvider)
          .changePassword(
            currentPassword:
                values[0],
            newPassword:
                values[1],
          );

      if (!context.mounted) {
        return;
      }

      _showMessage(
        context,
        'Password changed successfully.',
      );
    } on FirebaseAuthException catch (
        error) {
      if (!context.mounted) {
        return;
      }

      _showMessage(
        context,
        _firebaseErrorMessage(
          error,
        ),
        isError: true,
      );
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      _showMessage(
        context,
        'Failed to change password.',
        isError: true,
      );
    }
  }

  // account sheet returns action first
  // another dialog opens only after this route is gone
  Future<void> _showAccountPreferences(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final _AccountAction? action =
        await showModalBottomSheet<
            _AccountAction>(
      context: context,
      backgroundColor:
          Theme.of(context)
              .colorScheme
              .surface,
      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (
        bottomSheetContext,
      ) {
        final colors =
            Theme.of(
          bottomSheetContext,
        ).colorScheme;

        return SafeArea(
          child: Padding(
            padding:
                const EdgeInsets
                    .fromLTRB(
              22,
              18,
              22,
              24,
            ),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                Container(
                  height: 5,
                  width: 44,
                  decoration:
                      BoxDecoration(
                    color: colors
                        .outlineVariant,
                    borderRadius:
                        BorderRadius
                            .circular(
                      20,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                Align(
                  alignment:
                      Alignment
                          .centerLeft,
                  child: Text(
                    'Account Preferences',
                    style:
                        TextStyle(
                      fontSize: 22,
                      fontWeight:
                          FontWeight
                              .w900,
                      color: colors
                          .onSurface,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 6,
                ),

                Align(
                  alignment:
                      Alignment
                          .centerLeft,
                  child: Text(
                    'Manage your email and password settings.',
                    style:
                        TextStyle(
                      color: colors
                          .onSurfaceVariant,
                      fontWeight:
                          FontWeight
                              .w500,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 18,
                ),

                ListTile(
                  leading: Icon(
                    Icons.email_outlined,
                    color:
                        colors.primary,
                  ),
                  title: Text(
                    'Change email',
                    style:
                        TextStyle(
                      fontWeight:
                          FontWeight
                              .w800,
                      color: colors
                          .onSurface,
                    ),
                  ),
                  subtitle: Text(
                    'Send verification link to new email',
                    style:
                        TextStyle(
                      color: colors
                          .onSurfaceVariant,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(
                      bottomSheetContext,
                    ).pop(
                      _AccountAction
                          .changeEmail,
                    );
                  },
                ),

                Divider(
                  color: colors
                      .outlineVariant,
                ),

                ListTile(
                  leading: Icon(
                    Icons
                        .password_outlined,
                    color:
                        colors.primary,
                  ),
                  title: Text(
                    'Change password',
                    style:
                        TextStyle(
                      fontWeight:
                          FontWeight
                              .w800,
                      color: colors
                          .onSurface,
                    ),
                  ),
                  subtitle: Text(
                    'Update your password in the app',
                    style:
                        TextStyle(
                      color: colors
                          .onSurfaceVariant,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(
                      bottomSheetContext,
                    ).pop(
                      _AccountAction
                          .changePassword,
                    );
                  },
                ),

                Divider(
                  color: colors
                      .outlineVariant,
                ),

                ListTile(
                  leading: Icon(
                    Icons.lock_reset,
                    color:
                        colors.primary,
                  ),
                  title: Text(
                    'Reset password',
                    style:
                        TextStyle(
                      fontWeight:
                          FontWeight
                              .w800,
                      color: colors
                          .onSurface,
                    ),
                  ),
                  subtitle: Text(
                    'Send password reset email',
                    style:
                        TextStyle(
                      color: colors
                          .onSurfaceVariant,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(
                      bottomSheetContext,
                    ).pop(
                      _AccountAction
                          .resetPassword,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!context.mounted ||
        action == null) {
      return;
    }

    // waits for the bottom sheet's close ANIMATION to fully finish
    // (not just one microtask) before opening the next dialog.
    // Duration.zero only yields one event-loop turn, which isn't long
    // enough for showModalBottomSheet's ~250ms exit transition - opening
    // a new dialog while that route is still being removed is what was
    // causing the "_dependents.isEmpty" crash.
    await Future<void>.delayed(
      const Duration(milliseconds: 300),
    );

    if (!context.mounted) {
      return;
    }

    switch (action) {
      case _AccountAction.changeEmail:
        await _showChangeEmailDialog(
          context,
          ref,
        );
        break;

      case _AccountAction.changePassword:
        await _showChangePasswordDialog(
          context,
          ref,
        );
        break;

      case _AccountAction.resetPassword:
        await _sendPasswordReset(
          context,
          ref,
        );
        break;
    }
  }

  Future<void> _logout(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final bool? confirmed =
        await showDialog<bool>(
      context: context,
      builder: (
        dialogContext,
      ) {
        return AlertDialog(
          title:
              const Text('Log out'),
          content: const Text(
            'Are you sure you want to log out?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child:
                  const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              style:
                  ElevatedButton
                      .styleFrom(
                backgroundColor:
                    Colors.red,
                foregroundColor:
                    Colors.white,
              ),
              child:
                  const Text('Log out'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      ref
          .read(
            hasUnlockedProvider
                .notifier,
          )
          .state = false;

      await ref
          .read(firebaseServiceProvider)
          .logout();

      // no Navigator call here
      // AuthGate sees user == null and shows LoginScreen
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      _showMessage(
        context,
        'Logout failed. Please try again.',
        isError: true,
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
        12,
        18,
        22,
        18,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () {
              Navigator.of(context)
                  .pop();
            },
            icon: Icon(
              Icons
                  .arrow_back_ios_new_rounded,
              color:
                  colors.onSurface,
            ),
          ),

          const SizedBox(
            width: 2,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  'My Profile',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight:
                        FontWeight
                            .w900,
                    color:
                        colors.onSurface,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'Manage your account and preferences',
                  style: TextStyle(
                    fontSize: 15,
                    color: colors
                        .onSurfaceVariant,
                    fontWeight:
                        FontWeight
                            .w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(
    BuildContext context,
    WidgetRef ref,
    User? user,
  ) {
    final colors =
        Theme.of(context)
            .colorScheme;

    final guest =
        user?.isAnonymous ?? false;

    final displayName = guest
        ? 'Guest User'
        : user?.displayName ==
                    null ||
                user!
                    .displayName!
                    .isEmpty
            ? 'TP Go! User'
            : user.displayName!;

    final email = guest
        ? 'Guest account'
        : user?.email ??
            'No email';

    return Container(
      margin:
          const EdgeInsets.fromLTRB(
        22,
        16,
        22,
        28,
      ),
      padding:
          const EdgeInsets.fromLTRB(
        22,
        24,
        22,
        24,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius:
            BorderRadius.circular(
          28,
        ),
        border: Border.all(
          color:
              colors.outlineVariant,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 92,
                width: 92,
                padding:
                    const EdgeInsets
                        .all(
                  4,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      colors.surface,
                  shape:
                      BoxShape.circle,
                  border: Border.all(
                    color: colors
                        .outlineVariant,
                  ),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'images/profile.png',
                    fit: BoxFit.cover,
                    errorBuilder: (
                      context,
                      error,
                      stackTrace,
                    ) {
                      return Icon(
                        Icons.person,
                        size: 48,
                        color: colors
                            .primary,
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(
                width: 18,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow:
                          TextOverflow
                              .ellipsis,
                      style:
                          TextStyle(
                        fontSize: 21,
                        fontWeight:
                            FontWeight
                                .w900,
                        color: colors
                            .onSurface,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Text(
                      email,
                      maxLines: 1,
                      overflow:
                          TextOverflow
                              .ellipsis,
                      style:
                          TextStyle(
                        fontSize: 13.5,
                        color: colors
                            .onSurfaceVariant,
                        fontWeight:
                            FontWeight
                                .w600,
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    Row(
                      children: [
                        Icon(
                          Icons
                              .location_on,
                          color: colors
                              .primary,
                          size: 18,
                        ),
                        const SizedBox(
                          width: 6,
                        ),
                        Expanded(
                          child: Text(
                            'Block 22, Level 3',
                            maxLines: 1,
                            overflow:
                                TextOverflow
                                    .ellipsis,
                            style:
                                TextStyle(
                              color: colors
                                  .onSurfaceVariant,
                              fontWeight:
                                  FontWeight
                                      .w700,
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

          const SizedBox(
            height: 16,
          ),

          Align(
            alignment:
                Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                _showEditProfileDialog(
                  context,
                  ref,
                );
              },
              child: const Text(
                'Edit profile',
                style: TextStyle(
                  fontWeight:
                      FontWeight
                          .w900,
                ),
              ),
            ),
          ),

          const SizedBox(
            height: 18,
          ),

          Divider(
            color:
                colors.outlineVariant,
          ),

          const SizedBox(
            height: 22,
          ),

          Row(
            children: [
              const ProfileStatItem(
                icon:
                    Icons.bookmark_border,
                value: '24',
                label:
                    'Saved places',
              ),

              Container(
                height: 55,
                width: 1,
                color: colors
                    .outlineVariant,
              ),

              const ProfileStatItem(
                icon:
                    Icons.auto_awesome,
                value: '18',
                label:
                    'AI Tips read',
              ),

              Container(
                height: 55,
                width: 1,
                color: colors
                    .outlineVariant,
              ),

              const ProfileStatItem(
                icon: Icons
                    .directions_walk,
                value: '25 km',
                label:
                    'Walked in campus',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
    BuildContext context,
    String title,
  ) {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        22,
        2,
        22,
        14,
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

  Widget _buildSectionCard(
    BuildContext context, {
    required List<Widget> children,
  }) {
    final colors =
        Theme.of(context)
            .colorScheme;

    // Material fixes ListTile ink/background warnings too
    return Container(
      margin:
          const EdgeInsets.fromLTRB(
        22,
        0,
        22,
        28,
      ),
      child: Material(
        color: colors.surface,
        borderRadius:
            BorderRadius.circular(
          22,
        ),
        clipBehavior:
            Clip.antiAlias,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: colors
                  .outlineVariant,
            ),
            borderRadius:
                BorderRadius.circular(
              22,
            ),
          ),
          child: Column(
            children: children,
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(
    BuildContext context,
    WidgetRef ref,
  ) {
    return Container(
      margin:
          const EdgeInsets.fromLTRB(
        22,
        4,
        22,
        28,
      ),
      width: double.infinity,
      height: 70,
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .errorContainer,
        borderRadius:
            BorderRadius.circular(
          18,
        ),
      ),
      child: TextButton.icon(
        onPressed: () {
          _logout(
            context,
            ref,
          );
        },
        icon: Icon(
          Icons.logout,
          color: Theme.of(context)
              .colorScheme
              .onErrorContainer,
          size: 28,
        ),
        label: Text(
          'Log out',
          style: TextStyle(
            color: Theme.of(context)
                .colorScheme
                .onErrorContainer,
            fontSize: 17,
            fontWeight:
                FontWeight.w900,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    // watches profile changes such as display name/email
    // this does not control AuthGate
    final profileState =
        ref.watch(
      userProfileProvider,
    );

    final User? user =
        profileState.when(
      data: (
        value,
      ) =>
          value,
      loading: () => ref
          .read(
            firebaseServiceProvider,
          )
          .currentUser,
      error: (
        error,
        stackTrace,
      ) =>
          ref
              .read(
                firebaseServiceProvider,
              )
              .currentUser,
    );

    final language =
        ref.watch(
      languageProvider,
    );

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding:
              EdgeInsets.zero,
          children: [
            _buildHeader(
              context,
            ),

            _buildProfileCard(
              context,
              ref,
              user,
            ),

            _buildSectionTitle(
              context,
              'Account',
            ),

            _buildSectionCard(
              context,
              children: [
                ProfileMenuTile(
                  icon: Icons
                      .person_outline,
                  title:
                      'Personal Information',
                  onTap: () {
                    _showEditProfileDialog(
                      context,
                      ref,
                    );
                  },
                ),

                ProfileMenuTile(
                  icon: Icons
                      .admin_panel_settings_outlined,
                  title:
                      'Account Preferences',
                  onTap: () {
                    _showAccountPreferences(
                      context,
                      ref,
                    );
                  },
                ),

                ProfileMenuTile(
                  icon: Icons
                      .payment_outlined,
                  title:
                      'Payment & Subscription',
                  showDivider: false,
                  onTap: () {
                    _showPaymentInfo(
                      context,
                    );
                  },
                ),
              ],
            ),

            if (isAdminEmail(
              user?.email,
            )) ...[
              _buildSectionTitle(
                context,
                'Admin',
              ),

              _buildSectionCard(
                context,
                children: [
                  ProfileMenuTile(
                    icon: Icons
                        .edit_location_alt_outlined,
                    title:
                        'Manage Locations',
                    trailingText:
                        'Add / remove',
                    onTap: () {
                      Navigator.of(
                        context,
                      ).pushNamed(
                        ManageLocationsScreen
                            .routeName,
                      );
                    },
                  ),

                  ProfileMenuTile(
                    icon: Icons
                        .notifications_active_outlined,
                    title:
                        'Test Notification',
                    showDivider: false,
                    onTap: () async {
                      await NotificationService()
                          .notifyLocationStatusChange(
                        locationName:
                            'Library Level 7',
                        newStatus:
                            'Under Renovation',
                      );

                      if (!context
                          .mounted) {
                        return;
                      }

                      _showMessage(
                        context,
                        'Notification sent.',
                      );
                    },
                  ),
                ],
              ),
            ],

            _buildSectionTitle(
              context,
              'Preferences',
            ),

            _buildSectionCard(
              context,
              children: [
                ProfileMenuTile(
                  icon: Icons.tune,
                  title:
                      'App Preferences',
                  onTap: () {
                    _showAppPreferences(
                      context,
                      ref,
                    );
                  },
                ),

                ProfileMenuTile(
                  icon:
                      Icons.language,
                  title:
                      'Language',
                  trailingText:
                      language,
                  showDivider: false,
                  onTap: () {
                    _showLanguageSelector(
                      context,
                      ref,
                    );
                  },
                ),
              ],
            ),

            _buildSectionTitle(
              context,
              'Support',
            ),

            _buildSectionCard(
              context,
              children: [
                ProfileMenuTile(
                  icon: Icons
                      .feedback_outlined,
                  title:
                      'Send Feedback',
                  onTap: () {
                    _showFeedbackDialog(
                      context,
                      ref,
                    );
                  },
                ),

                ProfileMenuTile(
                  icon:
                      Icons.info_outline,
                  title:
                      'About TP Go!',
                  trailingText:
                      'Version 1.2.0',
                  showDivider: false,
                  onTap: () {
                    _showAboutDialog(
                      context,
                    );
                  },
                ),
              ],
            ),

            _buildLogoutButton(
              context,
              ref,
            ),

            const SizedBox(
              height: 18,
            ),
          ],
        ),
      ),
    );
  }
}