import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderID;

  /*final String senderEmail;*/
  final String receiverID;
  final String message;
  final Timestamp timestamp;
  final String? imageUrl;
  final String? audioUrl;
  final bool? isGeminiReply;

  Message({
    required this.senderID,
    /*required this.senderEmail,*/
    required this.receiverID,
    required this.message,
    required this.timestamp,
    this.imageUrl,
    this.audioUrl,
    this.isGeminiReply,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderID': senderID,
      /*'senderEmail': receiverID,*/
      /*'senderEmail': senderEmail,*/
      'receiverID': receiverID,
      'message': message,
      'timestamp': timestamp,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'isGeminiReply': isGeminiReply,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
        senderID: map['senderID'],
        receiverID: map['receiverID'],
        message: map['message'],
        audioUrl: map['audioUrl'],
        imageUrl: map['imageUrl'],
        timestamp: map['timestamp']);
  }
}
