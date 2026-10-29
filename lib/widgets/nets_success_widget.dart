import 'dart:async';

import 'package:flutter/material.dart';

// shown when payment succeeds
// matches Mini-Project 10's nets_success_widget.dart spec
//
// NOTE: uses Icons.check_circle as a stand-in for green_tick.png -
// swap in the real image asset if you have it from your lab materials
class NetsSuccessWidget extends StatefulWidget {
  const NetsSuccessWidget({super.key, this.secondsUntilReturn = 10});

  final int secondsUntilReturn;

  @override
  State<NetsSuccessWidget> createState() => _NetsSuccessWidgetState();
}

class _NetsSuccessWidgetState extends State<NetsSuccessWidget> {
  late int _seconds = widget.secondsUntilReturn;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _seconds -= 1;
      });
      if (_seconds <= 0) {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('images/green_tick.png', height: 100, width: 100),
            const SizedBox(height: 20),
            const Text(
              'Payment Successful',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF18B337)),
            ),
            const SizedBox(height: 8),
            Text(
              'Returning in $_seconds seconds',
              style: const TextStyle(color: Color(0xFF9CA3B8)),
            ),
          ],
        ),
      ),
    );
  }
}