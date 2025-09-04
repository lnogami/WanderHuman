import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wanderhuman_app/utilities/dimension_adapter.dart';
import 'package:wanderhuman_app/view/home/widgets/utility_functions/option_container.dart';
import 'package:wanderhuman_app/view/home/widgets/utility_functions/my_animated_snackbar.dart';

class MyMenuOptions extends StatefulWidget {
  final bool isVisible;
  const MyMenuOptions({super.key, this.isVisible = false});

  @override
  State<MyMenuOptions> createState() => _MyMenuOptionsState();
}

class _MyMenuOptionsState extends State<MyMenuOptions> {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 180),
      // color: Colors.amber,
      width: MyDimensionAdapter.getWidth(context) - 60,
      height: (widget.isVisible) ? 150 : 0,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // this is just for drawing a thin horizontal line that acts as a border.
            Container(
              width: MyDimensionAdapter.getWidth(context) - 60,
              height: 1,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              margin: EdgeInsets.only(top: 5, bottom: 22.5),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(height: 10),
                optionsContainer(
                  context,
                  onTap: () {},
                  Icons.person_outline_rounded,
                  "Acount",
                ),
                SizedBox(height: 10),
                optionsContainer(
                  context,
                  onTap: () {
                    try {
                      final personalInfo = FirebaseFirestore.instance
                          .collection("Personal Info")
                          .add({
                            "id": 1,
                            "usertype": "Caregiver",
                            "name": "Hori Zontal",
                            "gender": "male",
                            "contactNumber": "09876543210",
                            "address": "NA",
                            "notableTrait": "Imaginative, doer",
                            "profilePictureUrl": "NA",
                            "createdAt": FieldValue.serverTimestamp(),
                          });
                      // showMySnackBar(
                      //   context: context,
                      //   dataToDisplay: personalInfo.toString(),
                      // );
                      // } catch (e) {
                      showMyAnimatedSnackBar(
                        context: context,
                        dataToDisplay: personalInfo.toString(),
                      );
                    } on FirebaseException catch (e) {
                      // showMySnackBar(
                      //   context: context,
                      //   dataToDisplay: e.message.toString(),
                      // );
                      showMyAnimatedSnackBar(
                        context: context,
                        dataToDisplay: e.message.toString(),
                      );
                    }
                  },
                  Icons.add_outlined,
                  "Add Patient",
                ),
                SizedBox(height: 10),
              ],
            ),
            SizedBox(height: 8),
            GestureDetector(
              onTap: () => FirebaseAuth.instance.signOut(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(height: 10),
                  optionsContainer(
                    context,
                    Icons.settings_outlined,
                    "Settings",
                    onTap: () {
                      // showMySnackBar(
                      //   context: context,
                      //   dataToDisplay: "Testing",
                      // );
                      showMyAnimatedSnackBar(
                        context: context,
                        dataToDisplay: "Testing",
                        //                         dataToDisplay: '''
                        // hskbfkjf sfjbskjef sekjfbksejb sfkjbsekfje skjbfkjsbef efkjsbfkjes fskfjbskejbfs efsbfjksbe
                        // sfnsefnkesjf sefkjsbfkjesfskjbfksjebfsfskjbfkjbs fkjbsejkf skjbfsf skfjbskjeb sfkjbeskjf sfkjbefkjbs fskjeb
                        // sfnes skjfes sjefbksf skjfsjef sfk sekjf skej fskj fekjs fk esf eskj
                        // ''',
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
}
