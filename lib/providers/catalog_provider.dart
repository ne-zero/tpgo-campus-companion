import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/campus_location.dart';
import '../models/facility.dart';
import '../services/catalog_service.dart';

final catalogServiceProvider = Provider<CatalogService>((ref) {
  return CatalogService();
});

// streams all campus locations from firestore
// Explore, Home, and the AI chat context all read from this one provider
final campusLocationsProvider = StreamProvider<List<CampusLocation>>((ref) {
  final catalogService = ref.watch(catalogServiceProvider);
  return catalogService.getCampusLocations();
});

// streams all bookable facilities from firestore
final facilitiesProvider = StreamProvider<List<Facility>>((ref) {
  final catalogService = ref.watch(catalogServiceProvider);
  return catalogService.getFacilities();
});

// streams locations filtered to one category (the advanced query)
// used by Explore's category chips - each category gets its own cached
// stream since this is a StreamProvider.family
final categoryFilteredLocationsProvider =
    StreamProvider.family<List<CampusLocation>, String>((ref, category) {
  final catalogService = ref.watch(catalogServiceProvider);
  return catalogService.getCampusLocationsByCategory(category);
});
