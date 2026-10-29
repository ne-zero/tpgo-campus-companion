import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/biometric_service.dart';

const String _biometricEnabledKey =
    'biometric_unlock_enabled';

// provides biometric service
final biometricServiceProvider =
    Provider<BiometricService>((ref) {
  return BiometricService();
});

// initial value loaded before runApp
final initialBiometricEnabledProvider =
    Provider<bool>((ref) {
  return false;
});

// remembers whether biometric app lock is enabled
class BiometricEnabledNotifier
    extends Notifier<bool> {
  @override
  bool build() {
    return ref.watch(
      initialBiometricEnabledProvider,
    );
  }

  Future<void> setEnabled(
    bool value,
  ) async {
    state = value;

    final preferences =
        await SharedPreferences
            .getInstance();

    await preferences.setBool(
      _biometricEnabledKey,
      value,
    );
  }
}

final biometricEnabledProvider =
    NotifierProvider<
        BiometricEnabledNotifier,
        bool>(
  BiometricEnabledNotifier.new,
);

// checks whether biometric hardware is available
final biometricAvailableProvider =
    FutureProvider<bool>((ref) async {
  final service =
      ref.watch(
    biometricServiceProvider,
  );

  return service.isAvailable();
});

// whether the current app session has passed the lock
final hasUnlockedProvider =
    StateProvider<bool>((ref) {
  return false;
});

// loads saved biometric preference before runApp
Future<bool>
    loadBiometricEnabledPreference() async {
  final preferences =
      await SharedPreferences
          .getInstance();

  return preferences.getBool(
        _biometricEnabledKey,
      ) ??
      false;
}