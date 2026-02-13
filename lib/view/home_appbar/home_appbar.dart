import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wanderhuman_app/model/personal_info.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';
import 'package:wanderhuman_app/view-model/home_appbar_provider.dart';
import 'package:wanderhuman_app/view/components/image_displayer.dart';
import 'package:wanderhuman_app/view/home_appbar/home_appbar_dynamic_panel.dart';
import 'package:wanderhuman_app/view/home_appbar/menu_options.dart';
import 'package:wanderhuman_app/view/components/profile_picture_bottom_modal_sheet.dart';

class HomeAppBar extends StatefulWidget {
  /// This will contain the data of the logged in user for efficient usage in every other components.
  final PersonalInfo loggedInUserData;
  const HomeAppBar({super.key, required this.loggedInUserData});

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<HomeAppBar> {
  int animationDuration = 200;
  double animatedOpacity = 0.0;
  // bool isExpanded = false;
  double borderRadius = 50;

  // // pang cache sa user (patient) list
  // List<PersonalInfo> usersList = [];
  // String userName = "User";
  // // fetches all the users from firestore through MyFirebaseServices
  // Future<void> fetchUsers() async {
  //   usersList = await MyPersonalInfoRepository.getAllPersonalInfoRecords();
  // }
  // // to get the current user's name and UPDATE the userName variable's state
  // Future<void> fetchAndSetUsername() async {
  //   try {
  //     await fetchUsers();
  //     String name =
  //         MyPersonalInfoRepository.getSpecificUserNameOfTheLoggedInAccount(
  //           personsList: usersList,
  //           userIDToLookFor: FirebaseAuth.instance.currentUser!.uid,
  //         );
  //     setState(() {
  //       userName = name;
  //     });
  //   } catch (e) {
  //     print("❌❌❌ Error fetching user name: $e");
  //   }
  // }

  @override
  void initState() {
    super.initState();
    // fetchAndSetUsername(); //(deletable)
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeAppBarProvider>();

    return AnimatedContainer(
      duration: Duration(milliseconds: animationDuration),
      width: MyDimensionAdapter.getWidth(context) * 0.80,
      height: (provider.isAppBarExpanded)
          ? MyDynamicAppbarHeight.expandingOuterPanelHeight(
              widget.loggedInUserData.userType,
            )
          : 50,
      decoration: BoxDecoration(
        color: (provider.isAppBarExpanded)
            ? const Color.fromARGB(210, 255, 255, 255)
            : Colors.white70,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(borderRadius),
          topRight: Radius.circular(borderRadius),
          bottomLeft: Radius.circular(borderRadius),
          bottomRight: Radius.circular(borderRadius),
        ),
      ),
      padding: EdgeInsets.only(left: 8, right: 10, top: 5, bottom: 0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                // the user avatar/pic/icon container
                GestureDetector(
                  onTap: () {
                    showProfilePictureBottomModalSheet(
                      context,
                      currentLoggedInUserData: widget.loggedInUserData,
                    );
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.blue[100],
                    child: MyImageDisplayer(
                      base64ImageString: provider.cachedImageString,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                // greeting text
                SizedBox(
                  width: MyDimensionAdapter.getWidth(context) * 0.50,
                  // this userName will be updated by setState
                  // child: (userName == "...")
                  child: (widget.loggedInUserData.name == "...")
                      ? CircularProgressIndicator()
                      : Text(
                          // "${dotenv.env['SAMPLE_TEXT']}",
                          // "a dnbajbdjab ahbdhjabd ajbdhwbahw abdabhj",
                          // userName,
                          provider.userName,
                          style: TextStyle(
                            // color: Colors.,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                ),
                Spacer(),
                // menu button
                InkWell(
                  onTap: () {
                    setState(() {
                      // isExpanded = !isExpanded;
                      provider.toggleAppBarExpansion(
                        !(provider.isAppBarExpanded),
                      );
                      borderRadius = (provider.isAppBarExpanded) ? 20 : 50;
                    });
                  },
                  child: Icon(
                    (provider.isAppBarExpanded)
                        ? Icons.close_rounded
                        : Icons.menu_rounded,
                    size: 32,
                    color: (provider.isAppBarExpanded)
                        ? Colors.blueAccent
                        : Colors.blue,
                  ),
                ),

                // to be fixed
              ],
            ),

            // this contains the menu options
            AnimatedOpacity(
              opacity: (provider.isAppBarExpanded) ? 1.0 : 0.0,
              curve: Curves.easeInOut,
              duration: Duration(milliseconds: animationDuration),
              child: MyMenuOptions(
                isVisible: provider.isAppBarExpanded,
                loggedInUserData: widget.loggedInUserData,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
