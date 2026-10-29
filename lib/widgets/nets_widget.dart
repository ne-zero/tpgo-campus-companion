import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/nets_provider.dart';
import 'nets_fail_widget.dart';
import 'nets_success_widget.dart';

// main NETS QR payment widget
// matches Mini-Project 10's nets_widget.dart spec:
// - calls generateQR() on load via addPostFrameCallback
// - renders different UI based on state.status
class NetsWidget extends ConsumerStatefulWidget {
  const NetsWidget({super.key, required this.amount});

  final double amount;

  @override
  ConsumerState<NetsWidget> createState() => _NetsWidgetState();
}

class _NetsWidgetState extends ConsumerState<NetsWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(netsProvider.notifier).generateQR(widget.amount);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(netsProvider);

    if (state.status == 'loading') {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Requesting NETS QR code...'),
          ],
        ),
      );
    }

    if (state.status == 'success') {
      return const NetsSuccessWidget();
    }

    if (state.status == 'fail') {
      return const NetsFailWidget();
    }

    // "idle" - QR is ready, waiting for payment
    if (state.qrCode != null) {
      final minutes = (state.timeLeft ~/ 60).toString().padLeft(2, '0');
      final seconds = (state.timeLeft % 60).toString().padLeft(2, '0');

      return Column(
        children: [
          Text(
            'Registration Fee: \$${widget.amount.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          const Text(
            'Scan the QR code below with TWallet',
            style: TextStyle(color: Color(0xFF9CA3B8)),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 6)),
              ],
            ),
            child: Image.memory(state.qrCode!, height: 220, width: 220),
          ),
          if (state.message != null) ...[
            const SizedBox(height: 12),
            Text(
              state.message!,
              style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF2637FF)),
            ),
          ],
          const SizedBox(height: 20),
          // real instructions image from your lab materials
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Image.asset('images/nets_qr_info.png'),
          ),
          const SizedBox(height: 20),
          Text(
            'Time left: $minutes:$seconds',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {
              ref.read(netsProvider.notifier).cleanup();
              Navigator.of(context).pop();
            },
            child: const Text('Cancel Payment'),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}