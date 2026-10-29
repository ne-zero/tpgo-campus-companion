import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/facility.dart';
import '../../providers/auth_provider.dart';
import '../../providers/nets_provider.dart';
import '../../widgets/nets_widget.dart';

// simple holder passed from BookFacilityScreen to this screen
// this is the "sender" side of the lab's Passing of Data pattern
class BookingDetails {
  const BookingDetails({
    required this.facility,
    required this.bookingDateTime,
  });

  final Facility facility;
  final DateTime bookingDateTime;
}

// nets qr payment screen for tp go
// follows Mini-Project 10's SignupScreen pattern: conditionally renders
// NetsWidget while payment is in progress, and the booking confirmation
// once state.status == "complete"
class NetsPaymentScreen extends ConsumerStatefulWidget {
  const NetsPaymentScreen({super.key});

  static const String routeName = '/nets-payment';

  @override
  ConsumerState<NetsPaymentScreen> createState() => _NetsPaymentScreenState();
}

class _NetsPaymentScreenState extends ConsumerState<NetsPaymentScreen> {
  bool _hasSavedBooking = false;

  BookingDetails get _bookingDetails {
    // receiver side of the lab's Passing of Data pattern
    return ModalRoute.of(context)!.settings.arguments as BookingDetails;
  }

  // writes the booking to Firestore - triggered automatically the
  // moment netsProvider reports status == "complete" (which only ever
  // happens after a genuine success), instead of a manual button
  Future<void> _saveBookingAndFinish() async {
    if (_hasSavedBooking) return;
    _hasSavedBooking = true;

    final user = ref.read(firebaseServiceProvider).currentUser;
    if (user == null) {
      if (mounted) Navigator.of(context).pop();
      return;
    }

    try {
      final txnRef = ref.read(netsProvider).txnRef;

      await FirebaseFirestore.instance.collection('bookings').add({
        'userId': user.uid,
        'facilityName': _bookingDetails.facility.name,
        'facilityLocation': _bookingDetails.facility.location,
        'amountInDollars': _bookingDetails.facility.pricePerHour,
        'bookingDateTime': Timestamp.fromDate(_bookingDetails.bookingDateTime),
        'txnRetrievalRef': txnRef ?? '',
        'createdAt': Timestamp.now(),
      });

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Booking confirmed!'),
            content: Text('${_bookingDetails.facility.name} has been booked successfully.'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('Done'),
              ),
            ],
          );
        },
      );
    } catch (error) {
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = _bookingDetails;
    final state = ref.watch(netsProvider);

    // the moment the provider marks payment as "complete" (success
    // only - fail never reaches this state), finish the booking
    if (state.status == 'complete' && !_hasSavedBooking) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _saveBookingAndFinish();
      });
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('NETS QR Payment', style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(22),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.facility.name,
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${booking.bookingDateTime.day}/${booking.bookingDateTime.month}/${booking.bookingDateTime.year} • '
                    '${TimeOfDay.fromDateTime(booking.bookingDateTime).format(context)}',
                    style: const TextStyle(color: Color(0xFF4F5774)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            NetsWidget(amount: booking.facility.pricePerHour),
          ],
        ),
      ),
    );
  }
}