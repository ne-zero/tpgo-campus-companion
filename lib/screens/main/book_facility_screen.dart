import 'package:flutter/material.dart';

import '../../data/facilities.dart';
import '../../models/facility.dart';
import 'nets_payment_screen.dart';

// lets the user pick a facility, date and time to book
// on submit, passes the booking details to the payment screen
// using Navigator arguments (same pattern as "Passing of Data" in the lab)
class BookFacilityScreen extends StatefulWidget {
  const BookFacilityScreen({super.key});

  static const String routeName = '/book-facility';

  @override
  State<BookFacilityScreen> createState() {
    return _BookFacilityScreenState();
  }
}

class _BookFacilityScreenState extends State<BookFacilityScreen> {
  Facility? _selectedFacility;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  // lab-taught date picker (Mini-Project 5)
  Future<void> _presentDatePicker() async {
    final DateTime? value = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (value != null) {
      setState(() {
        _selectedDate = value;
      });
    }
  }

  Future<void> _presentTimePicker() async {
    final TimeOfDay? value = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (value != null) {
      setState(() {
        _selectedTime = value;
      });
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _goToPayment() {
    if (_selectedFacility == null) {
      _showMessage('Please select a facility.');
      return;
    }
    if (_selectedDate == null) {
      _showMessage('Please select a date.');
      return;
    }
    if (_selectedTime == null) {
      _showMessage('Please select a time.');
      return;
    }

    // combines DateTime (date) and TimeOfDay (time) into one DateTime,
    // the same trick mentioned in the common questions for storing both
    // in a single firestore Timestamp
    final bookingDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    Navigator.of(context).pushNamed(
      NetsPaymentScreen.routeName,
      arguments: BookingDetails(
        facility: _selectedFacility!,
        bookingDateTime: bookingDateTime,
      ),
    );
  }

  Widget _buildFacilityOption(Facility facility) {
    final isSelected = _selectedFacility == facility;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          setState(() {
            _selectedFacility = facility;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.12)
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF6B3DFF)
                  : Theme.of(context).colorScheme.outlineVariant,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  color: facility.color,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  facility.icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      facility.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      facility.location,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '\$${facility.pricePerHour.toStringAsFixed(2)}/hr',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF2637FF),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Book a Facility',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(22),
          children: [
            Text(
              'Select a facility',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            for (final facility in bookableFacilities)
              _buildFacilityOption(facility),
            const SizedBox(height: 10),
            Text(
              'Date and time',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _presentDatePicker,
                    icon: const Icon(Icons.calendar_month),
                    label: Text(
                      _selectedDate == null
                          ? 'Choose date'
                          : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _presentTimePicker,
                    icon: const Icon(Icons.access_time),
                    label: Text(
                      _selectedTime == null
                          ? 'Choose time'
                          : _selectedTime!.format(context),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _goToPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2637FF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Continue to payment',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
