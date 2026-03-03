import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wanderhuman_app/helper/personal_info_repository.dart';
import 'package:wanderhuman_app/model/personal_info.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';
import 'package:wanderhuman_app/utilities/properties/text_formatter.dart';
import 'package:wanderhuman_app/view/components/appbar.dart';
import 'package:wanderhuman_app/view/components/page_navigator.dart';
import 'package:wanderhuman_app/view/userRolesUI/admin/add_staff_form.dart';
import 'package:wanderhuman_app/view/components/card_admin_social_service_role.dart';
import 'package:wanderhuman_app/view/userRolesUI/admin/view_staff_form.dart';

class ManageStaff extends StatefulWidget {
  const ManageStaff({super.key});

  @override
  State<ManageStaff> createState() => _ManageStaffState();
}

class _ManageStaffState extends State<ManageStaff> {
  // final List<String> staffNames = const ["Hori", "Verti", "Diago", "Dimensio"];
  final List<PersonalInfo> staffs = [];
  final List<PersonalInfo> staffWithNoRoles = [];

  bool isLoading = true;

  Future<List<PersonalInfo>> getStaff() async {
    if (staffWithNoRoles.isNotEmpty) staffWithNoRoles.clear();
    if (staffs.isNotEmpty) staffs.clear();

    List<PersonalInfo> fetchedRecords =
        await MyPersonalInfoRepository.getAllPersonalInfoRecords();
    for (var person in fetchedRecords) {
      if (person.userType == "No Role") {
        staffWithNoRoles.add(person);
      } else if (person.userType != "Patient") {
        staffs.add(person);
      }
    }

    staffWithNoRoles.sort((a, b) => a.name.compareTo(b.name));
    setState(() => isLoading = false);
    staffs.sort((a, b) => a.name.compareTo(b.name));

    return staffs;
  }

  @override
  void initState() {
    super.initState();
    getStaff();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 227, 237, 250),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          // FutureBuilder(
          //   future: getStaff(),
          //   builder: (context, snapshot) {
          //     if (snapshot.connectionState == ConnectionState.done) {
          //       return
          (isLoading)
              ? Center(child: CircularProgressIndicator.adaptive())
              : Container(
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
                    itemCount: staffs.length,
                    itemBuilder: (context, index) {
                      return MyAdminSocialServiceCardInfoDisplayer(
                        personalInfo: staffs[index],
                        onTap: () {
                          MyNavigator.goTo(
                            context,
                            ViewStaffForm(staffPersonalInfo: staffs[index]),
                          );
                        },
                      );
                    },
                  ),
                ),

          //     } else {
          //       return Center(child: CircularProgressIndicator());
          //     }
          //   },
          // ),
          Positioned(
            // top: kToolbarHeight * 0.7, // (deletable)
            child: SafeArea(
              child: MyCustAppBar(
                title: "Manage Staff",
                backButton: () {
                  Navigator.pop(context);
                },
                actionButtons: [
                  (isLoading)
                      ? Center(child: CircularProgressIndicator.adaptive())
                      : Stack(
                          alignment: Alignment.center,
                          children: [
                            // Positioned(
                            //   top: 3,
                            //   right: 3,
                            //   child: Icon(
                            //     Icons.circle_notifications_rounded,
                            //     color: Colors.blue.shade400,
                            //     size: 16,
                            //   ),
                            // ),
                            Positioned(
                              top: 3,
                              right: 3,
                              child: (staffWithNoRoles.isEmpty)
                                  ? SizedBox()
                                  : CircleAvatar(
                                      radius: 8,
                                      backgroundColor: Colors.blue.shade400,
                                      child: FittedBox(
                                        child: MyTextFormatter.h3(
                                          text: staffWithNoRoles.length
                                              .toString(),
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                            ),
                            IconButton(
                              highlightColor: Colors.blue.shade100,
                              onPressed: () async {
                                MyNavigator.goTo(
                                  // ignore: use_build_context_synchronously
                                  context,
                                  AddStaffForm(
                                    bufferedStaffNames: staffWithNoRoles,
                                  ),
                                );
                              },
                              icon: Icon(
                                Icons.person_add_alt_1_rounded,
                                color: Colors.blue.shade400,
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
