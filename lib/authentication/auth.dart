import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Register user with email and password
  Future<String?> registerUser({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    try {
      // Register user in Firebase Auth
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Add additional user data to Firestore
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user?.uid).set({
        'name': name,
        'phone': phone ?? '',  // Ensure phone is not null in Firestore
        'email': email,  // Save email as well (optional, but useful for identification)
      });

      return null; // Registration successful
    } on FirebaseAuthException catch (e) {
      // Handle Firebase-specific errors
      if (e.code == 'weak-password') {
        return 'The password is too weak.';
      } else if (e.code == 'email-already-in-use') {
        return 'The account already exists for that email.';
      }
      return e.message ?? 'An error occurred during registration.';
    } catch (e) {
      return 'An error occurred during registration: ${e.toString()}';
    }
  }

  // Login user with email and password
  Future<UserCredential?> loginUser({required String email, required String password}) async {
    try {
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Handle Firebase-specific errors
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided.');
      }
      return null; // Return null if login fails
    } catch (e) {
      print('An error occurred during login: ${e.toString()}');
      return null;
    }
  }

  // To handle sign-out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
