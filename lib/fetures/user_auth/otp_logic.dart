import 'package:firebase_auth/firebase_auth.dart';

class PhoneAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> verifyPhoneNumber(String phoneNumber) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        // This callback is triggered on Android devices where the code is automatically verified.
        try {
          // Automatically sign in the user or link the credential to the current user.
          await _auth.signInWithCredential(credential);
          print('Phone number automatically verified and user signed in.');
        } catch (e) {
          print('Error signing in with credential: $e');
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        // Handle any error, such as invalid phone numbers or quota exceeding.
        if (e.code == 'invalid-phone-number') {
          print('The provided phone number is not valid.');
        } else {
          print('Verification failed: ${e.message}');
        }
      },
      codeSent: (String verificationId, int? resendToken) async {
        // Update UI to prompt the user to enter the SMS code.
        print('Verification code sent to $phoneNumber.');

        // Simulate getting the SMS code from the user input.
        String smsCode = '123456'; // Example SMS code.

        // Create a PhoneAuthCredential with the verificationId and smsCode.
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: smsCode,
        );

        // Sign in or link the user with the credential.
        try {
          await _auth.signInWithCredential(credential);
          print('User signed in with SMS code.');
        } catch (e) {
          print('Error signing in with SMS code: $e');
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // Called when automatic code retrieval times out.
        print('Code auto retrieval timeout.');
      },
    );
  }
}
