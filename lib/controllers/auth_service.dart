import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class AuthService {
  static FirebaseAuth _auth = FirebaseAuth.instance;

  // Send OTP
  static Future<String> sendOtp(String phone) async {
    Completer<String> completer = Completer();

    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto sign-in if possible
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        if (!completer.isCompleted) completer.completeError(e.message!);
      },
      codeSent: (String verId, int? resendToken) {
        if (!completer.isCompleted) completer.complete(verId);
      },
      codeAutoRetrievalTimeout: (String verId) {
        if (!completer.isCompleted) completer.complete(verId);
      },
    );

    return completer.future;
  }

  // Verify OTP
  static Future<UserCredential> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: smsCode);
    return await _auth.signInWithCredential(credential);
  }

  static Future<void> logout() async {
    await _auth.signOut();
  }
}
