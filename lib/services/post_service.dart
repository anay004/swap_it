import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post.dart';


class PostService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Fetch all posts from Firestore
  Future<List<PostModel>> fetchPosts() async {
    try {
      QuerySnapshot snapshot = await _db.collection('posts').get();
      return snapshot.docs.map((doc) => PostModel.fromjson(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Error fetching posts: $e');
    }
  }

  // Add a new post to Firestore
  Future<void> addPost(PostModel post) async {
    try {
      await _db.collection('posts').add(post.tojson());
    } catch (e) {
      throw Exception('Error adding post: $e');
    }
  }
}
