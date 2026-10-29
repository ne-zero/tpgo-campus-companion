import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';

// checks whether the current user is a full account (not a guest).
// if they are a guest, shows a friendly dialog explaining that this
// feature needs an account, with buttons to log in or register.
//
// returns true if the user can proceed (logged in with a real account),
// false if they are a guest and the dialog was shown instead.
//
// use this before any action that should be blocked for guest users:
// saving places, changing theme, booking facilities, etc.
bool requireFullAccount(
  BuildContext context,
  WidgetRef ref, {
  String message = 'Create a free account to unlock this feature.',
}) {
  final user = ref.read(firebaseServiceProvider).currentUser;

  final isGuest = user == null || user.isAnonymous;

  if (!isGuest) {
    return true;
  }

  showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Create an account'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Not now'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pushNamed(LoginScreen.routeName);
            },
            child: const Text('Log in'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pushNamed(RegisterScreen.routeName);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2637FF),
              foregroundColor: Colors.white,
            ),
            child: const Text('Register'),
          ),
        ],
      );
    },
  );

  return false;
}
