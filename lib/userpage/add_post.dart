import 'package:cloudinary_flutter/image/cld_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../models/post.dart';
import '../providers/user_provider.dart';
import '../services/cloudinary_service.dart';


class AddPost extends StatefulWidget {
  final Function(PostModel) onPostAdded;
  final String? userEmail;

  const AddPost({super.key, required this.onPostAdded, required this.userEmail});

  @override
  State<AddPost> createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  dynamic productImage;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Open file picker and handle the selected file
  Future<void> _openFilePicker() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        allowedExtensions: ["jpg", "jpeg", "png", "mp4"],
        type: FileType.custom,
      );

      if (result != null && result.files.single.path != null) {
        String filePath = result.files.single.path!; // Get the file path

        // Upload to Cloudinary
        dynamic uploadResult = await uploadToCloudinary(result); // Pass result directly here
        if (uploadResult != null) {
          setState(() {
            productImage = uploadResult['url']; // Get the URL from the returned map
          });
          print("Uploaded to Cloudinary: ${uploadResult['url']}");
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to upload image to Cloudinary")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No file selected")),
        );
      }
    } catch (e) {
      print("Error picking file: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to pick file")),
      );
    }
  }

  Future<void> _fetchUserData() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userData = await userProvider.getUserByEmail(widget.userEmail!);

      if (userData != null) {
        setState(() {
          emailController.text = userData.email!;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not found")),
        );
      }
    } catch (e) {
      print("Error fetching user data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to fetch user data")),
      );
    }
  }

  // Submit the post
  void _submitPost() {
    if (nameController.text.isEmpty ||
        priceController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        productImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields and add an image!")),
      );
      return;
    }

    // Create a new PostModel with post data
    final newPost = PostModel(
      email: emailController.text,
      name: nameController.text,
      price: priceController.text,
      description: descriptionController.text,
      productImage: productImage, // Use productImage directly
    );

    // Call the onPostAdded callback to add the new post
    widget.onPostAdded(newPost);

    // Clear fields
    nameController.clear();
    priceController.clear();
    descriptionController.clear();
    setState(() {
      productImage = null;
    });

    Fluttertoast.showToast(msg: "Post Added");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Theme.of(context).colorScheme.primaryFixedDim,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView( // Make the entire content scrollable if it overflows
              child: Card(
                elevation: 8, // Adds shadow to the card
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          "Add a Post",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                      SizedBox(height: 15),
                      _buildTextField(nameController, "Product Name"),
                      SizedBox(height: 10),
                      _buildTextField(priceController, "Asking Price", inputType: TextInputType.number),
                      SizedBox(height: 10),
                      _buildTextField(descriptionController, "Description", maxLines: 3),
                      SizedBox(height: 10),
                      productImage != null
                          ? Container(
                        height: 200, // Set a fixed height for the image box
                        child: SingleChildScrollView(
                          child: Image.network(
                            productImage,
                            width: double.infinity,
                            fit: BoxFit.contain, // Ensures the image maintains its aspect ratio
                          ),
                        ),
                      )
                          : ElevatedButton.icon(
                        onPressed: _openFilePicker,
                        icon: Icon(Icons.photo),
                        label: Text("Add Image"),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _submitPost,
                        child: Text("Submit"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build text fields
  TextField _buildTextField(TextEditingController controller, String label,
      {int maxLines = 1, TextInputType inputType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
