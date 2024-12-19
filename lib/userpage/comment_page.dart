import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:swap_it/models/post.dart';

class CommentPage extends StatefulWidget {
  final PostModel post; // The post to which the comments belong

  const CommentPage({super.key, required this.post});

  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final TextEditingController _commentController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Replace with actual logic for logged-in user email
  final String loggedInUserEmail = 'user@example.com';

  // Function to add a comment
  void _addComment() async {
    final String comment = _commentController.text.trim();
    if (comment.isNotEmpty) {
      // Add the new comment to Firestore
      List<String> updatedComments = List.from(widget.post.comments ?? []);
      List<String> updatedCommentBy = List.from(widget.post.commentBy ?? []);

      updatedComments.add(comment);
      updatedCommentBy.add(loggedInUserEmail);

      try {
        // Check if the document exists
        final postDoc = await _firestore.collection('posts').doc(widget.post.email).get();
        if (postDoc.exists) {
          // Update the Firestore document
          await _firestore.collection('posts').doc(widget.post.email).update({
            'comments': updatedComments,
            'commentBy': updatedCommentBy,
          });
          print("Firestore updated successfully!");
        } else {
          // Handle the case where the document doesn't exist
          print("Document not found, creating new document...");
          await _firestore.collection('posts').doc(widget.post.email).set({
            'comments': updatedComments,
            'commentBy': updatedCommentBy,
          });
          print("New document created!");
        }

        // Clear the comment input field
        _commentController.clear();
        setState(() {});
      } catch (e) {
        // Handle any Firestore update errors
        print("Error updating Firestore: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Display post details
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Posted by: ${post.email ?? 'Unknown'}"),
                    const SizedBox(height: 8),
                    Text("Description: ${post.description ?? 'No Description'}"),
                    const SizedBox(height: 8),
                    Text("Price: ${post.price ?? 'N/A'}"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Display comments
            Expanded(
              child: ListView.builder(
                itemCount: post.comments?.length ?? 0,
                itemBuilder: (context, index) {
                  final comment = post.comments?[index];
                  final commentBy = (post.commentBy != null && post.commentBy!.length > index)
                      ? post.commentBy![index]
                      : 'Unknown'; // Default value if the index is out of range

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: ListTile(
                      title: Text(comment ?? 'No Comment'),
                      subtitle: Text('By: $commentBy'),
                    ),
                  );
                },
              ),
            ),

            // Input field for new comment with Send button
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        labelText: 'Add a comment...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () {
                      _addComment();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
