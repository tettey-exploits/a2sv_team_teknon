import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthServiceFarmer {
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  static String verifyId = "";

  // to sent and otp to user
  static Future sentOtp({
    required String phone,
    required Function errorStep,
    required Function nextStep,
  }) async {
    await _firebaseAuth
        .verifyPhoneNumber(
      timeout: const Duration(seconds: 30),
      phoneNumber: phone,
      verificationCompleted: (phoneAuthCredential) async {
        if (kDebugMode) {
          print("VERIFICATION COMPLETED");
        }
      },
      verificationFailed: (error) async {
        return;
      },
      codeSent: (verificationId, forceResendingToken) async {
        verifyId = verificationId;
        nextStep();
      },
      codeAutoRetrievalTimeout: (verificationId) async {
        return;
      },
    )
        .onError((error, stackTrace) {
      errorStep();
    });
  }

  // verify the OTP and login
  /*static Future loginWithOtp({
    required String otp,
    required String username,
  }) async {
    final FirebaseFirestore fireStore = FirebaseFirestore.instance;

    final cred =
        PhoneAuthProvider.credential(verificationId: verifyId, smsCode: otp);

    try {
      final userCredential = await _firebaseAuth.signInWithCredential(cred);
      if (userCredential.user != null) {

        // Save user info in a separate doc
        fireStore.collection("Users").doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'email': userCredential.user!.phoneNumber,
          'username': username,
          'role': "farmer",
        });
        return "Success";
      } else {
        return "Error in Otp login";
      }
    } on FirebaseAuthException catch (e) {
      return e.message.toString();
    } catch (e) {
      return e.toString();
    }
  }*/

  // verify the OTP and login
  static Future loginWithOtp({
    required String otp,
    required String username,
    required String location,
    required int rating,
  }) async {
    final FirebaseFirestore fireStore = FirebaseFirestore.instance;

    final cred =
        PhoneAuthProvider.credential(verificationId: verifyId, smsCode: otp);

    try {
      final userCredential = await _firebaseAuth.signInWithCredential(cred);
      if (userCredential.user != null) {

        // Save farmer profile onto FireStore
        fireStore.collection("Users").doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'email': userCredential.user!.phoneNumber,
          'username': username,
          'role': "farmer",
          'location': location,
          'rating': rating,
        });
        return "Success";
      } else {
        return "Error in Otp login";
      }
    } on FirebaseAuthException catch (e) {
      return e.message.toString();
    } catch (e) {
      return e.toString();
    }
  }


  // to logout the user
  static Future logout() async {
    await _firebaseAuth.signOut();
  }

  // check whether the user is logged in or not
  static Future<bool> isLoggedIn() async {
    var user = _firebaseAuth.currentUser;
    return user != null;
  }
}
