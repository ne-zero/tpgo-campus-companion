import 'package:flutter/material.dart';

import '../models/campus_location.dart';

// starter campus locations used to seed firestore
// fixed ids stop the app from creating duplicate starter locations
final Map<String, CampusLocation> seedCampusLocations = {
  'sprouts-food-court': const CampusLocation(
    id: 'sprouts-food-court',
    name: 'Sprouts Food Court',
    category: 'Food',
    crowdLevel: 'Low',
    distance: '4 min walk',
    status: 'Open',
    description:
        'A convenient campus food court with a variety of affordable meal '
        'options. It is useful for quick lunches between classes and has '
        'seating for both individuals and small groups.',
    imagePath: 'images/sprouts.png',
    tags: ['Food', 'Vegetarian', 'Quick Meal'],
    icon: Icons.restaurant,
    color: Colors.orange,
    latitude: 1.3459,
    longitude: 103.9305,
  ),
  'breadboard-cafe': const CampusLocation(
    id: 'breadboard-cafe',
    name: 'Breadboard',
    category: 'Food',
    crowdLevel: 'Low',
    distance: '2 min walk',
    status: 'Open',
    description:
        'A student-run café that is convenient for coffee, snacks and short '
        'breaks. The relaxed seating also makes it a comfortable place to '
        'wait for friends or do light work between lessons.',
    imagePath: 'images/breadboard.png',
    tags: ['Café', 'Vegetarian', 'Casual'],
    icon: Icons.local_cafe,
    color: Color(0xFFC56E60),
    latitude: 1.3448,
    longitude: 103.9318,
  ),
  'pixel-garden': const CampusLocation(
    id: 'pixel-garden',
    name: 'IIT Pixel Garden',
    category: 'Study',
    crowdLevel: 'Medium',
    distance: '2 min walk',
    status: 'Open',
    description:
        'A convenient study and discussion space near IIT classrooms. It is '
        'best for short study sessions, project discussions and waiting '
        'between classes without travelling far across campus.',
    imagePath: 'images/pixel_garden.png',
    tags: ['Study Spot', 'Group Work', 'Near Classrooms'],
    icon: Icons.menu_book,
    color: Colors.blue,
    latitude: 1.3451,
    longitude: 103.9325,
  ),
  'library-level-7': const CampusLocation(
    id: 'library-level-7',
    name: 'Library Level 7',
    category: 'Study',
    crowdLevel: 'Low',
    distance: '5 min walk',
    status: 'Open',
    description:
        'A quieter level of the TP Library suited for focused individual '
        'study. It offers an air-conditioned environment and is a good '
        'choice when you need fewer distractions for longer study sessions.',
    imagePath: 'images/library.png',
    tags: ['Study Spot', 'Quiet', 'Air-conditioned'],
    icon: Icons.local_library,
    color: Colors.purple,
    latitude: 1.3444,
    longitude: 103.9309,
  ),
  'surau-an-nur': const CampusLocation(
    id: 'surau-an-nur',
    name: 'Surau An-Nur',
    category: 'Prayer',
    crowdLevel: 'Low',
    distance: '4 min walk',
    status: 'Open',
    description:
        'A peaceful prayer space on campus for students who need a quiet '
        'place for prayers. Ablution facilities are available nearby, and '
        'the space is intended to be calm and respectful.',
    imagePath: 'images/surau.png',
    tags: ['Prayer Space', 'Peaceful', 'Ablution Nearby'],
    icon: Icons.mosque,
    color: Colors.green,
    latitude: 1.3462,
    longitude: 103.9321,
  ),
  'sports-complex': const CampusLocation(
    id: 'sports-complex',
    name: 'Sports Complex',
    category: 'Sports',
    crowdLevel: 'High',
    distance: '8 min walk',
    status: 'Busy',
    description:
        'The main area for sports and fitness activities on campus. Students '
        'can use the nearby sports facilities for exercise, training and '
        'recreational activities, although peak periods can be crowded.',
    imagePath: 'images/gym.png',
    tags: ['Sports', 'Fitness', 'Busy'],
    icon: Icons.sports_basketball,
    color: Colors.red,
    latitude: 1.3438,
    longitude: 103.9333,
  ),
  'swimming-pool': const CampusLocation(
    id: 'swimming-pool',
    name: 'TP Swimming Pool',
    category: 'Sports',
    crowdLevel: 'Low',
    distance: '8 min walk',
    status: 'Under Renovation',
    description:
        'The campus swimming pool is currently closed while renovation works '
        'are being carried out. Students should not plan swimming activities '
        'here until the facility reopens. Check TP Go! again for status '
        'updates before visiting.',
    // no pool photo is included yet, so AppImageBox will show the water icon
    // fallback instead of displaying an unrelated photo
    imagePath: 'images/pool.png',
    tags: ['Swimming', 'Sports', 'Under Renovation'],
    icon: Icons.pool,
    color: Color(0xFF1597E5),
    latitude: 1.3436,
    longitude: 103.9338,
  ),
  'student-services': const CampusLocation(
    id: 'student-services',
    name: 'Student Services',
    category: 'Facilities',
    crowdLevel: 'Medium',
    distance: '7 min walk',
    status: 'Open',
    description:
        'A support point for common student enquiries and administrative '
        'assistance. Visit when you need help with student services or are '
        'unsure where to go for a campus-related enquiry.',
    imagePath: 'images/nest.png',
    tags: ['Facilities', 'Student Support', 'Enquiries'],
    icon: Icons.info,
    color: Colors.teal,
    latitude: 1.3455,
    longitude: 103.9298,
  ),
};
