import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';

// read-only list of the current user's facility bookings
// gives the NETS QR payment feature somewhere to "land" after payment
class MyBookingsScreen extends ConsumerWidget {
  const MyBookingsScreen({super.key});

  static const String routeName = '/my-bookings';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(firebaseServiceProvider).currentUser;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'My Bookings',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: user == null
            ? const Center(child: Text('Please log in to view bookings.'))
            : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('bookings')
                    .where('userId', isEqualTo: user.uid)
                    .orderBy('bookingDateTime', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Could not load bookings.'),
                    );
                  }

                  final docs = snapshot.data?.docs ?? [];

                  if (docs.isEmpty) {
                    return const Center(
                      child: Text('No bookings yet.'),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(22),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data();
                      final dateTime =
                          (data['bookingDateTime'] as Timestamp?)?.toDate();

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['facilityName'] ?? '',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              data['facilityLocation'] ?? '',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                fontSize: 12.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (dateTime != null)
                              Text(
                                '${dateTime.day}/${dateTime.month}/${dateTime.year} • '
                                '${TimeOfDay.fromDateTime(dateTime).format(context)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12.5,
                                  color: Color(0xFF2637FF),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}
