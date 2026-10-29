import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';

import 'providers/auth_provider.dart';
import 'providers/biometric_provider.dart';
import 'providers/theme_provider.dart';

import 'screens/auth/biometric_lock_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';

import 'screens/main/ai_chat_screen.dart';
import 'screens/main/book_facility_screen.dart';
import 'screens/main/main_screen.dart';
import 'screens/main/manage_locations_screen.dart';
import 'screens/main/my_bookings_screen.dart';
import 'screens/main/nets_payment_screen.dart';
import 'screens/main/profile_screen.dart';

import 'services/catalog_service.dart';
import 'services/notification_service.dart';

import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding
      .ensureInitialized();

  await Firebase.initializeApp(
    options:
        DefaultFirebaseOptions
            .currentPlatform,
  );

  // loads the saved biometric preference
  // before flutter builds the app
  final bool biometricEnabled =
      await loadBiometricEnabledPreference();

  runApp(
    ProviderScope(
      overrides: [
        initialBiometricEnabledProvider
            .overrideWithValue(
          biometricEnabled,
        ),
      ],
      child: const MyApp(),
    ),
  );

  // non-essential startup work runs after the UI is visible
  // so a Firestore/network/notification issue cannot leave a black screen
  unawaited(_initializeOptionalServices());
}

Future<void> _initializeOptionalServices() async {
  try {
    await CatalogService().seedIfEmpty();
  } catch (error) {
    debugPrint('Catalog seed failed: $error');
  }

  try {
    await NotificationService().init();
  } catch (error) {
    debugPrint('Notification init failed: $error');
  }
}

// main tp go application
class MyApp
    extends ConsumerWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final themeMode =
        ref.watch(
      themeModeProvider,
    );

    final accentColor =
        ref.watch(
      accentColorProvider,
    );

    return MaterialApp(
      debugShowCheckedModeBanner:
          false,

      scrollBehavior:
          const MaterialScrollBehavior()
              .copyWith(
        overscroll: false,
      ),

      title: 'TP Go!',

      theme:
          AppTheme.lightTheme(
        accentColor,
      ),

      darkTheme:
          AppTheme.darkTheme(
        accentColor,
      ),

      themeMode:
          themeMode,

      home:
          const AuthGate(),

      routes: {
        LoginScreen.routeName:
            (context) =>
                const LoginScreen(),

        RegisterScreen.routeName:
            (context) =>
                const RegisterScreen(),

        ForgotPasswordScreen.routeName:
            (context) =>
                const ForgotPasswordScreen(),

        MainScreen.routeName:
            (context) =>
                const MainScreen(),

        ProfileScreen.routeName:
            (context) =>
                const ProfileScreen(),

        BookFacilityScreen.routeName:
            (context) =>
                const BookFacilityScreen(),

        NetsPaymentScreen.routeName:
            (context) =>
                const NetsPaymentScreen(),

        MyBookingsScreen.routeName:
            (context) =>
                const MyBookingsScreen(),

        AiChatScreen.routeName:
            (context) =>
                const AiChatScreen(),

        ManageLocationsScreen.routeName:
            (context) =>
                const ManageLocationsScreen(),
      },
    );
  }
}

// decides what screen should appear when tp go starts
class AuthGate
    extends ConsumerWidget {
  const AuthGate({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final authState =
        ref.watch(
      authStateProvider,
    );

    return authState.when(
      loading: () {
        return const Scaffold(
          body: Center(
            child:
                CircularProgressIndicator(),
          ),
        );
      },

      error: (
        error,
        stackTrace,
      ) {
        return const Scaffold(
          body: Center(
            child: Text(
              'Something went wrong. Please restart the app.',
            ),
          ),
        );
      },

      data: (user) {
        // user has no existing firebase session
        // normal login is required
        if (user == null) {
          return const LoginScreen();
        }

        final bool biometricEnabled =
            ref.watch(
          biometricEnabledProvider,
        );

        final bool hasUnlocked =
            ref.watch(
          hasUnlockedProvider,
        );

        // firebase session still exists,
        // but biometric protection is enabled
        //
        // fingerprint must succeed before the user
        // can enter the main application
        if (biometricEnabled &&
            !hasUnlocked) {
          return const BiometricLockScreen();
        }

        return const MainScreen();
      },
    );
  }
}