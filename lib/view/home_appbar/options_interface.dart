import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';
import 'package:wanderhuman_app/utilities/properties/text_formatter.dart';
import 'package:wanderhuman_app/view-model/home_settings_provider.dart';
import 'package:wanderhuman_app/view-model/my_mapbox_ref_provider.dart';
import 'package:wanderhuman_app/view/components/lines.dart';
import 'package:wanderhuman_app/view/home/widgets/map/map_functions/map_camera_animations.dart';

class MyOptionsInterface extends StatefulWidget {
  const MyOptionsInterface({super.key});

  @override
  State<MyOptionsInterface> createState() => _MyOptionsInterfaceState();
}

class _MyOptionsInterfaceState extends State<MyOptionsInterface> {
  double zoomLevel = 15.0;

  @override
  Widget build(BuildContext context) {
    double width = MyDimensionAdapter.getWidth(context);
    double height = MyDimensionAdapter.getHeight(context);
    zoomLevel = context.read<MyHomeSettingsProvider>().zoomLevel;

    return Container(
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
                color: Colors.blue.shade700,
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
        ],
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
                text: "${zoomLevel.toInt()}",
                fontsize: kDefaultFontSize,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
              Spacer(),
              GestureDetector(
                onTap: () {
                  // Revert to default zoom level
                  setState(() => zoomLevel = 15.0);
                  context.read<MyHomeSettingsProvider>().setZoomLevel(
                    zoomLevel,
                  );
                  MyMapCameraAnimations.myMapZoom(
                    mapboxController: context
                        .read<MyMapboxRefProvider>()
                        .getMapboxMapController!,
                    zoomLevel: zoomLevel,
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
          SizedBox(
            width: width,
            height: height * 0.05,
            child: CupertinoSlider(
              min: 0.0,
              max: 20.0,
              divisions: 20,
              value: zoomLevel,
              onChanged: (value) {
                // setState(() => zoomLevel = value);
                setState(() {
                  context.read<MyHomeSettingsProvider>().setZoomLevel(value);
                });

                MyMapCameraAnimations.myMapZoom(
                  mapboxController: context
                      .read<MyMapboxRefProvider>()
                      .getMapboxMapController!,
                  zoomLevel: value,
                );
              },
            ),
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
