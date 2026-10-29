import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/firebase_service.dart';

// firebase auth instance
final firebaseAuthProvider =
    Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

// firebase authentication service
final firebaseServiceProvider =
    Provider<FirebaseService>((ref) {
  final auth =
      ref.watch(firebaseAuthProvider);

  return FirebaseService(auth);
});

// only tracks login/logout state
// AuthGate should watch this provider
final authStateProvider =
    StreamProvider<User?>((ref) {
  final firebaseService =
      ref.watch(firebaseServiceProvider);

  return firebaseService.authStateChanges;
});

// tracks changes to the current user's profile
// e.g. display name and email changes
final userProfileProvider =
    StreamProvider<User?>((ref) {
  final firebaseService =
      ref.watch(firebaseServiceProvider);

  return firebaseService.userChanges;
});