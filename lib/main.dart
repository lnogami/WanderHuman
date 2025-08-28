import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:wanderhuman_app/firebase_options.dart';
import 'package:wanderhuman_app/utilities/color_palette.dart';
import 'package:wanderhuman_app/view/login/login.dart';
import 'package:wanderhuman_app/view/login/temp_login.dart';

void main() async {
  // this will enure that other components are initialized first before running the whole app
  WidgetsFlutterBinding.ensureInitialized();
  // flutter initialization/configuration related
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Load environment variables from .env file
  await dotenv.load(fileName: ".env");
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // affects app bar, etc.
        primaryColor: Colors.blue,
        // this affects highlighted components, such as a TextField with focus, etc.
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.blue),
        // affects the scaffold's background
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Poppins',
        textTheme: TextTheme(
          bodyLarge: TextStyle(
            color: MyColorPalette.fontColorB,
          ), // For most text
          bodyMedium: TextStyle(
            color: MyColorPalette.fontColorB,
          ), // For smaller text
        ),
      ),
      // home: MapBody(),

      // home: HomePage(),
      home: LoginPage(),
      // home: TemporaryLoginPage(),
    );
  }
}
