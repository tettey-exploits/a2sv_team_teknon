import 'dart:developer';
import 'dart:typed_data';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmnets/chat_feature/models/message.dart';
import 'package:farmnets/services/ghana_nlp_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

/// A service class for interacting with the Gemini generative AI model
/// and handling messaging functionalities in Firestore.
class GeminiService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final GhanaNLPServices _nlpServices =
      GhanaNLPServices(apiKey: dotenv.env['GH_NLP_API']!);

  final String geminiAPIKey = dotenv.env['GEMINI_API']!;

  /// Calls the Gemini generative model with a text prompt and sends the
  /// generated response as a message.
  ///
  /// If [textPrompt] is not provided, a default prompt is used.
  Future<void> callGenerativeModel(
      {String? textPrompt, String? userLanguage}) async {
    // For text-only input, use the gemini-pro model
    final model = GenerativeModel(
        model: 'gemini-pro',
        apiKey: geminiAPIKey,
        generationConfig: GenerationConfig(maxOutputTokens: 300));
    final content = [
      Content.text(textPrompt ?? 'Respond with this string only: "Welcome"')
    ];

    try {
      final response = await model.generateContent(content);

      // Clean the response text
      String cleanedResponse = cleanText(response.text ?? "Kwame Gemini failed to respond");

      // Check user language
      if (userLanguage != null && userLanguage != "en") {
        // If user language is not English, translate Gemini's response to user language
        String? translatedText = await _nlpServices.translateText(
            cleanedResponse,
            localLanguage: userLanguage);
        log("Translated text: $translatedText\n");
        if (translatedText == "401") {
          log("Check API key");
          return;
        }

        // upload translated text
        await geminiMessageToFirestore(textMessage: translatedText);
      } else {
        // Upload Gemini's reply in English to Firestore
        await geminiMessageToFirestore(textMessage: cleanedResponse);
      }
    } catch (e) {
      if (e is GenerativeAIException && e.message.contains('Candidate was blocked due to safety')) {
        log("Safety block detected: ${e.message}");
        // Handle the safety block by sending a default message or taking other action
        await geminiMessageToFirestore(textMessage: "The response was blocked due to safety concerns.");
      } else {
        log("Unexpected error: ${e.toString()}");
        // Handle other exceptions as needed
        rethrow; // or handle it accordingly
      }
    }
  }

  /// Cleans the text by removing formatting and special characters.
  String cleanText(String text) {
    final cleanedText = text.replaceAll(RegExp(r'[\t\n\r*]'), ' ').replaceAll(RegExp(r' +'), ' ');
    return cleanedText.trim();
  }

  /// Sends a message text response from Gemini to Firestore
  ///
  /// The [textMessage] parameter is required. [imageFile] or [audioFile] are optional.
  Future<void> geminiMessageToFirestore({
    required String textMessage,
    File? imageFile,
    File? audioFile,
    bool? fromNLPService,
    List<int>? audioBytes,
  }) async {
    final String receiverID = _auth.currentUser!.uid;
    const String currentUserID = "gemini";
    final Timestamp timestamp = Timestamp.now();
    const String senderEmail = "gemini.google.com";
    String? imageUrl;
    String? audioUrl;

    if (imageFile != null) {
      imageUrl = await uploadMediaFile(imageFile, 'jpg');
    }
    if (audioFile != null) {
      if (fromNLPService == true) {
        audioUrl = await uploadMediaFile(audioFile, 'wav');
      }
      audioUrl = await uploadMediaFile(audioFile, 'mp3');
    } else if (audioBytes != null) {
      audioUrl = await uploadAudioBytes(audioBytes, 'wav');
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
      isGeminiReply: true,
    );

    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String chatRoomID = ids.join('_');
    await _firestore
        .collection("gemini_interactions")
        .doc(chatRoomID)
        .collection("messages")
        .add(newMessage.toMap());
  }

  /// Uploads a file to Firebase Storage and returns the download URL.
  ///
  /// The [file] parameter specifies the file to upload, and [fileType]
  /// specifies the file extension (e.g., 'jpg' for images).
  Future<String> uploadMediaFile(File file, String fileType) async {
    String fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileType';
    Reference reference = _storage.ref().child(fileName);
    UploadTask uploadTask = reference.putFile(file);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<String> uploadAudioBytes(List<int> audioBytes, String fileType) async {
    String fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileType';
    Reference reference = _storage.ref().child(fileName);
    UploadTask uploadTask = reference.putData(Uint8List.fromList(audioBytes));
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  /// Sends a user message to Firestore.
  ///
  /// The [textMessage] parameter is required. [imageFile] or [audioFile] are optional.
  Future<void> userSendMessage({
    String? textMessage,
    File? imageFile,
    File? audioFile,
  }) async {
    const String receiverID = "gemini";

    // get current user info
    final String currentUserID = _auth.currentUser!.uid;
    final String? currentUserEmail =
        _auth.currentUser!.email; // is ExtensionOfficer
    final String? currentUserPhoneNumber =
        _auth.currentUser!.phoneNumber; // is Farmer
    String? senderEmail;
    final Timestamp timestamp = Timestamp.now();

    String? imageUrl;
    String? audioUrl;

    // Determine sender email based on availability
    if (currentUserEmail != null) {
      senderEmail = currentUserEmail;
    } else if (currentUserPhoneNumber != null) {
      senderEmail = currentUserPhoneNumber;
    } else {
      // Handle the case where neither email nor phone number is available
      throw Exception("No sender email or phone number available.");
    }

    if (imageFile != null) {
      imageUrl = await uploadMediaFile(imageFile, 'jpg');
    }
    if (audioFile != null) {
      audioUrl = await uploadMediaFile(audioFile, 'mp3');
    }

    // create a new message
    Message newMessage = Message(
      senderID: currentUserID,
      /*senderEmail: senderEmail,*/
      receiverID: receiverID,
      message: textMessage ?? "",
      timestamp: timestamp,
      imageUrl: imageUrl,
      audioUrl: audioUrl,
      isGeminiReply: false,
    );

    // Construct chat room ID for the two users - sorted to ensure uniqueness
    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String chatRoomID = ids.join('_');
    await _firestore
        .collection("gemini_interactions")
        .doc(chatRoomID)
        .collection("messages")
        .add(newMessage.toMap());
  }

  /// Retrieves a stream of messages from Firestore for the specified user ID.
  ///
  /// The [userID] parameter specifies the user whose messages are to be retrieved.
  // get messsages
  Stream<QuerySnapshot> getMessages(String userID) {
    String geminiID = "gemini";
    // Construct a chatroom ID for the two users
    List<String> ids = [userID, geminiID];
    ids.sort();
    String chatRoomID = ids.join('_');

    return _firestore
        .collection("gemini_interactions")
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
        .collection("gemini_interactions")
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
          log("Empty text message, no media file");
          return "";
        }
      } else {
        log("Snapshot docs is empty");
        return "";
      }
    });
  }
}
