import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wanderhuman_app/utilities/dimension_adapter.dart';
import 'package:wanderhuman_app/view/add_patient_form/add_patient_form.dart';
import 'package:wanderhuman_app/helper/firebase_services.dart';
import 'package:wanderhuman_app/view/home/widgets/home_utility_functions/option_container.dart';
import 'package:wanderhuman_app/view/home/widgets/home_utility_functions/my_animated_snackbar.dart';
import 'package:wanderhuman_app/view/home/widgets/map/patient_simulator_container.dart';

class MyMenuOptions extends StatefulWidget {
  final bool isVisible;
  const MyMenuOptions({super.key, this.isVisible = false});

  @override
  State<MyMenuOptions> createState() => _MyMenuOptionsState();
}

class _MyMenuOptionsState extends State<MyMenuOptions> {
  double buttonsHorizontalGap = 8;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(
        milliseconds: (MyFirebaseServices.getUserType() == "admin") ? 200 : 180,
      ),
      // color: Colors.amber,
      width: MyDimensionAdapter.getWidth(context) - 60,
      height: (widget.isVisible)
          // nested conditional operator haha
          ? (MyFirebaseServices.getUserType() == "admin")
                ? 220
                : 150
          : 0,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // this is just for drawing a thin horizontal line that acts as a border.
            Container(
              width: MyDimensionAdapter.getWidth(context) - 60,
              height: 1,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              margin: EdgeInsets.only(top: 5), // bottom: 22.5),
            ),

            // displays user type
            toDisplayUserType(),

            SizedBox(
              height: MyFirebaseServices.getUserType() == "admin" ? 15 : 2,
            ),

            // admin exclusive options
            (MyFirebaseServices.getUserType() == "admin")
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(height: 10),
                      optionsContainer(
                        context,
                        Icons.person_pin_circle_outlined,
                        bgColor: Colors.green[300]!,
                        "Simulate",
                        onTap: () {
                          //
                          // Navigator.pop(context);
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => PatientSimulatorContainer(),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 10),
                      optionsContainer(
                        context,
                        Icons.add_outlined,
                        "Placeholder",
                        onTap: () {
                          showMyAnimatedSnackBar(
                            context: context,
                            dataToDisplay: "Admin Privilege",
                          );
                        },
                      ),
                      SizedBox(height: 10),
                    ],
                  )
                : SizedBox(height: 0),

            SizedBox(height: buttonsHorizontalGap),

            // buttons/options
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(height: 10),
                optionsContainer(
                  context,
                  Icons.person_outline_rounded,
                  "Acount",
                  onTap: () {
                    MyFirebaseServices.getAllPatients()
                        .then((value) {
                          showMyAnimatedSnackBar(
                            context: context,
                            dataToDisplay: "${value.length}",
                          );
                        })
                        .catchError((error) {
                          showMyAnimatedSnackBar(
                            context: context,
                            dataToDisplay: error.toString(),
                          );
                        });
                  },
                ),
                SizedBox(height: 10),
                optionsContainer(
                  context,
                  Icons.add_outlined,
                  "Add Patient",
                  onTap: () {
                    AddPatientForm();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddPatientForm()),
                    );
                  },
                ),
                SizedBox(height: 10),
              ],
            ),

            SizedBox(height: buttonsHorizontalGap),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(height: 10),
                optionsContainer(
                  context,
                  Icons.settings_outlined,
                  "Settings",
                  onTap: () {
                    showMyAnimatedSnackBar(
                      context: context,
                      dataToDisplay: "Testing",
                    );
                  },
                ),
                SizedBox(height: 10),
                optionsContainer(
                  context,
                  onTap: () {
                    FirebaseAuth.instance.signOut();
                  },
                  Icons.logout_outlined,
                  "Logout",
                  bgColor: const Color.fromARGB(130, 255, 108, 108),
                ),
                SizedBox(height: 10),
              ],
            ),
            // SizedBox(height: 20),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.end,
            //   children: [
            //     Icon(
            //       Icons.person_outline_rounded,
            //       color: const Color.fromARGB(200, 0, 0, 0),
            //     ),
            //     Spacer(),
            //     Text("Acount"),
            //   ],
            // ),
            // SizedBox(height: 10),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.end,
            //   children: [
            //     Icon(Icons.add, color: const Color.fromARGB(200, 0, 0, 0)),
            //     Spacer(),
            //     Text("Add Patient"),
            //   ],
            // ),
            // SizedBox(height: 10),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.end,
            //   children: [
            //     Icon(
            //       Icons.settings_outlined,
            //       color: const Color.fromARGB(200, 0, 0, 0),
            //     ),
            //     Spacer(),
            //     Text("Settings"),
            //   ],
            // ),
            // Container(
            //   width: MyDimensionAdapter.getWidth(context),
            //   height: 1,
            //   decoration: BoxDecoration(
            //     color: Colors.blue[100],
            //     borderRadius: BorderRadius.all(Radius.circular(30)),
            //   ),
            //   margin: EdgeInsets.only(top: 10, bottom: 15),
            // ),
            // GestureDetector(
            //   onTap: () => FirebaseAuth.instance.signOut(),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.end,
            //     children: [
            //       Icon(
            //         Icons.exit_to_app_rounded,
            //         color: const Color.fromARGB(200, 0, 0, 0),
            //       ),
            //       Spacer(),
            //       Text("Logout"),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Row toDisplayUserType() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          // for grammatical purposes
          (MyFirebaseServices.getUserType() == "admin")
              ? "You are an "
              : "You are a ",
          style: TextStyle(fontSize: 11, color: Colors.blueGrey),
        ),
        Text(
          MyFirebaseServices.getUserType().toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            // fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w500,
            color: Colors.blueGrey,
          ),
        ),
      ],
    );
  }
}
