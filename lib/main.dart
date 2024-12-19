import 'package:firebase_core/firebase_core.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:swap_it/services/firebase_service.dart';
import 'package:swap_it/userpage/user_login.dart';
import 'models/user.dart'; // Import UserModel
import 'providers/user_provider.dart'; // Import UserProvider
import 'package:cloudinary_url_gen/cloudinary.dart';
import 'package:cloudinary_flutter/cloudinary_context.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print("here 1");


  try {
    if (Firebase.apps.isEmpty) {
      // Initialize Firebase with default options for the current platform
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print("Firebase initialized");
    } else {
      print("Firebase already initialized");
    }
  } catch (e) {
    print("Error during Firebase initialization: $e");
  }

  CloudinaryContext.cloudinary =Cloudinary.fromCloudName(cloudName: 'dlgwtb6mi');
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");



  runApp(
    ChangeNotifierProvider(
      create: (context) => UserProvider(UserModel(name: "name", email: "email", phone: "phone", userImage: "userImage" )),
      child: const MyApp(),
    ),

  );

}




class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Swap It',
      theme:
      FlexThemeData.light(
        scheme: FlexScheme.sanJuanBlue, // Choose a predefined color scheme
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold, // Customization
        blendLevel: 30,
        appBarStyle: FlexAppBarStyle.background, // Matches the material style
        visualDensity: VisualDensity.comfortable,
        textTheme: GoogleFonts.adaminaTextTheme(),
        useMaterial3: true,
        bottomAppBarElevation: 20,
      ),
      // darkTheme: FlexThemeData.dark(
      //   scheme: FlexScheme.indigo, // Same scheme for dark mode
      //   surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
      //   blendLevel: 15,
      //   appBarStyle: FlexAppBarStyle.background,
      //   visualDensity: VisualDensity.adaptivePlatformDensity,
      //   useMaterial3: true,
      //     textTheme: GoogleFonts.lobsterTextTheme()
      // ),
      themeMode: ThemeMode.system,
      home: const UserLogin(), // Ensure UserLogin is the starting screen
    );
  }
}

