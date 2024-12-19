import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String sender; // Email of the sender
  final String message; // Message content
  final DateTime timestamp; // Time when the message was sent

  ChatMessage({
    required this.sender,
    required this.message,
    required this.timestamp,
  });

  // Convert a ChatMessage to a Map for Firestore storage
  Map<String, dynamic> toJson() {
    return {
      'sender': sender,
      'message': message,
      'timestamp': timestamp, // Firestore uses Timestamp type, no conversion needed
    };
  }

  // Create a ChatMessage from Firestore Map
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      sender: json['sender'] ?? '', // Fallback to an empty string if null
      message: json['message'] ?? '', // Fallback to an empty string if null
      timestamp: (json['timestamp'] as Timestamp).toDate(), // Convert Firestore Timestamp to DateTime
    );
  }
}
