import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

import 'package:swap_it/userpage/user_login.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Animation controller setup
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _controller.forward();

    // Navigate to home screen after splash screen
    Timer(Duration(seconds: 4), () {
      Navigator.push(context, MaterialPageRoute(builder: (context) => UserLogin()));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg.jpg'), // Replace with your background image path
            fit: BoxFit.cover, // This will make the background image cover the screen
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Add an image with animation on top of the background
              ScaleTransition(
                scale: _animation,
                child: Image.asset(
                  'assets/images/logo.png', // Replace with your logo image path
                  width: 400, // Adjust as needed
                  height: 100, // Adjust as needed
                  //fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 40),
              CircularProgressIndicator(
                color: Colors.black, // Matches the theme
                strokeWidth: 3, // Adjust thickness
              ),
            ],
          ),
        ),
      ),
    );
  }
}
