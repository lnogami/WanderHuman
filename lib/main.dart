import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:wanderhuman_app/firebase_options.dart';
import 'package:wanderhuman_app/helper/personal_info_repository.dart';
import 'package:wanderhuman_app/utilities/properties/color_palette.dart';
import 'package:wanderhuman_app/view-model/home_appbar_provider.dart';
import 'package:wanderhuman_app/view-model/home_geofence_config_provider.dart';
import 'package:wanderhuman_app/view-model/home_settings_provider.dart';
import 'package:wanderhuman_app/view-model/my_mapbox_ref_provider.dart';
import 'package:wanderhuman_app/view/home/home.dart';
import 'package:wanderhuman_app/view/home/widgets/map/geofence_related_stuff/geo_logics/notifcation_alerts.dart';
import 'package:wanderhuman_app/view/login/login.dart';
import 'package:wanderhuman_app/view/userRolesUI/no_role_yet_landing_page.dart';

// The "spy" that watches the navigation stack. This will be a big help later on
// in the map. This will detect if the map screen is not visible, so that we can
// save resources, like canceling StreamSubscriptions
final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

void main() async {
  // this will enure that other components are initialized first before running the whole app
  WidgetsFlutterBinding.ensureInitialized();
  // flutter initialization/configuration related
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Load environment variables from .env file
  await dotenv.load(fileName: ".env");
  // To prevent the device from sleeping.
  WakelockPlus.enable();
  // To initialize notification alerts
  await MyAlertNotification.init();

  runApp(
    // Phoenix is a wrapper that is capable of resrting the app.
    Phoenix(child: const MainApp()),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      // DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return MultiProvider(
      providers: [
        // NOTE: this is just a placeholder for now. It does not have a function yet as it is just a placeholder.
        ChangeNotifierProvider(create: (context) => HomeAppBarProvider()),
        // for Mapbox configuration
        ChangeNotifierProvider(create: (context) => MyMapboxRefProvider()),
        // newly added (not yet tested as of Feb05, 2026)
        ChangeNotifierProvider(
          create: (context) => MyHomeGeofenceConfigurationProvider(),
        ),
        // newly added (not yet tested as of Feb14, 2026)
        ChangeNotifierProvider(create: (context) => MyHomeSettingsProvider()),
      ],
      child: MaterialApp(
        navigatorObservers: [routeObserver], // registering the route observer
        debugShowCheckedModeBanner: false,
        color: MyColorPalette.formColor,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          // affects app bar, etc.
          primaryColor: Colors.blue,
          // this affects highlighted components, such as a TextField with focus, etc.
          colorScheme: ColorScheme.fromSwatch().copyWith(
            secondary: Colors.blue,
          ),
          // affects the scaffold's background
          // scaffoldBackgroundColor: Colors.white,
          scaffoldBackgroundColor: MyColorPalette.formColor,
          fontFamily: 'Poppins',
          textTheme: TextTheme(
            // For most text
            bodyLarge: TextStyle(color: MyColorPalette.fontColorB),
            // For smaller text
            bodyMedium: TextStyle(color: MyColorPalette.fontColorB),
          ),
        ),
        // StreamBuilder will build the UI
        //               it is like a FutureBuilder, this one will update everytime its listener change something.
        //               StreamBuilder always listen to changes unless it is turn off.
        home: StreamBuilder(
          // this it the StreamBuilder's source of data, a Stream with generic User type
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, streamSnapshot) {
            // if the stream is just ongoing yet, a loading visual will appear temporarily
            if (streamSnapshot.connectionState == ConnectionState.waiting) {
              // we need to have a temporary scaffold here to have a surface for the loading visual
              return Scaffold(
                body: const Center(child: CircularProgressIndicator()),
              );
            } else if (streamSnapshot.data != null) {
              // a FutureBuilder is just like a StreamBuilder but it is done after the execution of the Future is finished.
              return FutureBuilder(
                // FutureBuilder's source of data, a Future with generic PersonalInfo type
                future: MyPersonalInfoRepository.getSpecificPersonalInfo(
                  userID: streamSnapshot.data!.uid,
                ),
                builder: (context, futureSnapshot) {
                  // returns a loading visual if the future is still ongoing
                  if (futureSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    // we need to have a temporary scaffold here to have a surface for the loading visual
                    return Scaffold(
                      body: const Center(child: CircularProgressIndicator()),
                    );
                  }
                  // will direct you to the NoRoleYetLandingPage if the user has no role yet
                  else if (futureSnapshot.data!.userType == "No Role") {
                    return NoRoleYetLandingPage(
                      userNameToDisplay: futureSnapshot.data!.name,
                    );
                  }
                  // // will direct you to the HomePage if the user has a data and has a role
                  else {
                    return HomePage();
                  }
                },
              );
            }
            // will direct you to the LoginPage if the user has no data, meaning the user is not logged in or not yet registered
            else {
              return LoginPage();
            }
          },
        ),
        // home: TemporaryLoginPage(),
      ),
    );
  }
}
