import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wanderhuman_app/helper/personal_info_repository.dart';
import 'package:wanderhuman_app/model/personal_info.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';
import 'package:wanderhuman_app/view/components/appbar.dart';
import 'package:wanderhuman_app/view/components/cards.dart';
import 'package:wanderhuman_app/view/components/page_navigator.dart';
import 'package:wanderhuman_app/view/userRolesUI/admin/add_staff_form.dart';
import 'package:wanderhuman_app/view/userRolesUI/admin/view_staff_form.dart';

class ManageStaff extends StatelessWidget {
  const ManageStaff({super.key});
  // final List<String> staffNames = const ["Hori", "Verti", "Diago", "Dimensio"];

  Future<List<PersonalInfo>> getStaff() async {
    List<PersonalInfo> staffs = [];
    List<PersonalInfo> fetchedRecords =
        await MyPersonalInfoRepository.getAllPersonalInfoRecords();
    for (var person in fetchedRecords) {
      if (person.userType != "Patient") {
        staffs.add(person);
      }
    }

    return staffs;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 227, 237, 250),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          FutureBuilder(
            future: getStaff(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Container(
                  width: MyDimensionAdapter.getWidth(context),
                  height: MyDimensionAdapter.getHeight(context),
                  padding: EdgeInsets.only(
                    top: kToolbarHeight + 20,
                    bottom: 56,
                    left: 20,
                    right: 20,
                  ),
                  // color: const Color.fromARGB(255, 227, 237, 250),
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return MyCardInfoDisplayer(
                        profilePicture: snapshot.data![index].picture,
                        name: snapshot.data![index].name,
                        role: snapshot.data![index].userType,
                        contactNumber: snapshot.data![index].contactNumber,
                        emailAdd: snapshot.data![index].email,
                        onTap: () {
                          MyNavigator.goTo(
                            context,
                            ViewStaffForm(
                              staffPersonalInfo: snapshot.data![index],
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),

          Positioned(
            top: kToolbarHeight * 0.7,
            child: MyCustAppBar(
              title: "Manage Staff",
              backButton: () {
                Navigator.pop(context);
              },
              actionButtons: [
                IconButton(
                  highlightColor: Colors.blue.shade100,
                  onPressed: () async {
                    MyNavigator.goTo(
                      // ignore: use_build_context_synchronously
                      context,
                      AddStaffForm(bufferedStaffNames: await getStaff()),
                    );
                  },
                  icon: Icon(
                    Icons.person_add_alt_1_rounded,
                    color: Colors.blue.shade400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
