import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/biometric_provider.dart';

// app lock shown when:
// 1. firebase still has a logged-in user
// 2. biometric app lock was enabled
// 3. the app has just been opened again
//
// this is not a firebase login screen.
class BiometricLockScreen
    extends ConsumerStatefulWidget {
  const BiometricLockScreen({
    super.key,
  });

  @override
  ConsumerState<
      BiometricLockScreen>
      createState() {
    return _BiometricLockScreenState();
  }
}

class _BiometricLockScreenState
    extends ConsumerState<
        BiometricLockScreen> {
  bool _isChecking = false;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    // automatically open android's fingerprint prompt
    // as soon as tp go starts
    WidgetsBinding.instance
        .addPostFrameCallback(
      (_) {
        _attemptUnlock();
      },
    );
  }

  Future<void>
      _attemptUnlock() async {
    if (_isChecking) {
      return;
    }

    setState(() {
      _isChecking = true;
      _errorMessage = null;
    });

    final service =
        ref.read(
      biometricServiceProvider,
    );

    try {
      final bool success =
          await service.authenticate(
        reason:
            'Use your fingerprint to unlock TP Go!',
      );

      if (!mounted) {
        return;
      }

      if (success) {
        // changing this to true causes AuthGate
        // to rebuild and show MainScreen
        ref
            .read(
              hasUnlockedProvider
                  .notifier,
            )
            .state = true;
      } else {
        setState(() {
          _errorMessage =
              'Fingerprint was not recognised or authentication was cancelled.';
        });
      }
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage =
            'Biometric authentication is unavailable right now.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    final colors =
        theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.all(
            32,
          ),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Container(
                height: 116,
                width: 116,
                decoration:
                    BoxDecoration(
                  color: colors.primary
                      .withValues(
                    alpha: 0.12,
                  ),
                  shape:
                      BoxShape.circle,
                ),
                child: Icon(
                  Icons.fingerprint,
                  size: 62,
                  color:
                      colors.primary,
                ),
              ),

              const SizedBox(
                height: 28,
              ),

              Text(
                'TP Go! is locked',
                textAlign:
                    TextAlign.center,
                style: theme
                    .textTheme
                    .headlineSmall
                    ?.copyWith(
                  fontWeight:
                      FontWeight.w900,
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              Text(
                'Verify your fingerprint to continue.',
                textAlign:
                    TextAlign.center,
                style: theme
                    .textTheme
                    .bodyMedium,
              ),

              if (_errorMessage !=
                  null) ...[
                const SizedBox(
                  height: 18,
                ),

                Container(
                  width:
                      double.infinity,
                  padding:
                      const EdgeInsets
                          .all(
                    14,
                  ),
                  decoration:
                      BoxDecoration(
                    color: colors
                        .errorContainer,
                    borderRadius:
                        BorderRadius
                            .circular(
                      14,
                    ),
                  ),
                  child: Text(
                    _errorMessage!,
                    textAlign:
                        TextAlign.center,
                    style: TextStyle(
                      color: colors
                          .onErrorContainer,
                      fontWeight:
                          FontWeight
                              .w600,
                    ),
                  ),
                ),
              ],

              const SizedBox(
                height: 30,
              ),

              SizedBox(
                width:
                    double.infinity,
                height: 54,
                child:
                    ElevatedButton.icon(
                  onPressed:
                      _isChecking
                          ? null
                          : _attemptUnlock,
                  icon: _isChecking
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child:
                              CircularProgressIndicator(
                            strokeWidth:
                                2,
                            color:
                                Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons
                              .fingerprint,
                        ),
                  label: Text(
                    _isChecking
                        ? 'Checking...'
                        : 'Try again',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}