import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:wanderhuman_app/firebase_options.dart';
import 'package:wanderhuman_app/utilities/color_palette.dart';
import 'package:wanderhuman_app/view-model/home_appbar_proider.dart';
import 'package:wanderhuman_app/view/home/home.dart';
import 'package:wanderhuman_app/view/login/login.dart';

void main() async {
  // this will enure that other components are initialized first before running the whole app
  WidgetsFlutterBinding.ensureInitialized();
  // flutter initialization/configuration related
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Load environment variables from .env file
  await dotenv.load(fileName: ".env");
  // To prevent the device from sleeping.
  WakelockPlus.enable();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // NOTE: this is just a placeholder for now. It does not have a function yet as it is just a placeholder.
        ChangeNotifierProvider(
          create: (context) => HomeAppBarProvider(),
        ), // NOTE: this is just here because if I remove this it will call an error, the children must not be empty.
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          // affects app bar, etc.
          primaryColor: Colors.blue,
          // this affects highlighted components, such as a TextField with focus, etc.
          colorScheme: ColorScheme.fromSwatch().copyWith(
            secondary: Colors.blue,
          ),
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
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, asyncSnapshot) {
            if (asyncSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (asyncSnapshot.data != null) {
              return HomePage();
            } else {
              return LoginPage();
            }
          },
        ),
        // home: TemporaryLoginPage(),
      ),
    );
  }
}
