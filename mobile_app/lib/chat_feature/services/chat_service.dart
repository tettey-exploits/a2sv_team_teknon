import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmnets/chat_feature/models/message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// A service for managing chat-related operations.
class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Retrieves a stream of users from Firestore.
  ///
  /// Returns a [Stream] of user data as a list of maps.
  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection("Users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        // go through each individual user
        final user = doc.data();

        return user;
      }).toList();
    });
  }

  /// Retrieves a stream of farmers from Firestore.
  ///
  /// Filters users by role to return only farmers.
  /// Returns a [Stream] of farmer data as a list of maps
  Stream<List<Map<String, dynamic>>> getFarmersStream() {
    return _firestore.collection("Users").snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) {
            final user = doc.data();
            // Filter users by role
            if (user["role"] == "farmer") {
              return user;
            } else {
              return null;
            }
          })
          .whereType<Map<String, dynamic>>()
          .toList(); // Filter out null entries
    });
  }

  /// Retrieves a stream of extension officers from Firestore.
  ///
  /// Filters users by role to return only extension officers.
  /// Returns a [Stream] of extension officer data as a list of maps.
  Stream<List<Map<String, dynamic>>> getExtensionOfficersStream() {
    return _firestore.collection("Users").snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) {
            final user = doc.data();
            // Filter users by role
            if (user["role"] == "extensionOfficer") {
              return user;
            } else {
              return null;
            }
          })
          .whereType<Map<String, dynamic>>()
          .toList(); // Filter out null entries
    });
  }

  /// Uploads a file to Firebase Storage.
  ///
  /// The [file] parameter specifies the file to be uploaded.
  /// The [fileType] parameter specifies the type of the file ("jpg", "mp3").
  /// Returns a [Future] with the download URL of the uploaded file.
  Future<String> uploadFile(File file, String fileType) async {
    String fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileType';
    Reference reference = _storage.ref().child(fileName);
    UploadTask uploadTask = reference.putFile(file);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  /// Sends a message to a specified receiver.
  ///
  /// The [receiverID] parameter specifies the ID of the message receiver.
  /// The [textMessage] parameter specifies the text of the message.
  /// The [imageFile] and [audioFile] parameters specify optional image and audio files to be included in the message.
  Future<void> sendMessage({
    required String receiverID,
    required String textMessage,
    File? imageFile,
    File? audioFile,
  }) async {
    // get current user info
    final String currentUserID = _auth.currentUser!.uid;
    final String? currentUserEmail =
        _auth.currentUser!.email; // is ExtensionOfficer
    final String? currentUserPhoneNumber =
        _auth.currentUser!.phoneNumber; // is Farmer
    final Timestamp timestamp = Timestamp.now();

    // Determine sender email based on availability
    String? senderEmail;
    if (currentUserEmail != null) {
      senderEmail = currentUserEmail;
    } else if (currentUserPhoneNumber != null) {
      senderEmail = currentUserPhoneNumber;
    } else {
      // Handle the case where neither email nor phone number is available
      throw Exception("No sender email or phone number available.");
    }

    String? imageUrl;
    String? audioUrl;

    if (imageFile != null) {
      imageUrl = await uploadFile(imageFile, 'jpg');
    }

    if (audioFile != null) {
      audioUrl = await uploadFile(audioFile, 'mp3');
    }

    // create a new message
    Message newMessage = Message(
      senderID: currentUserID,
      /*senderEmail: senderEmail,*/
      receiverID: receiverID,
      message: textMessage,
      timestamp: timestamp,
      imageUrl: imageUrl,
      audioUrl: audioUrl,
    );

    // Construct chat room ID for the two users - sorted to ensure uniqueness
    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String chatRoomID = ids.join('_');
    await _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .add(newMessage.toMap());
  }

  /// Retrieves a stream of messages between two users.
  ///
  /// The [userID] and [otherUserID] parameters specify the IDs of the users.
  /// Returns a [Stream] of [QuerySnapshot] containing the messages.
  Stream<QuerySnapshot> getMessages(String userID, otherUserID) {
    // Construct a chatroom ID for the two users
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join('_');

    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  /// Retrieves a stream of the last message between two users.
  ///
  /// The [userID] and [otherUserID] parameters specify the IDs of the users.
  /// Returns a [Stream] of the last message as a string.
  Stream<String> getLastMessage({
    required String userID,
    required String otherUserID,
  }) {
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join('_');

    // Query for the last message in the specified chat room

    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy("timestamp", descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        final message = Message.fromMap(data);
        if (message.message.isNotEmpty) {
          return message.message;
        } else if (message.audioUrl != null) {
          return "Audio File";
        } else if (message.imageUrl != null) {
          return "Image File";
        } else {
          return "";
        }
      } else {
        return "";
      }
    });
  }
}
