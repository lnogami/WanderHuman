import 'dart:developer';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wanderhuman_app/utilities/properties/color_palette.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';
import 'package:wanderhuman_app/utilities/properties/text_formatter.dart';
import 'package:wanderhuman_app/view/app_version.dart';
import 'package:wanderhuman_app/view/components/button.dart';
import 'package:wanderhuman_app/view/components/my_animated_snackbar.dart';
import 'package:wanderhuman_app/view/login/register_account.dart';
import 'package:wanderhuman_app/view/login/widgets/layout_material.dart';
import 'package:wanderhuman_app/view/components/textfield.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // mainly for login
  late TextEditingController emailController;
  late FocusNode emailFocusNode;
  late TextEditingController passwordController;
  late FocusNode passwordFocusNode;
  // mainly for signup
  late TextEditingController confirmPasswordController;

  // error notifier
  Color emailFieldColor = MyColorPalette.borderColor;
  Color passwordFieldColor = MyColorPalette.borderColor;

  // FocusNode confirmPasswordFocusNode = FocusNode();

  bool isGoingToSignUp = false;
  double animatedContainerHeight = 0;
  double rotationAngle = 0;
  int animationDuration = 300;

  // for triggering a loading animation on the Login button
  bool isLoggingIn = false;

  // FOR LOGIN
  Future<void> signInWithEmailAndPassword() async {
    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );
      print("LOGGED IN: $userCredential");
    } on FirebaseAuthException catch (e) {
      print("Error during login: ${e.message}");
      // stop the button's loading nimation
      setState(() => isLoggingIn = false);

      // If error was caused by internect connectivity failure
      if (e.message.toString().contains("A network error")) {
        showMyAnimatedSnackBar(
          context: context,
          dataToDisplay:
              "A network error occured. Please check your internet connection and try again.",
        );
      }
      // Incorrect credentials
      else {
        showMyAnimatedSnackBar(
          // ignore: use_build_context_synchronously
          context: context,
          dataToDisplay: "The email or password is incorrect.",
        );
      }
    }
  }

  // FOR EMAIL INPUT FIELD VALIDATION
  void _latestValueOnEmailControllerListener() {
    if ((!emailController.text.contains('@') ||
            (emailController.text.contains('@') &&
                emailController.text.length < 6)) &&
        emailController.text.isNotEmpty) {
      setState(() => emailFieldColor = Colors.redAccent);
    } else {
      setState(() => emailFieldColor = MyColorPalette.borderColor);
    }
  }

  // FOR PASSWORD INPUT FIELDS VALIDATION
  void _latestValueOnPasswordListener() {
    if (passwordController.text.trim().length < 6 &&
        passwordController.text.isNotEmpty) {
      setState(() {
        passwordFieldColor = Colors.redAccent;
      });
      print("PASSWORDS DOES NOT MATCH!");
    } else {
      setState(() {
        passwordFieldColor = MyColorPalette.borderColor;
        print("PASSWORDS MATCH!");
      });
    }
  }

  // FOR PASSWORD INPUT FIELDS VALIDATION
  void _latestValueOnConfirmPasswordListener() {
    if (confirmPasswordController.text.trim() !=
            passwordController.text.trim() ||
        confirmPasswordController.text.length < 6) {
      setState(() {
        passwordFieldColor = Colors.redAccent;
      });
      print("PASSWORDS DOES NOT MATCH!");
    } else {
      setState(() {
        passwordFieldColor = MyColorPalette.borderColor;
        print("PASSWORDS MATCH!");
      });
    }
  }

  // to initialize before after usage
  @override
  void initState() {
    super.initState();

    emailController = TextEditingController();
    emailController.addListener(_latestValueOnEmailControllerListener);
    emailFocusNode = FocusNode();

    passwordController = TextEditingController();
    passwordController.addListener(_latestValueOnPasswordListener);
    passwordFocusNode = FocusNode();

    confirmPasswordController = TextEditingController();
    confirmPasswordController.addListener(
      _latestValueOnConfirmPasswordListener,
    );
  }

  // to clean after usage
  @override
  void dispose() {
    super.dispose();
    emailController.removeListener(_latestValueOnEmailControllerListener);
    emailController.dispose();
    emailFocusNode.dispose();

    passwordController.removeListener(_latestValueOnPasswordListener);
    passwordController.dispose();
    passwordFocusNode.dispose();

    confirmPasswordController.removeListener(
      _latestValueOnConfirmPasswordListener,
    );
    confirmPasswordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Container(
            width: MyDimensionAdapter.getWidth(context),
            height: MyDimensionAdapter.getHeight(context),
            // color: Colors.amber.shade200,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                MyLayoutMaterial(
                  distanceFromTop: 0,
                  heightPercentage: 0.40,
                  color: Colors.blue.shade300,
                ),
                MyLayoutMaterial(
                  distanceFromTop: 130,
                  isSquare: true,
                  isSquareSize: MyDimensionAdapter.getHeight(context) * .65,
                  borderRadius: 120,
                  rotationAngle: -4,
                ),
                // This is where the main content is
                MyLayoutMaterial(
                  distanceFromTop: 320,
                  heightPercentage: 0.7,
                  isRotatable: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      loginContentArea(),

                      SizedBox(height: 20),
                      (isGoingToSignUp) ? confirmSignUpButton() : loginButton(),
                      SizedBox(height: 5),
                      (isGoingToSignUp) ? cancelSignUpButton() : signUpButton(),
                    ],
                  ),
                ),

                // this is where the logo will be placed, and be animated if possible
                Positioned(
                  top: 110,
                  child: ClipRRect(
                    borderRadius: BorderRadiusGeometry.circular(15),
                    child: AnimatedContainer(
                      width: 150,
                      height: 150,
                      transformAlignment: Alignment.center,
                      transform: Matrix4.rotationZ(rotationAngle),
                      // color: Colors.blue.shade300,
                      duration: Duration(milliseconds: animationDuration),
                      // onEnd: () {},
                      child: Image.asset(
                        "assets/app_icon/wander_human_app_logo.png",
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: 265,
                  // child: MyTextFormatter.h3(text: "WanderHuman", fontsize: 32),
                  child: AnimatedTextKit(
                    repeatForever: true,
                    pause: Duration.zero,
                    animatedTexts: [
                      ColorizeAnimatedText(
                        "WanderHuman",
                        textStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                          // color: Colors.blue.shade400,
                        ),
                        colors: [
                          Colors.blue.shade400,
                          Colors.blue.shade100,
                          // Colors.white,
                          Colors.blue.shade200,
                          Colors.blue.shade400,
                          Colors.blue.shade600,
                          Colors.blue.shade500,
                          Colors.blue.shade400,
                        ],
                        speed: Duration(milliseconds: 500),
                      ),
                      // RotateAnimatedText(
                      //   "WanderHuman",
                      //   textStyle: TextStyle(
                      //     fontWeight: FontWeight.bold,
                      //     fontSize: 32,
                      //     color: Colors.blue.shade400,
                      //   ),
                      // ),
                      FadeAnimatedText(
                        "WanderHuman",
                        textStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                          color: Colors.blue.shade400,
                        ),
                      ),
                    ],
                  ),
                ),

                // App version number
                Positioned(bottom: 5, child: SafeArea(child: MyAppVersion())),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Column loginContentArea() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 30),
        MyCustTextfield(
          textController: emailController,
          prefixIcon: Icons.person_rounded,
          labelText: "Email",
          hintText: "inogami@gmail.com",
          focusNode: emailFocusNode,
          borderRadius: 10,
          // color: emailFieldColor,
          borderColor: emailFieldColor,
          activeBorderColor: emailFieldColor,
        ),
        invalidInputVisuals(
          conditionToTriggerWarning:
              (!emailController.text.contains('@') &&
              emailController.text.isNotEmpty &&
              !emailFocusNode.hasFocus),
          warningText: "Please enter a valid email address.",
        ),
        invalidInputVisuals(
          conditionToTriggerWarning:
              (emailController.text.contains('@') &&
              emailController.text.length < 6 &&
              !emailFocusNode.hasFocus),
          warningText: "Invalid email",
        ),
        SizedBox(height: 10),

        MyCustTextfield(
          textController: passwordController,
          prefixIcon: Icons.key_rounded,
          labelText: "Password",
          borderRadius: 10,
          focusNode: passwordFocusNode,
          isPasswordField: true,
          borderColor: passwordFieldColor,
          activeBorderColor: passwordFieldColor,
        ),
        invalidInputVisuals(
          conditionToTriggerWarning:
              (passwordController.text.length < 6 &&
              passwordController.text.isNotEmpty),
          warningText: "Invalid password length, at least 6 characters.",
        ),

        AnimatedContainer(
          // width: 0,
          height: animatedContainerHeight,
          margin: EdgeInsets.only(top: 10),
          duration: Duration(milliseconds: animationDuration),
          child: MyCustTextfield(
            textController: confirmPasswordController,
            prefixIcon: Icons.key_rounded,
            prefixIconColor: (animatedContainerHeight == 50 && isGoingToSignUp)
                ? Colors.grey
                : Colors.transparent,
            suffixIconColor: (animatedContainerHeight == 50 && isGoingToSignUp)
                ? Colors.blue
                : Colors.transparent,
            labelText: "Confirm Password",
            borderRadius: 10,
            borderWidth: (animatedContainerHeight == 50 && isGoingToSignUp)
                ? 1
                : 0,
            borderColor: (animatedContainerHeight == 50 && isGoingToSignUp)
                ? passwordFieldColor
                : Colors.transparent,
            activeBorderColor: passwordFieldColor,
            isPasswordField: true,
          ),
        ),
        invalidInputVisuals(
          conditionToTriggerWarning:
              (passwordController.text.trim() !=
                  confirmPasswordController.text.trim() &&
              confirmPasswordController.text.isNotEmpty &&
              !passwordFocusNode.hasFocus),
          warningText: "Passwords does not match.",
        ),
      ],
    );
  }

  Widget invalidInputVisuals({
    required bool conditionToTriggerWarning,
    required String warningText,
  }) {
    if (conditionToTriggerWarning) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 1),
          MyTextFormatter.p(
            text: warningText,
            fontsize: kDefaultFontSize - 4,
            color: Colors.red,
            maxLines: 2,
          ),
        ],
      );
    } else {
      return SizedBox();
    }
  }

  Widget loginButton() {
    return (isLoggingIn)
        ? CircularProgressIndicator.adaptive()
        : MyCustButton(
            onTap: () async {
              setState(() => isLoggingIn = true);
              await signInWithEmailAndPassword();
              // print("LOGIN BUTTON PRESSEDDDDDDDDDDDDDDDDDDDDDDDDDD");

              FocusManager.instance.primaryFocus?.unfocus();
            },
            buttonText: "LOGIN",
            color: Colors.blue,
            buttonTextFontWeight: FontWeight.w700,
            buttonTextColor: Colors.white,
          );
  }

  MyCustButton confirmSignUpButton() {
    return MyCustButton(
      onTap: () {
        // if Passwords does not match
        if (passwordController.text.trim() !=
            confirmPasswordController.text.trim()) {
          showMyAnimatedSnackBar(
            context: context,
            dataToDisplay:
                "Passwords does not match. Please make sure it matches.",
          );
        }
        // if Password does not have 6 or more characters
        else if (passwordController.text.length < 6) {
          showMyAnimatedSnackBar(
            context: context,
            dataToDisplay: "Password length must at least 6 characters.",
          );
        }
        // if everything is complied, then proceed
        else {
          bottomModalSheetOfSignUp(
            context: context,
            email: emailController.text,
            password: passwordController.text,
          );
        }
      },
      buttonText: "REGISTER ACCOUNT",
      color: Colors.blue,
      buttonTextFontWeight: FontWeight.w700,
      buttonTextColor: Colors.white,
      buttonTextSpacing: 1,
      buttonWidth: 200,
    );
  }

  MyCustButton signUpButton() {
    return MyCustButton(
      onTap: () {
        setState(() {
          // if it is 0, move to 50
          if (animatedContainerHeight == 0 && isGoingToSignUp == false) {
            animatedContainerHeight = 50;
            isGoingToSignUp = true;
          }
          // if it is 50, revert back to 0
          else {
            animatedContainerHeight = 0;
            isGoingToSignUp = false;
          }
        });
      },
      buttonText: "SIGNUP",
      color: Colors.white,
      buttonTextFontWeight: FontWeight.w400,
      buttonTextColor: MyColorPalette.fontColorB,
      enableShadow: false,
      borderWidth: 0.5,
      borderColor: Colors.white,
    );
  }

  MyCustButton cancelSignUpButton() {
    return MyCustButton(
      onTap: () {
        setState(() {
          // requestFocus() para mabalhin ang focus sa textfield before sya ma render out.
          passwordFocusNode.requestFocus();
          passwordFocusNode.unfocus();
          isGoingToSignUp = !isGoingToSignUp;
          animatedContainerHeight = 0;
          emailController.clear();
          passwordController.clear();
          confirmPasswordController.clear();
        });
      },
      buttonText: "CANCEL",
      color: Colors.white,
      buttonTextFontWeight: FontWeight.w400,
      buttonTextColor: MyColorPalette.fontColorB,
      enableShadow: false,
      borderWidth: 0.5,
      borderColor: Colors.white,
    );
  }
}
