// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:provider/provider.dart';
import 'package:wanderhuman_app/helper/settings_repository.dart';
import 'package:wanderhuman_app/model/settings_model.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';
import 'package:wanderhuman_app/utilities/properties/text_formatter.dart';
import 'package:wanderhuman_app/view-model/home_settings_provider.dart';
import 'package:wanderhuman_app/view-model/my_mapbox_ref_provider.dart';
import 'package:wanderhuman_app/view/components/alert_dialogue.dart';
import 'package:wanderhuman_app/view/components/button.dart';
import 'package:wanderhuman_app/view/components/info_dialogue.dart';
import 'package:wanderhuman_app/view/components/lines.dart';
import 'package:wanderhuman_app/view/components/my_animated_snackbar.dart';
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
  bool? useDefaultAvatar;
  bool? previousAvatarPreference; // original value of useDefaultAvatar
  bool? enableAvatarDistanceAccuracy;

  @override
  void initState() {
    super.initState();
    // loadData(context);
  }

  @override
  Widget build(BuildContext context) {
    double width = MyDimensionAdapter.getWidth(context);
    double height = MyDimensionAdapter.getHeight(context);
    // Provider
    settingsProvider = context.watch<MyHomeSettingsProvider>();
    zoomLevel = settingsProvider.zoomLevel;
    previousZoomLevel ??= zoomLevel;
    alwaysFollowYourAvatar = settingsProvider.alwaysFollowYourAvatar;
    useDefaultAvatar = settingsProvider.useDefaultAvatar;
    previousAvatarPreference ??= useDefaultAvatar!;
    enableAvatarDistanceAccuracy =
        settingsProvider.enableAvatarDistanceAccuracy;

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
              SizedBox(height: 7),

              defaultAvatarSwitch(width),
              SizedBox(height: 7),

              enableAvatarDistanceAccuracySwitch(width),

              Spacer(),
              cancelAndSaveButtons(context),
              SizedBox(height: 15),
            ],
          ),
        ),
      ),
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
                  settingsProvider.setZoomLevel(previousZoomLevel!);
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
                      settingsProvider.setZoomLevel(value);
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
            message: (useDefaultAvatar!)
                ? "Your avatar is the blue dot that has no name above it. Off by default."
                : "Your avatar has your picture on it. Minimum of 20 meters distance to move.",
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
              settingsProvider.setAlwaysFollowYourAvatar(value);
            },
          ),
        ],
      ),
    );
  }

  Container defaultAvatarSwitch(double width) {
    return _myLayoutContainer(
      width: width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 5,
        children: [
          MyTextFormatter.p(text: "Use default avatar?"),
          MyCustTooltip(
            triggerMode: TooltipTriggerMode.tap,
            duration: 3000,
            heightConstraints: 75,
            message:
                "By default, your avatar is a blue circle. Has more visual features but less accurate.",
            child: Icon(
              Icons.info_outline_rounded,
              size: 20,
              color: Colors.grey.shade500,
            ),
          ),
          Spacer(),
          CupertinoSwitch(
            activeTrackColor: Colors.blue.shade400,
            value: useDefaultAvatar!,
            onChanged: (value) {
              settingsProvider.setToUseDefaultAvatar(value);

              if (!(useDefaultAvatar!)) {
                settingsProvider.setEnableAvatarDistanceAccuracy(false);
              } else {
                settingsProvider.setEnableAvatarDistanceAccuracy(value);
              }
            },
          ),
        ],
      ),
    );
  }

  Container enableAvatarDistanceAccuracySwitch(double width) {
    return _myLayoutContainer(
      width: width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 5,
        children: [
          MyTextFormatter.p(text: "Enable avatar accuracy?"),
          MyCustTooltip(
            triggerMode: TooltipTriggerMode.tap,
            duration: 3000,
            heightConstraints: 75,
            message:
                "This determines how accurate your location is. Automatically turned off when not using the default avatar.",
            child: Icon(
              Icons.info_outline_rounded,
              size: 20,
              color: Colors.grey.shade500,
            ),
          ),
          Spacer(),
          CupertinoSwitch(
            activeTrackColor: Colors.blue.shade400,
            value: enableAvatarDistanceAccuracy!,
            onChanged: (value) {
              if (useDefaultAvatar!) {
                settingsProvider.setEnableAvatarDistanceAccuracy(value);
              } else {
                showMyAnimatedSnackBar(
                  context: context,
                  dataToDisplay: "Use default avatar to enable this feature.",
                  bgColor: Colors.white,
                );
              }
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
              alertContent: (settingsProvider.useDefaultAvatar)
                  ? "Are you sure you want to save changes? \nNote: using the default avatar may have more visual features but less location accuracy (visually)."
                  : "Are you sure you want to save changes?",
              onApprovalPressed: () async {
                await MySettigsRepository.updateSettings(
                  settings: MySettingsModel(
                    userID: widget.loggedInUserID,
                    zoomLevel: zoomLevel!,
                    alwaysFollowYourAvatar: alwaysFollowYourAvatar!,
                    useDefaultAvatar: settingsProvider.useDefaultAvatar,
                    enableAvatarDistanceAccuracy:
                        settingsProvider.enableAvatarDistanceAccuracy,
                  ),
                );

                log(
                  "useDefaultAvatar: $useDefaultAvatar, previousAvatarPreference: $previousAvatarPreference",
                );

                if (useDefaultAvatar! == previousAvatarPreference) {
                  Navigator.pop(context);
                } else {
                  Navigator.pop(context);
                  myInfoDialogue(
                    context: context,
                    alertTitle: "Restart App",
                    alertContent: "To apply the recent changes.",
                    onPressText: "Restart",
                    onPress: () {
                      Phoenix.rebirth(context);
                    },
                  );
                }
              },
            );
          },
        ),
      ],
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
