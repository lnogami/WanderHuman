import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wanderhuman_app/utilities/color_palette.dart';
import 'package:wanderhuman_app/utilities/dimension_adapter.dart';
import 'package:wanderhuman_app/components/button.dart';
import 'package:wanderhuman_app/view/login/widgets/layout_material.dart';
import 'package:wanderhuman_app/view/login/widgets/textfield.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

// mainly for login
TextEditingController emailController = TextEditingController();
TextEditingController passwordController = TextEditingController();
// mainly for signup
TextEditingController confirmPasswordController = TextEditingController();
FocusNode passwordFocusNode = FocusNode();
// FocusNode confirmPasswordFocusNode = FocusNode();

bool isGoingToSignUp = false;
double animatedContainerHeight = 0;
double rotationAngle = 0;
int animationDuration = 300;

class _LoginPageState extends State<LoginPage> {
  Future<void> createUserWithEmailAndPassword() async {
    try {
      final UserCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      print(UserCredential);
    } on FirebaseAuthException catch (e) {
      print(e.message);
    }
  }

  // to clean after usage
  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    passwordFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          width: MyDimensionAdapter.getWidth(context),
          height: MyDimensionAdapter.getHeight(context),
          color: Colors.amber.shade200,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              MyLayoutMaterial(
                distanceFromTop: 0,
                heightPercentage: 0.40,
                color: Colors.blue.shade500,
              ),
              MyLayoutMaterial(
                distanceFromTop: 210,
                isSquare: true,
                isSquareSize: MyDimensionAdapter.getHeight(context) * .65,
                borderRadius: 120,
                rotationAngle: -4,
              ),
              // this is where the main content is
              MyLayoutMaterial(
                distanceFromTop: 300,
                heightPercentage: 0.7,
                // color: const Color.fromARGB(118, 76, 175, 79),
                isRotatable: false,
                child: loginContentArea(),
              ),

              // this is where the logo will be placed, and be animated if possible
              Positioned(
                top: 200,
                child: ClipRRect(
                  borderRadius: BorderRadiusGeometry.circular(15),
                  child: AnimatedContainer(
                    width: 100,
                    height: 100,
                    transformAlignment: Alignment.center,
                    transform: Matrix4.rotationZ(rotationAngle),
                    color: Colors.green,
                    duration: Duration(milliseconds: animationDuration),
                    // onEnd: () {},
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /* 
    This is where all the login related Widgets are put together. 
    Scaffold > GestureDetector > MyLayoutMaterial > loginContentArea
  */
  Column loginContentArea() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(height: 30),
        MyCustTextfield(
          textController: emailController,
          prefixIcon: Icons.person_rounded,
          labelText: "Email",
          hintText: "inogami@gmail.com",
          borderRadius: 10,
        ),
        SizedBox(height: 10),
        MyCustTextfield(
          textController: passwordController,
          prefixIcon: Icons.key_rounded,
          labelText: "Password",
          borderRadius: 10,
          focusNode: passwordFocusNode,
          isPasswordField: true,
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
            labelText: "Confirm Password",
            borderRadius: 10,
            borderWidth: (animatedContainerHeight == 50 && isGoingToSignUp)
                ? 1
                : 0,
            borderColor: (animatedContainerHeight == 50 && isGoingToSignUp)
                ? Colors.blue
                : Colors.transparent,
          ),
        ),
        SizedBox(height: 20),
        (isGoingToSignUp) ? confirmSignUpButton() : loginButton(),
        SizedBox(height: 5),
        (isGoingToSignUp) ? cancelSignUpButton() : signUpButton(),
      ],
    );
  }

  MyCustButton loginButton() {
    return MyCustButton(
      onTap: () {
        print("LOGIN BUTTON PRESSEDDDDDDDDDDDDDDDDDDDDDDDDDD");
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
        createUserWithEmailAndPassword();
        print("CONFIRM SIGNUP BUTTON PRESSEDDDDDDDDDDDDDDDDDDDDDDDDDD");
      },
      buttonText: "CONFIRM SIGNUP",
      color: Colors.blue,
      buttonTextFontWeight: FontWeight.w700,
      buttonTextColor: Colors.white,
      buttonTextSpacing: 1,
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
