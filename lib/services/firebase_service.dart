import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

// handles all firebase authentication logic
class FirebaseService {
  FirebaseService(this._auth);

  final FirebaseAuth _auth;

  // only watches actual login and logout changes
  // this is what AuthGate should use
  Stream<User?> get authStateChanges {
    return _auth.authStateChanges();
  }

  // watches changes to firebase user details such as display name
  // profile screens can use this without rebuilding the whole AuthGate
  Stream<User?> get userChanges {
    return _auth.userChanges();
  }

  User? get currentUser {
    return _auth.currentUser;
  }

  // register using email and password
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential =
        await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;

    if (user != null) {
      try {
        await user.updateDisplayName(
          name.trim(),
        );
      } catch (_) {}

      try {
        await user.sendEmailVerification();
      } catch (_) {}

      try {
        await user.reload();
      } catch (_) {}
    }
  }

  // normal email and password login
  Future<void> login({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // guest login
  Future<void> signInAsGuest() async {
    await _auth.signInAnonymously();
  }

  // google login
  Future<void> signInWithGoogle() async {
    if (kIsWeb) {
      final provider =
          GoogleAuthProvider();

      await _auth.signInWithPopup(
        provider,
      );

      return;
    }

    final googleUser =
        await GoogleSignIn.instance
            .authenticate();

    final googleAuth =
        googleUser.authentication;

    final credential =
        GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    await _auth.signInWithCredential(
      credential,
    );
  }

  // github login
  Future<void> signInWithGitHub() async {
    final provider =
        GithubAuthProvider();

    if (kIsWeb) {
      await _auth.signInWithPopup(
        provider,
      );
    } else {
      await _auth.signInWithProvider(
        provider,
      );
    }
  }

  // change firebase display name
  Future<void> updateDisplayName(
    String newName,
  ) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-user',
        message:
            'No user is currently logged in.',
      );
    }

    if (user.isAnonymous) {
      throw FirebaseAuthException(
        code: 'guest-account',
        message:
            'Guest accounts cannot edit profile details.',
      );
    }

    final trimmedName =
        newName.trim();

    if (trimmedName.isEmpty) {
      throw FirebaseAuthException(
        code: 'invalid-name',
        message:
            'Please enter a valid display name.',
      );
    }

    await user.updateDisplayName(
      trimmedName,
    );
  }

  // forgot password from login screen
  Future<void> sendPasswordResetEmail(
    String email,
  ) async {
    await _auth.sendPasswordResetEmail(
      email: email.trim(),
    );
  }

  // reset password for logged in user
  Future<void>
      sendResetEmailForCurrentUser() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-user',
        message:
            'No user is currently logged in.',
      );
    }

    if (user.isAnonymous) {
      throw FirebaseAuthException(
        code: 'guest-account',
        message:
            'Guest accounts do not have a password to reset.',
      );
    }

    final email = user.email;

    if (email == null ||
        email.isEmpty) {
      throw FirebaseAuthException(
        code: 'no-email',
        message:
            'This account does not have an email address.',
      );
    }

    await _auth.sendPasswordResetEmail(
      email: email,
    );
  }

  // sends another verification email
  Future<void>
      sendVerificationEmail() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-user',
        message:
            'No user is currently logged in.',
      );
    }

    if (user.isAnonymous) {
      throw FirebaseAuthException(
        code: 'guest-account',
        message:
            'Guest accounts cannot verify email.',
      );
    }

    await user.reload();

    final refreshedUser =
        _auth.currentUser;

    if (refreshedUser == null) {
      throw FirebaseAuthException(
        code: 'no-user',
        message:
            'No user is currently logged in.',
      );
    }

    if (refreshedUser.emailVerified) {
      throw FirebaseAuthException(
        code: 'already-verified',
        message:
            'This email is already verified.',
      );
    }

    await refreshedUser
        .sendEmailVerification();
  }

  Future<bool>
      reloadAndCheckEmailVerified() async {
    final user = _auth.currentUser;

    if (user == null) {
      return false;
    }

    await user.reload();

    return _auth
            .currentUser
            ?.emailVerified ??
        false;
  }

  // sends verification link to the new email
  Future<void> changeEmail(
    String newEmail,
  ) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-user',
        message:
            'No user is currently logged in.',
      );
    }

    if (user.isAnonymous) {
      throw FirebaseAuthException(
        code: 'guest-account',
        message:
            'Guest accounts cannot change email.',
      );
    }

    await user.verifyBeforeUpdateEmail(
      newEmail.trim(),
    );
  }

  // in-app password change
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-user',
        message:
            'No user is currently logged in.',
      );
    }

    if (user.isAnonymous) {
      throw FirebaseAuthException(
        code: 'guest-account',
        message:
            'Guest accounts do not have a password to change.',
      );
    }

    final hasPasswordProvider =
        user.providerData.any(
      (info) =>
          info.providerId ==
          'password',
    );

    if (!hasPasswordProvider) {
      throw FirebaseAuthException(
        code:
            'no-password-provider',
        message:
            'This account signed in with Google or GitHub and does not have a password to change.',
      );
    }

    final email = user.email;

    if (email == null ||
        email.isEmpty) {
      throw FirebaseAuthException(
        code: 'no-email',
        message:
            'This account does not have an email address.',
      );
    }

    final credential =
        EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );

    try {
      await user
          .reauthenticateWithCredential(
        credential,
      );
    } on FirebaseAuthException catch (
        error) {
      if (error.code ==
              'wrong-password' ||
          error.code ==
              'invalid-credential') {
        throw FirebaseAuthException(
          code: 'wrong-password',
          message:
              'The current password is incorrect.',
        );
      }

      rethrow;
    }

    await user.updatePassword(
      newPassword,
    );
  }

  // logout
  Future<void> logout() async {
    await _auth.signOut();

    if (!kIsWeb) {
      try {
        await GoogleSignIn.instance
            .signOut();
      } catch (_) {
        // firebase logout already succeeded
      }
    }
  }
}