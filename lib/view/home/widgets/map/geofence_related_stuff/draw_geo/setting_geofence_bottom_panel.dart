import 'dart:math';

import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:wanderhuman_app/utilities/properties/color_palette.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';
import 'package:wanderhuman_app/utilities/properties/text_formatter.dart';
import 'package:wanderhuman_app/view-model/home_geofence_config_provider.dart';
import 'package:wanderhuman_app/view-model/my_mapbox_ref_provider.dart';
import 'package:wanderhuman_app/view/components/alert_dialogue.dart';
import 'package:wanderhuman_app/view/home/widgets/map/geofence_related_stuff/draw_geo/map_geofence_drawer.dart';
import 'package:wanderhuman_app/view/home/widgets/map/map_functions/fly_to.dart';

class SettingGeofenceBottomPanel extends StatefulWidget {
  const SettingGeofenceBottomPanel({super.key});

  @override
  State<SettingGeofenceBottomPanel> createState() =>
      _SettingGeofenceBottomPanelState();
}

class _SettingGeofenceBottomPanelState
    extends State<SettingGeofenceBottomPanel> {
  // List<String> sampleTexts = ["Hello", "World!", "Hi", "Hi", "Are", "You?"];
  // List<Widget> sampleTexts = [
  //   // _myCustContainer(Text("Hello")),
  //   // _myCustContainer(Text("World!")),
  //   // _myCustContainer(Text("Hi")),)
  //   Text("Hello"),
  //   Text("World!"),
  //   Text("Hi"),
  //   Text("Are"),
  //   Text("You?"),
  //   Text("World!"),
  // ];

  int selectedIndex = 0;
  List<Position>? listOfPositions;

  MapboxMap? mapboxMapRef;
  late FixedExtentScrollController scrollController;
  late double width;

  // this is for when the points for the polygon have already been marked, and now we need to add the center point.
  bool isAboutToAddCenterPoint = false;

  @override
  void initState() {
    super.initState();
    // // TODO: to be change to call the actual source, the repository
    // listOfPositions = MyMapGeofence.customShapePoints[0];
    // listOfPositions = MyMapGeofence.listOfMarkedPositions[0];
    listOfPositions = context
        .read<MyHomeGeofenceConfigurationProvider>()
        .listOfMarkedPositions[0];
    scrollController = FixedExtentScrollController(
      initialItem: selectedIndex,
      keepScrollOffset: true,
    );
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    width = MyDimensionAdapter.getWidth(context);
    mapboxMapRef = context.read<MyMapboxRefProvider>().getMapboxMapController;
    isAboutToAddCenterPoint = context
        .watch<MyHomeGeofenceConfigurationProvider>()
        .isAboutToAddCenterPoint;

    return (listOfPositions!.isNotEmpty)
        ? Stack(
            alignment: Alignment.center,
            children: [
              if (!isAboutToAddCenterPoint)
                Positioned(
                  left: 10,
                  child: Container(
                    width: width,
                    height: MyDimensionAdapter.getHeight(context) * 0.25,
                    // padding: EdgeInsets.only(right: 30),
                    padding: EdgeInsets.only(right: width * 0.125),
                    // color: Colors.amber,
                    child: RawScrollbar(
                      radius: Radius.circular(50),
                      interactive: false,
                      thumbVisibility: true,
                      trackVisibility: true,
                      trackColor: Colors.grey.shade300,
                      thumbColor: Colors.blue.shade200,
                      thickness: 5,
                      // padding: EdgeInsets.only(right: -20, top: 5, bottom: 5),
                      padding: EdgeInsets.only(
                        right: (width * -0.095),
                        top: 5,
                        bottom: 5,
                      ),
                      controller: scrollController,
                      child: ListWheelScrollView(
                        // key: ValueKey(listOfPositions!.length),
                        perspective: 0.005,
                        controller: scrollController,
                        // squeeze: 2,
                        // useMagnifier: true,
                        // offAxisFraction: 1,
                        // perspective: RenderListWheelViewport.,
                        diameterRatio: 1.3,
                        itemExtent: MyDimensionAdapter.getHeight(context) * 0.1,
                        onSelectedItemChanged: (value) {
                          // setState(() {
                          selectedIndex = value;
                          // });
                          dev.log("VALUEEEE: $value");
                          dev.log("SELECTED ITEMMMM: $selectedIndex");
                          if (listOfPositions!.isNotEmpty) {
                            myMapFlyTo(
                              mapboxController: mapboxMapRef!,
                              position: listOfPositions![value],
                            );
                          }
                        },
                        children: myIterator(),
                      ),
                    ),
                  ),
                ),

              // This is the blue button for deleting the selected coordinate, it will show an alert dialogue for confirmation before deleting the coordinate
              if (!isAboutToAddCenterPoint)
                Positioned(
                  right: 5,
                  top: MyDimensionAdapter.getHeight(context) * 0.07,
                  child: GestureDetector(
                    onTap: () {
                      myAlertDialogue(
                        context: context,
                        alertTitle: "Remove Coordinates",
                        alertContent:
                            "Are you sure you want to remove this coordinate?",
                        onApprovalPressed: () {
                          dev.log(
                            "List of Positions Length: ${listOfPositions!.length}",
                          );

                          // This will remove the marked position at the selected index from the Provider
                          context
                              .read<MyHomeGeofenceConfigurationProvider>()
                              .removeMarkedAnnotationPositionAt(selectedIndex);

                          setState(() {
                            listOfPositions!.removeAt(selectedIndex);
                            // to safely handle the index out of range error before scrolling to child
                            if (selectedIndex >= listOfPositions!.length) {
                              selectedIndex = listOfPositions!.length - 1;
                            }
                            scrollToChild(selectedIndex);
                          });

                          dev.log(
                            "List of Positions Length: ${listOfPositions!.length}",
                          );

                          // Remove the alert dialog
                          Navigator.pop(context);

                          // This will redraw the polygon with the updated list of positions after deleting the selected coordinate
                          MyMapGeofenceDrawer.drawPolygon(
                            polygonManager: context
                                .read<MyHomeGeofenceConfigurationProvider>()
                                .markedPolygonAnnotationManager!,
                            positions: context
                                .read<MyHomeGeofenceConfigurationProvider>()
                                .listOfMarkedPositions,
                          );

                          dev.log(
                            "Successfully removed coordinate at $selectedIndex",
                          );
                        },
                      );
                    },
                    child: SizedBox(
                      // color: Colors.amber,
                      width: 55,
                      height: 55,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Transform.rotate(
                            angle: pi / 180 * 65,
                            origin: Offset(0, 0),
                            child: Icon(
                              Icons.location_on_rounded,
                              size: 56,
                              color: Colors.blue,
                            ),
                          ),
                          Positioned(
                            top: 17.5,
                            right: 15.5,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: Colors.white,
                              ),
                              child: Icon(Icons.close, size: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              if (isAboutToAddCenterPoint)
                // if there is no centerPoint yet, display this text, otherwise, display the actual coordinates
                (context
                            .read<MyHomeGeofenceConfigurationProvider>()
                            .centerPoint ==
                        null)
                    ? dialogVisibleDuringCenterPointMarking()
                    : _myCustomContainer(
                        context
                            .read<MyHomeGeofenceConfigurationProvider>()
                            .centerPoint!,
                        isPadded: true,
                      ),
            ],
          )
        : Center(
            child: MyTextFormatter.p(
              text: "No Coordinates Set",
              fontWeight: FontWeight.w500,
              fontsize: kDefaultFontSize + 2,
              color: Colors.grey.shade700,
            ),
          );
  }

  Padding dialogVisibleDuringCenterPointMarking() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyTextFormatter.p(
            text:
                "Tap INSIDE the previously added safezone to add center point.",
            maxLines: 5,
            color: Colors.blue.shade600,
            fontWeight: FontWeight.w600,
            fontsize: kDefaultFontSize + 2,
          ),
          SizedBox(height: 20),
          MyTextFormatter.p(
            text: "WARNING NOTICE:",
            maxLines: 5,
            color: Colors.grey.shade800,
            fontWeight: FontWeight.w600,
            fontsize: kDefaultFontSize + 2,
          ),
          MyTextFormatter.p(
            text: "DO NOT MARK OUTSIDE THE SAFEZONE.",
            maxLines: 5,
            color: const Color.fromARGB(255, 173, 47, 37),
            fontWeight: FontWeight.w600,
            fontsize: kDefaultFontSize + 2,
          ),
        ],
      ),
    );
  }

  // this will make the listview to scroll to the selected index
  void scrollToChild(int index) {
    scrollController.animateToItem(
      // selectedIndex,
      index,
      duration: Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
    );
  }

  // this is responsible for
  List<Widget> myIterator() {
    if (listOfPositions!.isEmpty) return [];
    // int length = MyMapGeofence.customShapePoints.length;
    List<Widget> widgets = <Widget>[];
    for (var position in listOfPositions!) {
      widgets.add(_myCustomContainer(position));
    }
    return widgets;
  }

  // containers for the ListWheelScrollView childred, the UI
  Container _myCustomContainer(Position postion, {bool isPadded = false}) {
    return Container(
      width: MyDimensionAdapter.getWidth(context) * 0.8,
      height: MyDimensionAdapter.getHeight(context) * ((isPadded) ? 0.15 : 25),
      margin: EdgeInsets.only(top: 5),
      decoration: BoxDecoration(
        color: Colors.white70,
        borderRadius: BorderRadius.circular(7),
        border: BoxBorder.all(color: MyColorPalette.formColor, width: 1.5),
      ),
      // child: SizedBox(height: 100, child: child),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Spacer(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              MyTextFormatter.p(text: "Longhitude: "),
              MyTextFormatter.p(text: "Latitude: "),
            ],
          ),
          SizedBox(width: 4.0),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyTextFormatter.p(
                text: "${postion.lng}",
                color: Colors.blue.shade500,
                fontWeight: FontWeight.w600,
              ),
              MyTextFormatter.p(
                text: "${postion.lat}",
                color: Colors.blue.shade500,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
          Spacer(),
        ],
      ),
    );
  }
}
