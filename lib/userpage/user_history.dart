import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/post.dart';

class UserHistory extends StatelessWidget {
  final String userEmail;

  const UserHistory({
    super.key,
    required this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final backgroundColor = theme.colorScheme.background;

    return Scaffold(
      body: Container(
        color: Theme.of(context).colorScheme.primaryFixedDim,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('posts')
              .where('email', isEqualTo: userEmail)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  "You haven't created any posts yet!",
                  style: TextStyle(fontSize: 18),
                ),
              );
            }

            final userPosts = snapshot.data!.docs
                .map((doc) => PostModel.fromjson(doc.data() as Map<String, dynamic>))
                .toList();

            return GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 3 / 4,
              ),
              itemCount: userPosts.length,
              itemBuilder: (context, index) {
                final post = userPosts[index];
                final formattedDate = DateFormat('yyyy-MM-dd,  hh:mm a')
                    .format(post.dateCreated!);

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: InkWell(
                    onTap: () {
                      // Handle tap event if necessary
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Text(
                              //   "Posted by: ${post.email ?? "Unknown"}",
                              //   style: TextStyle(
                              //     decoration: TextDecoration.none,
                              //   ),
                              // ),
                              Text(
                                "Date: $formattedDate",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                            ),
                            child: post.productImage != null
                                ? Image.network(
                              post.productImage!,
                              fit: BoxFit.cover,
                            )
                                : const Icon(
                              Icons.image,
                              size: 50,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(post.name ?? "No Name"),
                              const SizedBox(height: 4),
                              Text(post.description ?? "No Description"),
                              const SizedBox(height: 4),
                              Text("Price: ${post.price ?? "N/A"}"),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Column(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.thumb_up,
                                          color: Colors.blue,
                                        ),
                                        onPressed: () {
                                          // Handle like action
                                        },
                                      ),
                                      Text(post.likes.toString()),
                                    ],
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.comment,
                                          color: Colors.blue,
                                        ),
                                        onPressed: () {
                                          // Handle comment action
                                        },
                                      ),
                                      Text(post.comments?.length.toString() ?? '0'),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
