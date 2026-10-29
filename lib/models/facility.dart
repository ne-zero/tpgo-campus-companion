import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// a bookable campus facility
// now maps to a document in the "facilities" collection
class Facility {
  static const int defaultIconCodePoint = 0xe55f;

  const Facility({
    required this.id,
    required this.name,
    required this.location,
    required this.pricePerHour,
    required this.icon,
    required this.color,
  });

  final String id;
  final String name;
  final String location;
  final double pricePerHour;
  final IconData icon;
  final Color color;

  static Facility fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();

    return Facility(
      id: doc.id,
      name: data['name'] ?? '',
      location: data['location'] ?? '',
      pricePerHour: (data['pricePerHour'] as num?)?.toDouble() ?? 0.0,
      // icon code comes from firestore data, so it can't be a compile-time
      // constant - see note in campus_location.dart
      icon: IconData(
        // ignore: non_const_argument_for_const_parameter
        data['iconCode'] ?? defaultIconCodePoint,
        fontFamily: 'MaterialIcons',
      ),
      color: Color(data['colorValue'] ?? 0xFF2637FF),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'location': location,
      'pricePerHour': pricePerHour,
      'iconCode': icon.codePoint,
      'colorValue': color.toARGB32(),
    };
  }
}
