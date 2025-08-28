// // import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_login/flutter_login.dart';
// import 'package:wanderhuman_app/utilities/dimension_adapter.dart';

// /// This is a temporary LoginPage, not yet final to be use or not.
// class TemporaryLoginPage extends StatelessWidget {
//   const TemporaryLoginPage({super.key});

//   // loading Duration
//   Duration get loadingTime => Duration(milliseconds: 1500);

//   // for Authentication (Loging in)
//   Future<String?> _authUser(LoginData data) async {
//     return Future.delayed(loadingTime).then((value) => null);
//   }

//   Future<String?> _recoveryPassword(String data) async {
//     return Future.delayed(loadingTime).then((value) => null);
//   }

//   // for Signing up
//   // Future<void> _onSignup(SignupData signupData) async {
//   //   // return Future.delayed(loadingTime).then((value) => null);
//   //   await Future.delayed(loadingTime).then((value) {
//   //     FirebaseAuth.instance.createUserWithEmailAndPassword(
//   //       email: signupData.name!,
//   //       password: signupData.password!,
//   //     );
//   //   });
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: FlutterLogin(
//         logo: "assets/icons/isagi.jpg",
//         onLogin: _authUser,
//         onRecoverPassword: _recoveryPassword,
//         // onSignup: _onSignup,
//         keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
//         footer: "Hello, World! This is a String footer.",
//         headerWidget: headerArea(context),
//         scrollable: true,
//         // showDebugButtons: true,
//       ),
//     );
//   }

//   // The whole are where the header is.
//   Padding headerArea(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 10, bottom: 30),
//       child: SizedBox(
//         width: MyDimensionAdapter.getWidth(context),
//         height: 70,
//         // color: Colors.green,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Text("Hello, welcome to"),
//             Text(
//               "WanderHuman!",
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
