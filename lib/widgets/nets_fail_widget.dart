import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/nets_provider.dart';

// shown when nets payment or qr generation fails
class NetsFailWidget extends ConsumerStatefulWidget {
  const NetsFailWidget({
    super.key,
    this.secondsUntilReturn = 15,
  });

  final int secondsUntilReturn;

  @override
  ConsumerState<NetsFailWidget> createState() {
    return _NetsFailWidgetState();
  }
}

class _NetsFailWidgetState
    extends ConsumerState<NetsFailWidget> {
  late int _seconds =
      widget.secondsUntilReturn;

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted) {
          return;
        }

        if (_seconds <= 1) {
          timer.cancel();

          ref
              .read(netsProvider.notifier)
              .cleanup();

          Navigator.of(context).pop();

          return;
        }

        setState(() {
          _seconds -= 1;
        });
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state =
        ref.watch(netsProvider);

    final theme =
        Theme.of(context);

    final colors =
        theme.colorScheme;

    final String errorMessage =
        state.message?.trim().isNotEmpty == true
            ? state.message!.trim()
            : 'NETS could not complete the payment request.';

    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(24),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Image.asset(
              'images/red_cross.png',
              height: 100,
              width: 100,
              errorBuilder: (
                context,
                error,
                stackTrace,
              ) {
                return const Icon(
                  Icons.cancel,
                  size: 100,
                  color: Colors.red,
                );
              },
            ),

            const SizedBox(height: 20),

            const Text(
              'Payment Failed',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.w900,
                color: Colors.red,
              ),
            ),

            const SizedBox(height: 14),

            // shows the real error caught by netsProvider
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(
                14,
              ),
              decoration:
                  BoxDecoration(
                color: colors
                    .errorContainer
                    .withValues(
                  alpha: 0.55,
                ),
                borderRadius:
                    BorderRadius.circular(
                  14,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Reason',
                    style: TextStyle(
                      color: colors
                          .onErrorContainer,
                      fontWeight:
                          FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    errorMessage,
                    textAlign:
                        TextAlign.center,
                    style: TextStyle(
                      color: colors
                          .onErrorContainer,
                      fontSize: 12.5,
                      height: 1.35,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Text(
              'Returning in $_seconds seconds',
              style: TextStyle(
                color: colors
                    .onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 16),

            TextButton(
              onPressed: () {
                _timer?.cancel();

                ref
                    .read(
                      netsProvider
                          .notifier,
                    )
                    .cleanup();

                Navigator.of(context)
                    .pop();
              },
              child: const Text(
                'Return now',
              ),
            ),
          ],
        ),
      ),
    );
  }
}