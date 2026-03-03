import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wanderhuman_app/helper/settings_repository.dart';
import 'package:wanderhuman_app/model/settings_model.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';
import 'package:wanderhuman_app/utilities/properties/text_formatter.dart';
import 'package:wanderhuman_app/view-model/home_settings_provider.dart';
import 'package:wanderhuman_app/view-model/my_mapbox_ref_provider.dart';
import 'package:wanderhuman_app/view/components/alert_dialogue.dart';
import 'package:wanderhuman_app/view/components/button.dart';
import 'package:wanderhuman_app/view/components/lines.dart';
import 'package:wanderhuman_app/view/components/tooltip.dart';
import 'package:wanderhuman_app/view/home/widgets/map/map_functions/map_camera_animations.dart';

class MySettingsInterface extends StatefulWidget {
  final String loggedInUserID;
  const MySettingsInterface({super.key, required this.loggedInUserID});

  @override
  State<MySettingsInterface> createState() => _MySettingsInterfaceState();
}

class _MySettingsInterfaceState extends State<MySettingsInterface> {
  late MyHomeSettingsProvider settingsProvider;
  // bool isLoadingData = true;
  late MySettingsModel settings;
  // This will hold the loaded data from the database
  double? previousZoomLevel;
  // While this one will hold the changes made by the user before saving to database
  double? zoomLevel;
  //
  bool? alwaysFollowYourAvatar;

  // Future<void> loadData(BuildContext context) async {
  //   // bool isSettingsForThisUserIsAvailable =
  //   //     await MySettigsRepository.doesSettingsForThisUserExist(
  //   //       userID: widget.loggedInUserID,
  //   //     );

  //   // // if there is no settings yet for this user, create one
  //   // if (!isSettingsForThisUserIsAvailable) {
  //   //   var tempSettings = MySettingsModel(
  //   //     userID: widget.loggedInUserID,
  //   //     zoomLevel: 16.0,
  //   //     alwaysFollowYourAvatar: true,
  //   //   );

  //   //   await MySettigsRepository.addSettings(settings: tempSettings);

  //   //   setState(() => settings = tempSettings);
  //   // }

  //   // // else, fetch the settings for this user
  //   // else {
  //   //   settings = await MySettigsRepository.getSettingsOfTheUser(
  //   //     userID: widget.loggedInUserID,
  //   //   );
  //   // }

  //   // zoomLevel = settings.zoomLevel;
  //   // previousZoomLevel = zoomLevel;

  //   setState(() => isLoadingData = false);
  // }

  @override
  void initState() {
    super.initState();
    // loadData(context);
  }

  @override
  Widget build(BuildContext context) {
    double width = MyDimensionAdapter.getWidth(context);
    double height = MyDimensionAdapter.getHeight(context);
    // MyHomeSettingsProvider object reference
    settingsProvider = context.watch<MyHomeSettingsProvider>();
    zoomLevel = settingsProvider.zoomLevel;
    previousZoomLevel ??= zoomLevel;
    alwaysFollowYourAvatar = settingsProvider.alwaysFollowYourAvatar;

    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          width: width,
          height: height * 0.56,
          padding: EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white70,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              MyLine(
                length: width * 0.3,
                isVertical: false,
                isRounded: true,
                thickness: 5,
                margin: 10,
              ),
              SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 3,
                children: [
                  Icon(
                    Icons.settings_outlined,
                    size: 36,
                    color: const Color.fromARGB(224, 30, 136, 229),
                  ),
                  MyTextFormatter.p(
                    text: "Settings",
                    fontWeight: FontWeight.w600,
                    fontsize: kDefaultFontSize + 10,
                    color: Colors.grey.shade700,
                  ),
                ],
              ),
              SizedBox(height: 30),

              myMapZoomSlider(width, context, height),
              SizedBox(height: 7),

              followMyMapAvatarSwitch(width),

              Spacer(),
              cancelAndSaveButtons(context),
              SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

  Container followMyMapAvatarSwitch(double width) {
    return _myLayoutContainer(
      width: width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 5,
        children: [
          MyTextFormatter.p(text: "Always Follow Your Avatar?"),
          MyCustTooltip(
            triggerMode: TooltipTriggerMode.tap,
            duration: 2500,
            message:
                "Your avatar is the blue dot that has no name above it. Off by default.",
            child: Icon(
              Icons.info_outline_rounded,
              size: 20,
              color: Colors.grey.shade500,
            ),
          ),
          Spacer(),
          CupertinoSwitch(
            activeTrackColor: Colors.blue.shade400,
            value: alwaysFollowYourAvatar!,
            onChanged: (value) {
              // setState(() => alwaysFollowYourAvatar = value);
              settingsProvider.setAlwaysFollowYourAvatar(value);
            },
          ),
        ],
      ),
    );
  }

  Row cancelAndSaveButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        MyCustButton(
          buttonText: "Cancel",
          widthPercentage: 0.30,
          color: Colors.transparent,
          borderColor: Colors.transparent,
          enableShadow: false,
          buttonTextSpacing: 1.2,
          height: 40,
          onTap: () {
            Navigator.pop(context);
          },
        ),
        MyCustButton(
          buttonText: "Save Changes",
          widthPercentage: 0.40,
          buttonTextColor: Colors.white,
          buttonTextSpacing: 1.2,
          buttonTextFontWeight: FontWeight.w600,
          height: 40,
          onTap: () {
            myAlertDialogue(
              context: context,
              alertTitle: "Save Changes",
              alertContent: "Are you sure you want to save changes?",
              onApprovalPressed: () async {
                await MySettigsRepository.updateSettings(
                  settings: MySettingsModel(
                    userID: widget.loggedInUserID,
                    zoomLevel: zoomLevel!,
                    alwaysFollowYourAvatar: alwaysFollowYourAvatar!,
                  ),
                );
                Navigator.pop(context);
              },
            );
          },
        ),
      ],
    );
  }

  Container myMapZoomSlider(double width, BuildContext context, double height) {
    return _myLayoutContainer(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              MyTextFormatter.p(
                text: "Map Zoom Level:  ",
                fontsize: kDefaultFontSize - 2,
              ),
              MyTextFormatter.p(
                text: "${context.read<MyHomeSettingsProvider>().zoomLevel}",
                fontsize: kDefaultFontSize,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
              Spacer(),
              // Revert icon
              GestureDetector(
                onTap: () {
                  // Revert to default zoom level
                  context.read<MyHomeSettingsProvider>().setZoomLevel(
                    previousZoomLevel!,
                  );
                  setState(() => zoomLevel = previousZoomLevel!);
                  MyMapCameraAnimations.myMapZoom(
                    mapboxController: context
                        .read<MyMapboxRefProvider>()
                        .getMapboxMapController!,
                    zoomLevel: zoomLevel!,
                  );
                },
                child: Icon(
                  Icons.rotate_left_rounded,
                  size: 24,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: 5,
            children: [
              Icon(Icons.zoom_out, size: 22, color: Colors.grey.shade700),
              Expanded(
                child: SizedBox(
                  // width: width * 0.6,
                  height: height * 0.05,
                  child: CupertinoSlider(
                    min: 0.0,
                    max: 20.0,
                    divisions: 20,
                    value: zoomLevel!,
                    onChanged: (value) {
                      // setState(() => zoomLevel = value);
                      // setState(() {
                      // zoomLevel = value;
                      context.read<MyHomeSettingsProvider>().setZoomLevel(
                        value,
                      );
                      // });

                      MyMapCameraAnimations.myMapZoom(
                        mapboxController: context
                            .read<MyMapboxRefProvider>()
                            .getMapboxMapController!,
                        zoomLevel: value,
                      );
                    },
                  ),
                ),
              ),
              Icon(Icons.zoom_in, size: 28, color: Colors.grey.shade700),
            ],
          ),
        ],
      ),
    );
  }

  // generic layouter container
  Container _myLayoutContainer({required double width, required Widget child}) {
    return Container(
      width: width,
      padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: Colors.white70, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade400,
            offset: Offset(0, 2),
            blurRadius: 4,
            blurStyle: BlurStyle.outer,
          ),
        ],
      ),
      child: child,
    );
  }
}
