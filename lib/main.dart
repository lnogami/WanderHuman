import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:wanderhuman_app/utilities/color_palette.dart';
import 'package:wanderhuman_app/view/home/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
        fontFamily: 'Poppins',
        textTheme: TextTheme(
          bodyLarge: TextStyle(
            color: MyColorPalette.fontColorB,
          ), // For most text
          bodyMedium: TextStyle(
            color: MyColorPalette.fontColorB,
          ), // For smaller text
          // You can add more styles if needed
        ),
      ),
      // home: MapBody(),
      home: HomePage(),
    );
  }
}
