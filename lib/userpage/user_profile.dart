import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:swap_it/providers/user_provider.dart';
import '../authentication/auth.dart';
import '../services/cloudinary_service.dart';
import '../userpage/user_login.dart';

class UserProfile extends StatefulWidget {
  final String? userEmail;

  const UserProfile({super.key, required this.userEmail});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  File? profileImage;
  String? email, phone, name;
  dynamic userImage; // User image URL

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userData = await userProvider.getUserByEmail(widget.userEmail!);

      if (userData != null) {
        setState(() {
          name = userData.name;
          email = userData.email;
          phone = userData.phone;
          userImage = userData.userImage; // Fetching saved user image URL
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

  Future<void> _openFilePicker() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        allowedExtensions: ["jpg", "jpeg", "png", "mp4"],
        type: FileType.custom,
      );

      setState(() {
        profileImage = File(result!.files.single.path!);
      });

      dynamic results = await uploadToCloudinary(result);
      if (results != null) {
        setState(() {
          userImage = results['url']; // Update with the Cloudinary image URL
        });
      }

    } catch (e) {
      print("Error picking file: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to pick file")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text("User Profile", style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),),
      ),
      body: Container(
        color: Theme.of(context).colorScheme.primaryFixedDim,

        padding: const EdgeInsets.all(57.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _openFilePicker,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 80,
                    backgroundImage: userImage != null
                        ? NetworkImage(userImage) // Using NetworkImage here
                        : null,
                    child: userImage == null
                        ? const Icon(
                      Icons.camera_alt,
                      size: 50,
                      color: Colors.grey,
                    )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: primaryColor,
                      radius: 20,
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              name ?? 'User Name',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              email ?? 'Email not available',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              phone ?? 'Phone not available',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.logout),
              label: const Text(
                "Logout",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _logout() async {
    await Auth().signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const UserLogin()),
          (route) => false,
    );
  }
}



