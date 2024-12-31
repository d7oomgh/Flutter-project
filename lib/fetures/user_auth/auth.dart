import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> signInWithPhoneNumber(String phoneNumber) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Handle verification completed
      },
      verificationFailed: (FirebaseAuthException exception) {
        // Handle verification failed
      },
      codeSent: (String verificationId, int? resendToken) async {
        // Handle code sent

        
        String smsCode = 'sms_code'; // Get the SMS code from the user
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: smsCode,
        );




        await _auth.signInWithCredential(credential);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // Handle code auto retrieval timeout
      },
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}