import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/facilities.dart';
import '../data/sample_locations.dart';
import '../models/campus_location.dart';
import '../models/facility.dart';

// handles reading campus locations and facilities from firestore
class CatalogService {
  final CollectionReference<Map<String, dynamic>> _locationsRef =
      FirebaseFirestore.instance.collection('campusLocations');

  final CollectionReference<Map<String, dynamic>> _facilitiesRef =
      FirebaseFirestore.instance.collection('facilities');

  // RETRIEVE - all campus locations
  Stream<List<CampusLocation>> getCampusLocations() {
    return _locationsRef.snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => CampusLocation.fromFirestore(doc))
              .toList(),
        );
  }

  // advanced query - filter locations by category
  Stream<List<CampusLocation>> getCampusLocationsByCategory(String category) {
    return _locationsRef
        .where('category', isEqualTo: category)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CampusLocation.fromFirestore(doc))
              .toList(),
        );
  }

  // RETRIEVE - all bookable facilities
  Stream<List<Facility>> getFacilities() {
    return _facilitiesRef.snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => Facility.fromFirestore(doc))
              .toList(),
        );
  }

  // makes sure every starter record exists without deleting or duplicating
  // data already in firestore. this fixes the old behaviour where having
  // even one location stopped the rest of the starter pins from being added.
  Future<void> seedIfEmpty() async {
    try {
      final locationSnapshot = await _locationsRef.get();
      final existingLocationIds = locationSnapshot.docs
          .map((doc) => doc.id)
          .toSet();

      final locationBatch = FirebaseFirestore.instance.batch();
      bool hasLocationWrites = false;

      for (final entry in seedCampusLocations.entries) {
        final ref = _locationsRef.doc(entry.key);
        final location = entry.value;

        if (!existingLocationIds.contains(entry.key)) {
          // missing starter location: write the full document
          locationBatch.set(ref, location.toMap());
          hasLocationWrites = true;
        } else {
          // existing starter location: refresh display-only data so improved
          // descriptions, images and map coordinates appear, but preserve
          // live admin-controlled status and crowd values
          locationBatch.set(
            ref,
            {
              'name': location.name,
              'category': location.category,
              'description': location.description,
              'imagePath': location.imagePath,
              'tags': location.tags,
              'iconCode': location.icon.codePoint,
              'colorValue': location.color.toARGB32(),
              'latitude': location.latitude,
              'longitude': location.longitude,
            },
            SetOptions(merge: true),
          );
          hasLocationWrites = true;
        }
      }

      if (hasLocationWrites) {
        await locationBatch.commit();
      }

      final facilitySnapshot = await _facilitiesRef.get();
      final existingFacilityIds = facilitySnapshot.docs
          .map((doc) => doc.id)
          .toSet();

      final facilityBatch = FirebaseFirestore.instance.batch();
      bool hasFacilityWrites = false;

      for (final entry in seedFacilities.entries) {
        if (!existingFacilityIds.contains(entry.key)) {
          facilityBatch.set(_facilitiesRef.doc(entry.key), entry.value.toMap());
          hasFacilityWrites = true;
        }
      }

      if (hasFacilityWrites) {
        await facilityBatch.commit();
      }
    } catch (error) {
      // a seeding problem should not stop the whole app from opening
      // ignore: avoid_print
      print('Catalog seeding failed: $error');
    }
  }
}
