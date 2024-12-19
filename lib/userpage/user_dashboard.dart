import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:swap_it/chat/chat_list_page.dart';
import 'package:swap_it/userpage/chat_page.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../services/post_service.dart';
import 'comment_page.dart';
import 'user_history.dart';
import 'user_profile.dart';
import 'add_post.dart';
import 'package:intl/intl.dart';

class UserDashboard extends StatefulWidget {
  final UserModel loggedInUser; // Pass the logged-in user details

  UserDashboard({super.key, required this.loggedInUser});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  int _currentIndex = 0;

  final PostService _postService = PostService();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final backgroundColor = theme.colorScheme.background;

    print("Full user dd: ${widget.loggedInUser.email}");

    final pages = [
      _buildHomePage(),
      AddPost(
        onPostAdded: (newPost) async {
          await _postService.addPost(newPost as PostModel); // Add post to Firestore
          setState(() {});
        },
        userEmail: widget.loggedInUser.email!,
      ),
      ChatListPage(userEmail: widget.loggedInUser.email ?? ""),
      //UserProfile(userEmail: widget.loggedInUser.email),

      UserHistory(
        userEmail: widget.loggedInUser.email ?? "",
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Text(
              "Swap It",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: true,

      ),
      body: Stack(
        children: [
          pages[_currentIndex],
        ],
      ),
      drawer: Drawer(
        child: UserProfile(userEmail: widget.loggedInUser.email), // Drawer content with UserProfile
      ),
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.react,
        backgroundColor: primaryColor, // FlexColorScheme's primary color
        activeColor: Colors.white, // Highlight color for the selected tab
        color: backgroundColor,
        curveSize: 150,
        items: const [
          TabItem(icon: Icons.home, title: "Home"),
          TabItem(icon: Icons.add_circle_outline, title: "Add Post"),
          TabItem(icon: Icons.message_outlined, title: "Chats"),
          TabItem(icon: Icons.history, title: "History"),
        ],
        initialActiveIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildHomePage() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('posts').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              "No posts yet! Start adding some.",
              style: TextStyle(fontSize: 18),
            ),
          );
        }

        final posts = snapshot.data!.docs
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
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            final isLiked = post.likedBy!.contains(widget.loggedInUser.email);

            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: InkWell(
                onTap: () {
                  if (post.email != widget.loggedInUser.email) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(
                          userEmail: widget.loggedInUser.email!,
                          postEmail: post.email!,
                        ),
                      ),
                    );
                  }
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Posted by: ${post.email ?? "Unknown"}",
                            style: TextStyle(
                              decoration: TextDecoration.none,
                            ),
                          ),
                          Text(
                            "Date: ${post.dateCreated != null ? DateFormat('yyyy-MM-dd ,  hh:mm a').format(post.dateCreated!) : "N/A"}",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold, // Bold text
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
                                    icon: Icon(
                                      isLiked
                                          ? Icons.thumb_up
                                          : Icons.thumb_up_off_alt,
                                      color: isLiked ? Colors.blue : null,
                                    ),
                                    onPressed: () async {
                                      List<String> updatedLikedBy =
                                      List.from(post.likedBy);
                                      if (isLiked) {
                                        updatedLikedBy.remove(
                                            widget.loggedInUser.email);
                                      } else {
                                        updatedLikedBy
                                            .add(widget.loggedInUser.email!);
                                      }

                                      await FirebaseFirestore.instance
                                          .collection('posts')
                                          .doc(snapshot.data!.docs[index].id)
                                          .update({
                                        'likes': isLiked
                                            ? post.likes! - 1
                                            : post.likes! + 1,
                                        'likedBy': updatedLikedBy,
                                      });
                                    },
                                  ),
                                  Text(post.likes.toString()),
                                ],
                              ),
                              SizedBox(width: 10,),
                              Column(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.comment,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () {
                                      // Navigate to Comment Page
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => CommentPage(
                                            post: post,
                                            //loggedInUser: widget.loggedInUser,
                                          ),
                                        ),
                                      );
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
    );
  }

}
//dashboard with like and comment!