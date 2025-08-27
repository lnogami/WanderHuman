import 'package:flutter/material.dart';
import 'package:wanderhuman_app/utilities/dimension_adapter.dart';
import 'package:wanderhuman_app/view/login/widgets/layout_material.dart';
import 'package:wanderhuman_app/view/login/widgets/textfield.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

TextEditingController usernameController = TextEditingController();
TextEditingController passwordController = TextEditingController();

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MyDimensionAdapter.getWidth(context),
        height: MyDimensionAdapter.getHeight(context),
        color: Colors.amber.shade200,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            //Original before creating customed Widget ====================
            // Positioned(
            //   top: 0,
            //   child: Container(
            //     width: MyDimensionAdapter.getWidth(context),
            //     height: MyDimensionAdapter.getHeight(context) * 0.35,
            //     color: Colors.blue.shade200,
            //   ),
            // ),
            //My customed widget -----------------------------------------
            MyLayoutMaterial(
              distanceFromTop: 0,
              heightPercentage: 0.35,
              color: Colors.blue.shade500,
            ),
            //Original before creating customed Widget ====================
            // Positioned(
            //   top: 210,
            //   child: Container(
            //     width: MyDimensionAdapter.getHeight(context) * 0.65,
            //     height: MyDimensionAdapter.getHeight(context) * 0.65,
            //     decoration: BoxDecoration(
            //       color: Colors.white,
            //       borderRadius: BorderRadius.circular(120),
            //     ),
            //     transform: Matrix4.rotationZ(Math.pi / -4),
            //     transformAlignment: Alignment.center,
            //     child: Center(child: Text("Hellooo")),
            //   ),
            // ),
            //My customed widget -----------------------------------------
            MyLayoutMaterial(
              distanceFromTop: 210,
              isSquare: true,
              isSquareSize: MyDimensionAdapter.getHeight(context) * .65,
              borderRadius: 120,
              rotationAngle: -4,
            ),

            //Original before creating customed Widget ====================
            // Positioned(
            //   top: 300,
            //   child: Container(
            //     width: MyDimensionAdapter.getWidth(context),
            //     height: MyDimensionAdapter.getHeight(context) - 300,
            //     color: const Color.fromARGB(147, 165, 214, 167),
            //     child: Column(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       children: [],
            //     ),
            //   ),
            // ),
            //My customed widget -----------------------------------------
            MyLayoutMaterial(
              distanceFromTop: 300,
              heightPercentage: 0.7,
              // color: const Color.fromARGB(118, 76, 175, 79),
              isRotatable: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("Hellooo"),
                  Text("World!!!"),
                  Text("We love Flutter!"),
                  MyCustTextfield(
                    textController: usernameController,
                    prefixIcon: Icons.person_rounded,
                    labelText: "Username",
                    hintText: "Username...",
                  ),
                  SizedBox(height: 10),
                  MyCustTextfield(
                    textController: passwordController,
                    prefixIcon: Icons.key_rounded,
                    labelText: "Password",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
