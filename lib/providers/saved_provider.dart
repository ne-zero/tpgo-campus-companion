import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/saved_place.dart';
import '../services/firestore_service.dart';
import 'auth_provider.dart';

// firestore service used for saved place CRUD
final firestoreServiceProvider =
    Provider<FirestoreService>((ref) {
  return FirestoreService();
});

// READ ALL
// current user's saved places sorted newest first
final savedPlacesProvider =
    StreamProvider<List<SavedPlace>>((ref) {
  final authState =
      ref.watch(authStateProvider);

  final firestoreService =
      ref.watch(firestoreServiceProvider);

  final user =
      authState.value;

  if (user == null) {
    return Stream.value([]);
  }

  return firestoreService
      .getSavedPlaces(user.uid);
});

// ADVANCED QUERY
// different fields:
// userId == current user
// AND category == selected category
final savedPlacesByCategoryProvider =
    StreamProvider.family<
        List<SavedPlace>,
        String>(
  (ref, category) {
    final authState =
        ref.watch(authStateProvider);

    final firestoreService =
        ref.watch(
      firestoreServiceProvider,
    );

    final user =
        authState.value;

    if (user == null) {
      return Stream.value([]);
    }

    return firestoreService
        .getSavedPlacesByCategory(
      userId: user.uid,
      category: category,
    );
  },
);

// ADVANCED QUERY
// same field with multiple criteria:
// category can be Study OR Food
final studyFoodSavedPlacesProvider =
    StreamProvider<List<SavedPlace>>(
  (ref) {
    final authState =
        ref.watch(authStateProvider);

    final firestoreService =
        ref.watch(
      firestoreServiceProvider,
    );

    final user =
        authState.value;

    if (user == null) {
      return Stream.value([]);
    }

    return firestoreService
        .getSavedPlacesByCategories(
      userId: user.uid,
      categories: const [
        'Study',
        'Food',
      ],
    );
  },
);

// ADVANCED QUERY
// firestore aggregation count
final savedPlacesCountProvider =
    FutureProvider<int>((ref) async {
  final authState =
      ref.watch(authStateProvider);

  final firestoreService =
      ref.watch(
    firestoreServiceProvider,
  );

  final user =
      authState.value;

  if (user == null) {
    return 0;
  }

  return firestoreService
      .countSavedPlaces(
    user.uid,
  );
});