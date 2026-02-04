import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wanderhuman_app/helper/personal_info_repository.dart';
import 'package:wanderhuman_app/helper/realtime_temporary_test.dart';
import 'package:wanderhuman_app/model/personal_info.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';
import 'package:wanderhuman_app/view-model/home_appbar_provider.dart';
import 'package:wanderhuman_app/view/components/page_navigator.dart';
import 'package:wanderhuman_app/view/home/widgets/home_emergency_contacts_button.dart';
import 'package:wanderhuman_app/view/home/widgets/home_patient_list_dropdown.dart';
import 'package:wanderhuman_app/view/home/widgets/map/map_functions/active_status.dart';
import 'package:wanderhuman_app/view/home/widgets/set_geofence.dart';
import 'package:wanderhuman_app/view/home_appbar/home_appbar.dart';
import 'package:wanderhuman_app/view/home/widgets/map/map_body.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;

  // this will initialize the logged in user's personal info in the HomeAppBarProvider
  Future<void> initUserData() async {
    try {
      final String uid = FirebaseAuth.instance.currentUser!.uid;
      // Fetch the full object once to save reads
      PersonalInfo currentlyLoggedInUserData =
          await MyPersonalInfoRepository.getSpecificPersonalInfo(userID: uid);

      // using addPostFrameCallback ensures it doesn't conflict with the build cycle
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<HomeAppBarProvider>().initUserData(
          currentlyLoggedInUserData,
        );
        setState(() {
          isLoading = false;
        });
      });
    } catch (e, stackTrace) {
      log("ERROR FETCHING DATAAAAAA: $e. AT $stackTrace");
    }
  }

  @override
  void initState() {
    super.initState();
    initUserData();
    ActiveStatus.setupOnDisconnectStatus();
  }

  @override
  void dispose() {
    ActiveStatus.setActiveStatusToOffline();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: (isLoading)
            ? Center(child: CircularProgressIndicator())
            : Stack(
                alignment: Alignment.topCenter,
                children: [
                  // Map body
                  Positioned(
                    // child: Container()
                    child: SizedBox(
                      width: MyDimensionAdapter.getWidth(context),
                      height: MyDimensionAdapter.getHeight(context),
                      child: MapBody(
                        loggedInUserData: context
                            .watch<HomeAppBarProvider>()
                            .loggedInUserData,
                      ),
                      // child: MyMapBody(),
                    ),
                  ),

                  // Emergency Contacts
                  Positioned(
                    top: MyDimensionAdapter.getHeight(context) * 0.12,
                    left: 18,
                    child: MyHomeEmergencyContactsButton(),
                  ),

                  // Set Geofence
                  Positioned(
                    top: MyDimensionAdapter.getHeight(context) * 0.2,
                    left: 18,
                    child: SetGeofence(),
                  ),

                  // Temporary for testing realtime database only (deletable)
                  Positioned(
                    top: MyDimensionAdapter.getHeight(context) * 0.27,
                    left: 18,
                    child: IconButton(
                      onPressed: () {
                        MyNavigator.goTo(context, RealtimeTemporaryTest());
                      },
                      icon: Icon(
                        Icons.data_saver_on_rounded,
                        color: Colors.amber,
                        size: 32,
                      ),
                    ),
                  ),

                  // Dropdown
                  Positioned(
                    // top: MyDimensionAdapter.getHeight(context) * 0.18,
                    top: MyDimensionAdapter.getHeight(context) * 0.12,
                    right: 18,
                    child: HomePatientListDropDown(),
                  ),

                  // Appbar
                  Positioned(
                    top: 20,
                    child: HomeAppBar(
                      loggedInUserData: context
                          .watch<HomeAppBarProvider>()
                          .loggedInUserData,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
