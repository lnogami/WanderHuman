import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wanderhuman_app/helper/personal_info_repository.dart';
import 'package:wanderhuman_app/model/personal_info.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';
import 'package:wanderhuman_app/view-model/home_appbar_provider.dart';
import 'package:wanderhuman_app/view/components/image_displayer.dart';
import 'package:wanderhuman_app/view/home/widgets/appbar/menu_options.dart';
import 'package:wanderhuman_app/view/home/widgets/home_utility_functions/profile_picture_bottom_modal_sheet.dart';

class HomeAppBar extends StatefulWidget {
  const HomeAppBar({super.key});

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<HomeAppBar> {
  int animationDuration = 200;
  double animatedOpacity = 0.0;
  bool isExpanded = false;
  double borderRadius = 50;

  // pang cache sa user (patient) list
  List<PersonalInfo> usersList = [];
  String userName = "User";

  // fetches all the users from firestore through MyFirebaseServices
  Future<void> fetchUsers() async {
    usersList = await MyPersonalInfoRepository.getAllPersonalInfoRecords();
  }

  // to get the current user's name and UPDATE the userName variable's state
  Future<void> fetchAndSetUsername() async {
    try {
      await fetchUsers();
      String name =
          MyPersonalInfoRepository.getSpecificUserNameOfTheLoggedInAccount(
            personsList: usersList,
            userIDToLookFor: FirebaseAuth.instance.currentUser!.uid,
          );
      setState(() {
        userName = name;
      });
    } catch (e) {
      print("❌❌❌ Error fetching user name: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAndSetUsername();

    // using addPostFrameCallback ensures it doesn't conflict with the build cycle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeAppBarProvider>().initUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeAppBarProvider>();

    return AnimatedContainer(
      duration: Duration(milliseconds: animationDuration),
      width: MyDimensionAdapter.getWidth(context) * 0.80,
      height: (isExpanded)
          // might be back later (still deciding)
          ? (MyPersonalInfoRepository.getUserType() == "admin")
                // ? 290
                // : 220
                ? 220
                : 220
          : 50,
      decoration: BoxDecoration(
        color: (isExpanded)
            ? const Color.fromARGB(210, 255, 255, 255)
            : Colors.white70,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(borderRadius),
          topRight: Radius.circular(borderRadius),
          bottomLeft: Radius.circular(borderRadius),
          bottomRight: Radius.circular(borderRadius),
        ),
      ),
      padding: EdgeInsets.only(left: 8, right: 10, top: 5, bottom: 5),
      child: Column(
        children: [
          Row(
            children: [
              // the user avatar/pic/icon container
              GestureDetector(
                onTap: () {
                  showProfilePictureBottomModalSheet(context);
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
                child: (userName == "...")
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
                    isExpanded = !isExpanded;
                    borderRadius = (isExpanded) ? 20 : 50;
                  });
                },
                child: Icon(
                  (isExpanded) ? Icons.close_rounded : Icons.menu_rounded,
                  size: 32,
                  color: (isExpanded) ? Colors.blueAccent : Colors.blue,
                ),
              ),

              // to be fixed
            ],
          ),
          // this contains the menu options
          AnimatedOpacity(
            opacity: (isExpanded) ? 1.0 : 0.0,
            curve: Curves.easeInOut,
            duration: Duration(milliseconds: animationDuration),
            child: MyMenuOptions(isVisible: isExpanded),
          ),
        ],
      ),
    );
  }
}
