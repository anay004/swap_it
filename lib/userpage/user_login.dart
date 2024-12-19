import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swap_it/admin/admin_login.dart';
import 'package:swap_it/userpage/user_dashboard.dart';
import 'package:swap_it/userpage/user_register.dart';

import '../authentication/auth.dart';
import '../models/user.dart'; // Import your UserModel class
import '../providers/user_provider.dart'; // Import UserProvider

class UserLogin extends StatefulWidget {
  const UserLogin({super.key});

  @override
  State<UserLogin> createState() => _UserLoginState();
}

class _UserLoginState extends State<UserLogin> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final Auth _auth = Auth(); // Initialize Auth class

  Future<void> checkCredentials() async {
    String email = emailController.text;
    String password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in both fields")),
      );
      return;
    }

    try {
      UserCredential? userCredential = await _auth.loginUser(email: email, password: password);
      print("from login $userCredential");
      if (userCredential == null || userCredential.user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid email or password")),
        );
        return;
      }

      UserModel loggedInUser = UserModel(
        name: userCredential.user?.displayName ?? "No Name",
        email: userCredential.user?.email ?? email,
        password: password,
        phone: userCredential.user?.phoneNumber ?? "No Phone",
      );

      context.read<UserProvider>().updateUser(loggedInUser);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => UserDashboard(loggedInUser: loggedInUser),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login Successful!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // decoration: const BoxDecoration(
        //   // gradient: LinearGradient(
        //   //   colors: [Colors.black, Colors.blueGrey],
        //   //   begin: Alignment.topLeft,
        //   //   end: Alignment.bottomRight,
        //   // ),
        //   image: DecorationImage(
        //     image: AssetImage('moroccan-flower-dark.png'), // Path to your pattern
        //     repeat: ImageRepeat.repeat, // Repeats the pattern
        //   ),
        // ),
        color: Theme.of(context).colorScheme.primaryFixedDim,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0), // Padding around the card
            child: Card(
              color: Theme.of(context).colorScheme.surfaceContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 8, // Elevation for shadow effect
              child: Padding(
                padding: const EdgeInsets.all(20.0), // Padding inside the card
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        height: 60,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Login to continue",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, ),
                      ),
                      const SizedBox(height: 20),

                      // Email Field
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: "Enter Email",
                          prefixIcon: const Icon(Icons.email),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Password Field
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: "Enter Password",
                          prefixIcon: const Icon(Icons.lock),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Login Button
                      ElevatedButton(

                        onPressed: checkCredentials,
                        style: ElevatedButton.styleFrom(
                          padding:  EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),

                          ),
                        ),
                        child: const Text("Login"),
                      ),
                      const SizedBox(height: 20),

                      // Register Option
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "New User?",
                            style: TextStyle(fontSize: 14),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const UserRegister()),
                              );
                            },
                            child: const Text(
                              "Register here",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Admin Login Option
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Admin? ",
                            style: TextStyle(fontSize: 14),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const AdminLogin()),
                              );
                            },
                            child: const Text(
                              "Login here",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
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
}
