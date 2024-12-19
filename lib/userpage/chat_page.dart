import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore import
import 'package:swap_it/models/chat_model.dart';

class ChatPage extends StatefulWidget {
  final String userEmail; // The logged-in user's email
  final String postEmail; // The email of the user who posted the item

  const ChatPage({Key? key, required this.userEmail, required this.postEmail})
      : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Firestore collection for chat messages
  String get chatRoomId =>
      widget.userEmail.hashCode <= widget.postEmail.hashCode
          ? '${widget.userEmail}_${widget.postEmail}'
          : '${widget.postEmail}_${widget.userEmail}';

  // Method to send a message
  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      final newMessage = ChatMessage(
        sender: widget.userEmail,
        message: _messageController.text,
        timestamp: DateTime.now(),
      );

      _firestore.collection('chats/$chatRoomId/messages').add(newMessage.toJson());

      // Clear the message input field
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.postEmail}'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              Navigator.pop(context); // Close the chat page and return to the chat list
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats/$chatRoomId/messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No messages yet.'));
                }

                final messages = snapshot.data!.docs
                    .map((doc) => ChatMessage.fromJson(doc.data() as Map<String, dynamic>))
                    .toList();

                return ListView.builder(
                  reverse: true, // Messages will appear from the bottom
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final chatMessage = messages[index];
                    final isUserMessage = chatMessage.sender == widget.userEmail;

                    return ListTile(
                      title: Align(
                        alignment: isUserMessage
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                          decoration: BoxDecoration(
                            color: isUserMessage
                                ? Colors.blueAccent
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            crossAxisAlignment: isUserMessage
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Text(
                                chatMessage.message,
                                style: TextStyle(
                                  color: isUserMessage ? Colors.white : Colors.black,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                chatMessage.timestamp.toLocal().toString().substring(0, 16),
                                style: TextStyle(
                                  color: isUserMessage
                                      ? Colors.white70
                                      : Colors.black54,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
