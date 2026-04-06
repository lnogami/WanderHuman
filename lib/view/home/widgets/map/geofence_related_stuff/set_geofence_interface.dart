import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';
import 'package:wanderhuman_app/utilities/properties/text_formatter.dart';
import 'package:wanderhuman_app/view-model/home_geofence_config_provider.dart';
import 'package:wanderhuman_app/view-model/home_settings_provider.dart';
import 'package:wanderhuman_app/view/components/bottom_sheet.dart';
import 'package:wanderhuman_app/view/components/button.dart';
import 'package:wanderhuman_app/view/components/tooltip.dart';
import 'package:wanderhuman_app/view/home/widgets/map/geofence_related_stuff/view_geo/viewing_geofences_bottom_panel.dart';

class SetGeofence extends StatefulWidget {
  const SetGeofence({super.key});

  @override
  State<SetGeofence> createState() => _SetGeofenceState();
}

class _SetGeofenceState extends State<SetGeofence> {
  @override
  Widget build(BuildContext context) {
    MyHomeSettingsProvider settingsProvider = context
        .watch<MyHomeSettingsProvider>();

    return GestureDetector(
      onTap: () {
        _bottomPanelContents(context);
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 600),
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: (settingsProvider.minimizeHomePageButtons)
              ? BorderRadius.only(
                  topRight: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                )
              : null,
          color: (settingsProvider.minimizeHomePageButtons)
              ? Colors.white54
              : Colors.transparent,
        ),
        child: (settingsProvider.minimizeHomePageButtons)
            ? Icon(
                Icons.location_searching_rounded,
                color: Colors.grey.shade600,
                size: 28,
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_searching_rounded,
                    size: 32,
                    // color: Colors.blue.shade100,
                    color: Colors.grey.shade600,
                  ),
                  MyTextFormatter.p(
                    text: "Geofence",
                    fontsize: kDefaultFontSize - 4,
                    color: Colors.grey.shade700,
                  ),
                ],
              ),
      ),
    );
  }

  void _bottomPanelContents(BuildContext context) {
    return MyBottomPanel.showMyBottomPanel(
      context: context,
      child: SafeArea(
        child: Container(
          width: MyDimensionAdapter.getWidth(context),
          height: MyDimensionAdapter.getHeight(context) * 0.3,
          padding: EdgeInsets.only(top: 20),
          decoration: BoxDecoration(
            color: Colors.white70,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Column(
            children: [
              header(context),
              SizedBox(height: 25),
              MyCustButton(
                buttonText: "New Geofence",
                widthPercentage: 0.7,
                buttonTextColor: Colors.white,
                buttonTextFontWeight: FontWeight.w500,
                buttonTextFontSize: kDefaultFontSize + 2,
                onTap: () {
                  // this will make the bottom panel appear
                  context
                      .read<MyHomeGeofenceConfigurationProvider>()
                      .toggleGeofenceCreation(true);

                  Navigator.pop(context);
                },
              ),
              SizedBox(height: 10),
              MyCustButton(
                buttonText: "View Geofences",
                widthPercentage: 0.7,
                buttonTextColor: Colors.grey.shade600,
                buttonTextFontWeight: FontWeight.w500,
                buttonTextFontSize: kDefaultFontSize + 2,
                borderColor: Colors.transparent,
                height: 45,
                color: Colors.white24,
                enableShadow: false,
                onTap: () {
                  Navigator.pop(context);
                  MyBottomPanel.showMyBottomPanel(
                    context: context,
                    child: ViewingGeofencesBottomPanel(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  MyCustTooltip header(BuildContext context) {
    return MyCustTooltip(
      message: "Hello, World!",
      triggerMode: TooltipTriggerMode.tap,
      child: Container(
        width: MyDimensionAdapter.getWidth(context) * 0.9,
        height: 45,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.white30,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_searching_rounded,
              size: 32,
              color: Colors.blue.shade500,
            ),
            SizedBox(width: 10),
            MyTextFormatter.h3(text: "Geofence", color: Colors.grey.shade800),
          ],
        ),
      ),
    );
  }
}
