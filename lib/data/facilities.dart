import 'package:flutter/material.dart';

import '../models/facility.dart';

// starter data used ONLY to seed firestore the first time the app runs
// BookFacilityScreen no longer reads this list directly - it reads from
// facilitiesProvider, which streams from firestore instead.
final Map<String, Facility> seedFacilities = {
  'sports-hall-court-1': const Facility(
    id: 'sports-hall-court-1',
    name: 'Sports Hall Court 1',
    location: 'Sports Complex, Level 1',
    pricePerHour: 8,
    icon: Icons.sports_basketball,
    color: Colors.red,
  ),
  'discussion-room-a': const Facility(
    id: 'discussion-room-a',
    name: 'Discussion Room A',
    location: 'Library Level 5',
    pricePerHour: 3,
    icon: Icons.groups,
    color: Colors.blue,
  ),
  'music-practice-room': const Facility(
    id: 'music-practice-room',
    name: 'Music Practice Room',
    location: 'Block 21, Level 2',
    pricePerHour: 5,
    icon: Icons.music_note,
    color: Colors.purple,
  ),
};

final List<Facility> bookableFacilities = seedFacilities.values.toList(
  growable: false,
);
