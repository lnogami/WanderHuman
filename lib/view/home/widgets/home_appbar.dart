import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:wanderhuman_app/helper/firebase_services.dart';
import 'package:wanderhuman_app/model/firebase_patients.dart';
import 'package:wanderhuman_app/utilities/dimension_adapter.dart';
import 'package:wanderhuman_app/view/home/widgets/menu_options.dart';
import 'package:wanderhuman_app/view/home/widgets/utility_functions/my_animated_snackbar.dart';

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

  List<Patients> usersList = [];
  String userName = "User";

  // to fetch patients (users) from firestore through MyFirebaseServices
  // List<Patients> fetchedPatients() {
  //   List<Patients> patientsList =
  //       MyFirebaseServices.getAllPatients() as List<Patients>;
  //   return patientsList;
  // }

  //// TO BE CLEANED
  // FutureBuilder<List<Patients>>(
  //     future: MyFirebaseServices.getSpecificUserName(personsList: await MyFirebaseServices.getAllPatients(), userIDToLookFor: FirebaseAuth.instance.currentUser!.uid),
  //     builder: (context, snapshot) {
  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         return CircularProgressIndicator();
  //       } else if (snapshot.hasError) {
  //         return Text("Error: ${snapshot.error}");
  //       } else if (snapshot.hasData) {
  //         List<Patients> patients = snapshot.data!;
  //         return patients;
  //       } else {
  //         return Text("No data found");
  //       },
  //   ),

  // fetches all the users from firestore through MyFirebaseServices
  Future<void> fetchUsers() async {
    usersList = await MyFirebaseServices.getAllPatients();
    showMyAnimatedSnackBar(
      context: context,
      dataToDisplay: "Number of users ${usersList.length.toString()}",
    );
  }

  // to get the current user's name
  Future<void> fetchAndSetUsername() async {
    try {
      await fetchUsers();
      String name = MyFirebaseServices.getSpecificUserName(
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
    // if (userName != "") {
    //   print("✅✅✅✅✅ Fetched user name: $userName");
    // }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: animationDuration),
      width: MyDimensionAdapter.getWidth(context) * 0.80,
      height: (isExpanded) ? 220 : 50,
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
              CircleAvatar(
                backgroundColor: Colors.blue[100],
                child: Icon(Icons.person_rounded, color: Colors.blue),
              ),
              SizedBox(width: 10),
              // greeting text
              SizedBox(
                width: MyDimensionAdapter.getWidth(context) * 0.50,
                child: (userName == "User")
                    ? CircularProgressIndicator()
                    : Text(
                        // "${dotenv.env['SAMPLE_TEXT']}",
                        // "a dnbajbdjab ahbdhjabd ajbdhwbahw abdabhj",
                        userName,
                        style: TextStyle(
                          // color: Colors.,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),

                // FutureBuilder(
                //     future: fetchAndSetUsername(),
                //     builder: (context, snapshot) {
                //       if (snapshot.connectionState ==
                //           ConnectionState.waiting) {
                //         return CircularProgressIndicator();
                //       } else if (snapshot.hasError) {
                //         return Text("Error: ${snapshot.error}");
                //       } else if (snapshot.hasData) {
                //         return Text(userName);
                //       } else {
                //         return Text("No data found");
                //       }
                //     },
                //   ),
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
