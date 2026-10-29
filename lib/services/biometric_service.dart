import 'package:local_auth/local_auth.dart';

// handles device fingerprint / face authentication
//
// this does NOT log a user into firebase.
// firebase keeps the existing signed-in session.
//
// this service only protects access to tp go when the
// user opens the app again.
class BiometricService {
  static final BiometricService _instance =
      BiometricService._internal();

  factory BiometricService() {
    return _instance;
  }

  BiometricService._internal();

  final LocalAuthentication _auth =
      LocalAuthentication();

  // checks whether the device supports biometric authentication
  Future<bool> isAvailable() async {
    try {
      final bool supported =
          await _auth.isDeviceSupported();

      final bool canCheck =
          await _auth.canCheckBiometrics;

      final biometrics =
          await _auth.getAvailableBiometrics();

      return supported &&
          canCheck &&
          biometrics.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // returns available biometric types such as fingerprint
  Future<List<BiometricType>>
      availableTypes() async {
    try {
      return await _auth
          .getAvailableBiometrics();
    } catch (_) {
      return [];
    }
  }

  // asks android for fingerprint / face authentication
  Future<bool> authenticate({
    String reason = 'Unlock TP Go!',
  }) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options:
            const AuthenticationOptions(
          stickyAuth: true,

          // actual biometric only
          // device pin does not count as fingerprint login
          biometricOnly: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }
}