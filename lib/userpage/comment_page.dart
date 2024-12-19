import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final String loggedInUserEmail = FirebaseAuth.instance.currentUser?.email ?? 'Unkown';

  // Function to add a comment
  void _addComment() async {
    final String comment = _commentController.text.trim();
    if (comment.isNotEmpty) {
      // Add the new comment to local lists
      List<String> updatedComments = List.from(widget.post.comments ?? []);
      List<String> updatedCommentBy = List.from(widget.post.commentBy ?? []);

      updatedComments.add(comment);
      updatedCommentBy.add(loggedInUserEmail);

      try {
        // Check if the post exists in Firestore
        final querySnapshot = await _firestore
            .collection('posts')
            .where('email', isEqualTo: widget.post.email)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          final docId = querySnapshot.docs.first.id; // Get the document ID

          // Update the Firestore document
          await _firestore.collection('posts').doc(docId).update({
            'comments': updatedComments,
            'commentBy': updatedCommentBy,
          });

          // Update the local post object
          setState(() {
            widget.post.comments = updatedComments;
            widget.post.commentBy = updatedCommentBy;
          });

          // Clear the comment input field
          _commentController.clear();
          print("Comment added successfully!");
        } else {
          print("Post not found!");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Post not found! Unable to add comment.")),
          );
        }
      } catch (e) {
        // Handle errors
        print("Error updating comments: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to add comment")),
        );
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final post = widget.post;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Comments', style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),),
      ),
      body: Container(
        color: Theme.of(context).colorScheme.primaryFixedDim,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Display post details
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                // child: Padding(
                //   padding: const EdgeInsets.all(8.0),
                //   //child:
                //
                //   // Column(
                //   //   crossAxisAlignment: CrossAxisAlignment.start,
                //   //   children: [
                //   //     Text("Posted by: ${post.email ?? 'Unknown'}"),
                //   //     const SizedBox(height: 8),
                //   //     Text("Description: ${post.description ?? 'No Description'}"),
                //   //     const SizedBox(height: 8),
                //   //     Text("Price: ${post.price ?? 'N/A'}"),
                //   //   ],
                //   // ),
                // ),
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
                      padding: const EdgeInsets.only(bottom: 8.0), // Add some space between cards
                      child: Card(
                        elevation: 5, // Set elevation for the shadow effect
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10), // Optional: rounded corners
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                comment ?? 'No Comment',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text('By: $commentBy'),
                            ],
                          ),
                        ),
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
                          filled: true,  // Enable background color
                          fillColor: Colors.white,
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
      ),
    );
  }
}
