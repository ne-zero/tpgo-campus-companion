import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// saved place model
// this now maps to a document in the "savedPlaces" collection in firestore
class SavedPlace {
  static const int defaultBadgeIconCodePoint = 0xe55f;

  const SavedPlace({
    required this.id,
    required this.userId,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.note,
    required this.imagePath,
    required this.badgeIcon,
    required this.badgeColor,
    required this.walkTime,
    required this.crowdText,
    required this.tags,
    required this.savedAt,
  });

  final String id;
  final String userId;
  final String title;
  final String subtitle;
  final String category;
  final String note;
  final String imagePath;
  final IconData badgeIcon;
  final Color badgeColor;
  final String walkTime;
  final String crowdText;
  final List<String> tags;
  final DateTime savedAt;

  // turns a firestore document into a SavedPlace object
  // same pattern as Expense.fromFirestore in the lab
  static SavedPlace fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};

    return SavedPlace(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      category: data['category'] ?? '',
      note: data['note'] ?? '',
      imagePath: data['imagePath'] ?? 'images/tp_campus.jpg',
      // icon and color are stored as simple codes so they can be saved
      // as plain numbers/strings in firestore
      // icon code comes from firestore data, so it can't be a compile-time
      // constant - see note in campus_location.dart
      badgeIcon: IconData(
        // ignore: non_const_argument_for_const_parameter
        data['badgeIconCode'] ?? defaultBadgeIconCodePoint,
        fontFamily: 'MaterialIcons',
      ),
      badgeColor: Color(data['badgeColorValue'] ?? 0xFF2637FF),
      walkTime: data['walkTime'] ?? '',
      crowdText: data['crowdText'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      savedAt: (data['savedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
