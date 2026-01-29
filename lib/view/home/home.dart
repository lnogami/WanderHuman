import 'package:flutter/material.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';
import 'package:wanderhuman_app/view/home/widgets/home_emergency_contacts_button.dart';
import 'package:wanderhuman_app/view/home/widgets/home_patient_list_dropdown.dart';
import 'package:wanderhuman_app/view/home_appbar/home_appbar.dart';
import 'package:wanderhuman_app/view/home/widgets/map/map_body.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // //pang full screen ra ni
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // // this will prevent the screen from sleeping.
    // WakelockPlus.enable();
  }

  @override
  void dispose() {
    // WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            // Map body
            Positioned(
              // child: Container()
              child: SizedBox(
                width: MyDimensionAdapter.getWidth(context),
                height: MyDimensionAdapter.getHeight(context),
                child: MapBody(),
                // child: MyMapBody(),
              ),
            ),

            // Emergency Contacts
            Positioned(
              top: MyDimensionAdapter.getHeight(context) * 0.12,
              left: 18,
              child: MyHomeEmergencyContactsButton(),
            ),

            // Dropdown
            Positioned(
              // top: MyDimensionAdapter.getHeight(context) * 0.18,
              top: MyDimensionAdapter.getHeight(context) * 0.12,
              right: 18,
              child: HomePatientListDropDown(),
            ),

            // Appbar
            Positioned(top: 20, child: HomeAppBar()),
          ],
        ),
      ),
    );
  }
}
