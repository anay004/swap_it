import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swap_it/models/post.dart';

class UpdatePostPage extends StatefulWidget {
  final QueryDocumentSnapshot postDoc;

  const UpdatePostPage({Key? key, required this.postDoc}) : super(key: key);

  @override
  _UpdatePostPageState createState() => _UpdatePostPageState();
}

class _UpdatePostPageState extends State<UpdatePostPage> {
  late TextEditingController nameController;
  late TextEditingController priceController;
  late TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();
    final post = PostModel.fromjson(widget.postDoc.data() as Map<String, dynamic>);
    nameController = TextEditingController(text: post.name);
    priceController = TextEditingController(text: post.price);
    descriptionController = TextEditingController(text: post.description);
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _updatePost() async {
    await FirebaseFirestore.instance.collection('posts').doc(widget.postDoc.id).update({
      'name': nameController.text,
      'price': priceController.text,
      'description': descriptionController.text,
    });
    Navigator.pop(context); // Return to the previous screen after updating
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Post"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: "Price"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: "Description"),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updatePost,
              child: const Text("Update Post"),
            ),
          ],
        ),
      ),
    );
  }
}
