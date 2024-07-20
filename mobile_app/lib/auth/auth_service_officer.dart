import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmnets/widgets/toast_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

class AuthServiceOfficer {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<UserCredential?> signInWithEmailPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // TODO: comment out when done
      /*_fireStore.collection("Users").doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'role': "extensionOfficer"
      });*/
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        showToast(message: 'Invalid email or password');
      } else {
        showToast(message: 'An error occurred: ${e.code}');
      }
    }
    return null;
  }

  Future<String> _uploadImageToFirebase(String childName, Uint8List file) async {
    Reference ref = _firebaseStorage.ref().child(childName);
    UploadTask uploadTask = ref.putData(file);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<UserCredential> signUpWithEmailPassword({
    required String email,
    required String password,
    required String username,
    required String location,
    required int rating,
    required Uint8List imageFile,
  }) async {
    try {
      // Create account for user.
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String imageUrl =
      await _uploadImageToFirebase('profileImage_$email', imageFile);

      // Save extension officer profile to FireStore
      _fireStore.collection("Users").doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'username': username,
        'role': "extensionOfficer",
        'location': location,
        'rating': rating,
        'imageUrl': imageUrl,
      });
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        showToast(message: 'This email address is already in use.');
      } else {
        showToast(message: 'An error occurred ${e.code}');
      }
      // If sign-up fails, throw the exception
      throw Exception(e.code);
    }
  }

  Future<void> signOut() async {
    return await _auth.signOut();
  }
}
