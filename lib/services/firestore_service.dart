import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/saved_place.dart';

// handles all firestore database logic for saved places
// kept separate from firebase_service.dart because this is database logic
class FirestoreService {
  final CollectionReference<Map<String, dynamic>> _savedPlacesRef =
      FirebaseFirestore.instance.collection('savedPlaces');

  // CREATE
  Future<void> savePlace({
    required String userId,
    required String title,
    required String subtitle,
    required String category,
    required String note,
    required String imagePath,
    required int badgeIconCode,
    required int badgeColorValue,
    required String walkTime,
    required String crowdText,
    required List<String> tags,
  }) {
    return _savedPlacesRef.add({
      'userId': userId,
      'title': title,
      'subtitle': subtitle,
      'category': category,
      'note': note,
      'imagePath': imagePath,
      'badgeIconCode': badgeIconCode,
      'badgeColorValue': badgeColorValue,
      'walkTime': walkTime,
      'crowdText': crowdText,
      'tags': tags,
      'savedAt': Timestamp.now(),
    });
  }

  // READ - all saved places for the current user
  // also uses firestore sort order so newest saved places appear first
  Stream<List<SavedPlace>> getSavedPlaces(String userId) {
    return _savedPlacesRef
        .where('userId', isEqualTo: userId)
        .orderBy('savedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(SavedPlace.fromFirestore)
              .toList(),
        );
  }

  // READ - one saved place using its firestore document id
  Future<SavedPlace?> getSavedPlace(String id) async {
    final doc = await _savedPlacesRef.doc(id).get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return SavedPlace.fromFirestore(doc);
  }

  // advanced query - multiple criteria on different fields
  // userId AND category must both match
  Stream<List<SavedPlace>> getSavedPlacesByCategory({
    required String userId,
    required String category,
  }) {
    return _savedPlacesRef
        .where('userId', isEqualTo: userId)
        .where('category', isEqualTo: category)
        .orderBy('savedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(SavedPlace.fromFirestore)
              .toList(),
        );
  }

  // advanced query - multiple criteria on the same field
  // category can match any value in the whereIn list
  Stream<List<SavedPlace>> getSavedPlacesByCategories({
    required String userId,
    required List<String> categories,
  }) {
    return _savedPlacesRef
        .where('userId', isEqualTo: userId)
        .where('category', whereIn: categories)
        .orderBy('savedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(SavedPlace.fromFirestore)
              .toList(),
        );
  }

  // UPDATE
  Future<void> updateSavedPlace({
    required String id,
    required String category,
    required String note,
  }) {
    return _savedPlacesRef.doc(id).update({
      'category': category,
      'note': note,
    });
  }

  // DELETE
  Future<void> deleteSavedPlace(String id) {
    return _savedPlacesRef.doc(id).delete();
  }

  // advanced query - firestore aggregation count
  Future<int> countSavedPlaces(String userId) async {
    final snapshot = await _savedPlacesRef
        .where('userId', isEqualTo: userId)
        .count()
        .get();

    return snapshot.count ?? 0;
  }
}
