import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/user.dart'; // Import the UserModel

class UserProvider with ChangeNotifier {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // The current user data
  UserModel? _user;

  // Constructor to initialize the user
  UserProvider(this._user);

  // Getter to access the current user data
  UserModel? get user => _user;

  // Method to update the user information
  void updateUser(UserModel updatedUser) {
    _user = updatedUser;
    notifyListeners(); // Notify listeners to update the UI
  }
  Future<UserModel?> getUserByEmail(String email) async {
    try {
      // Query Firestore for the user document with the given email
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Parse the document into a UserModel
        final userData = querySnapshot.docs.first.data();
        _user = UserModel.fromJson(userData);
        notifyListeners(); // Notify listeners about user change
        return _user;
      } else {
        // No user found
        return null;
      }
    } catch (e) {
      throw Exception('Failed to fetch user by email: $e');
    }
  }

  // Method to update user image
  void updateUserImage(String newImagePath) {
    if (_user != null) {
      _user!.userImage = newImagePath;
      notifyListeners(); // Notify listeners to update the UI
    }
  }

  // **Method to register a user**
  Future<void> registerUser({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      // Example of user registration logic
      _user = UserModel(
        name: name,
        email: email,
        password: password,
        phone: phone,
        userImage: "userImage", // Default image can be an empty string or a placeholder
      );
      notifyListeners(); // Notify listeners to update the UI
    } catch (e) {
      rethrow; // If registration fails, throw the error to handle it later
    }
  }

  // **New Method: Set User Data**
  void setUserData({
    required String name,
    required String email,
    required String phone,
    required String userImage,
  }) {
    _user = UserModel(
      name: name,
      email: email,
      phone: phone,
      password: "", // Password not included in setUserData
      userImage: userImage, // Provide a default value for image if null
    );
    notifyListeners(); // Notify listeners to update the UI
  }
}