import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// SEND OTP
  static Future<String> sendOtp(String phone) async {
    Completer<String> completer = Completer();

    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      timeout: const Duration(seconds: 60),

      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-verification (Android only)
        try {
          await _auth.signInWithCredential(credential);
        } catch (_) {}
      },

      verificationFailed: (FirebaseAuthException e) {
        completer.completeError(e.message ?? "Verification Failed");
      },

      codeSent: (String verificationId, int? resendToken) {
        completer.complete(verificationId);
      },

      codeAutoRetrievalTimeout: (String verificationId) {
        if (!completer.isCompleted) {
          completer.complete(verificationId);
        }
      },
    );

    return completer.future;
  }

  /// VERIFY OTP
  static Future<void> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    await _auth.signInWithCredential(credential);
  }

  /// LOGOUT
  static Future<void> logout() async {
    await _auth.signOut();
  }
}
