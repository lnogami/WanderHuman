import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wanderhuman_app/model/personal_info.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';
import 'package:wanderhuman_app/utilities/properties/universal_sizes.dart';
import 'package:wanderhuman_app/view/components/alert_dialogue.dart';
import 'package:wanderhuman_app/view/home_appbar/user_role_previlige.dart';
import 'package:wanderhuman_app/view/components/option_container.dart';
import 'package:wanderhuman_app/view/components/my_animated_snackbar.dart';

class MyMenuOptions extends StatefulWidget {
  final bool isVisible;
  final PersonalInfo loggedInUserData;
  const MyMenuOptions({
    super.key,
    this.isVisible = false,
    required this.loggedInUserData,
  });

  @override
  State<MyMenuOptions> createState() => _MyMenuOptionsState();
}

class _MyMenuOptionsState extends State<MyMenuOptions> {
  // the space between User Role and the role previlige options in the menu.
  double? _horizontalSpace;

  double getHorizontalSpace() {
    switch (widget.loggedInUserData.userType.toUpperCase()) {
      case "ADMIN":
        return 10; // as of Dec,18,25, not yet tested
      case "SOCIAL SERVICE":
        return 10; // already tested
      case "MEDICAL SERVICE":
        return 15;
      case "PSYCHOLOGICAL SERVICE":
        return 15;
      case "HOME LIFE":
        return 15;
      case "PSD":
        return 15;
      default:
        return 0;
    }
  }

  // String _userType = "";
  // Future<void> getUserType() async {
  //   _userType = await MyPersonalInfoRepository.getSpecificPersonalInfo(
  //     userID: FirebaseAuth.instance.currentUser!.uid,
  //   ).then((personalInfo) => personalInfo.userType);
  // }

  @override
  void initState() {
    super.initState();

    setState(() {
      // getUserType(); // to initialize userType
      _horizontalSpace = getHorizontalSpace();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(
        milliseconds:
            (widget.loggedInUserData.userType.toUpperCase() == "ADMIN")
            ? 200
            : 180,
      ),
      // color: Colors.amber,
      width: MyDimensionAdapter.getWidth(context) - 60,
      height: (widget.isVisible)
          // nested conditional operator haha
          ? (widget.loggedInUserData.userType.toUpperCase() == "ADMIN")
                // ? 220
                // : 150
                ? 150
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

            // this is only for spacing purposes only, might be adjustable base on how many user previlige options there are for each user Roles.
            SizedBox(
              // height: (MyFirebaseServices.getUserType() == "admin") ? 15 : 2,
              height: (_horizontalSpace == 0) ? 10 : _horizontalSpace,
            ),

            // Determine user role privilege options to display
            MyUserRolePrevilige(userType: widget.loggedInUserData.userType),

            SizedBox(height: MySizes.buttonsHorizontalGap),

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
                    myAlertDialogue(
                      context: context,
                      alertTitle: "Confirm Logout",
                      alertContent: "Are you sure you want to logout?",
                      onApprovalPressed: () {
                        Navigator.pop(context);
                        FirebaseAuth.instance.signOut();
                      },
                    );
                  },
                  Icons.logout_outlined,
                  "Logout",
                  // bgColor: const Color.fromARGB(80, 255, 108, 108),
                  // bgColor: const Color.fromARGB(70, 255, 198, 198),
                  bgColor: const Color.fromARGB(70, 255, 234, 234),
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
          (widget.loggedInUserData.userType == "ADMIN")
              ? "You are an "
              : "You are a ",
          // ? "Your role is an "
          // : "Your role is ",
          style: TextStyle(fontSize: 11, color: Colors.blueGrey),
        ),
        Text(
          widget.loggedInUserData.userType.toUpperCase(),
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
