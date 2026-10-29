import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// one campus location shown across Home, Explore, and the AI chat context
// this now maps to a document in the "campusLocations" collection
class CampusLocation {
  static const int defaultIconCodePoint = 0xe55f;

  const CampusLocation({
    required this.id,
    required this.name,
    required this.category,
    required this.crowdLevel,
    required this.distance,
    required this.status,
    required this.description,
    required this.imagePath,
    required this.tags,
    required this.icon,
    required this.color,
    required this.latitude,
    required this.longitude,
  });

  final String id;
  final String name;
  final String category;
  final String crowdLevel;
  final String distance;
  final String status;
  final String description;
  final String imagePath;
  final List<String> tags;
  final IconData icon;
  final Color color;

  // map coordinates, used by the campus map on the Explore screen
  final double latitude;
  final double longitude;

  // turns a firestore document into a CampusLocation object
  // same pattern as SavedPlace.fromFirestore
  static CampusLocation fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();

    return CampusLocation(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      crowdLevel: data['crowdLevel'] ?? '',
      distance: data['distance'] ?? '',
      status: data['status'] ?? '',
      description: data['description'] ?? '',
      imagePath: data['imagePath'] ?? 'images/tp_campus.jpg',
      tags: List<String>.from(data['tags'] ?? []),
      // icon code comes from firestore data, so it can't be a compile-time
      // constant - disables icon tree-shaking for this one, which is fine
      // since MaterialIcons ships uncompressed anyway
      icon: IconData(
        // ignore: non_const_argument_for_const_parameter
        data['iconCode'] ?? defaultIconCodePoint,
        fontFamily: 'MaterialIcons',
      ),
      color: Color(data['colorValue'] ?? 0xFF2637FF),
      // falls back to the middle of TP campus if a document has no
      // coordinates yet (e.g. older seeded data)
      latitude: (data['latitude'] as num?)?.toDouble() ?? 1.3453,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 103.9312,
    );
  }

  // turns this object back into a map for seeding firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'crowdLevel': crowdLevel,
      'distance': distance,
      'status': status,
      'description': description,
      'imagePath': imagePath,
      'tags': tags,
      'iconCode': icon.codePoint,
      'colorValue': color.toARGB32(),
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

const List<String> locationCategories = [
  'All',
  'Food',
  'Study',
  'Prayer',
  'Sports',
  'Facilities',
];
