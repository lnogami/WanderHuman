import 'dart:math';

import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:wanderhuman_app/utilities/properties/color_palette.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';
import 'package:wanderhuman_app/utilities/properties/text_formatter.dart';
import 'package:wanderhuman_app/view-model/my_mapbox_ref_provider.dart';
import 'package:wanderhuman_app/view/components/alert_dialogue.dart';
import 'package:wanderhuman_app/view/home/widgets/map/geofence_related_stuff/map_geofence.dart';
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

  @override
  void initState() {
    super.initState();
    // TODO: to be change to call the actual source, the repository
    listOfPositions = MyMapGeofence.customShapePoints[0];
    scrollController = FixedExtentScrollController(initialItem: selectedIndex);
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

    return (listOfPositions!.isNotEmpty)
        ? Stack(
            alignment: Alignment.center,
            children: [
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
                        myMapFlyTo(
                          mapboxController: mapboxMapRef!,
                          position: listOfPositions![value],
                        );
                      },
                      // children: [
                      // _myCustomContainer(Text("Hello")),
                      // _myCustomContainer(Text("World!")),
                      // _myCustomContainer(Text("Hi")),
                      // _myCustomContainer(Text("Are")),
                      // _myCustomContainer(Text("You?")),
                      // _myCustomContainer(Text("World!")),
                      // ],
                      children: myIterator(),
                    ),
                  ),
                ),
              ),

              //(deletable)
              // Positioned(
              //   left: -10,
              //   child: Transform.rotate(
              //     angle: -pi / 180 * 90,
              //     origin: Offset(0, 0),
              //     // child: Container(width: 100, height: 100, color: Colors.blue),
              //     child: Icon(
              //       Icons.location_on_rounded,
              //       size: 56,
              //       color: Colors.blue,
              //     ),
              //   ),
              // ),
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

                        setState(() {
                          listOfPositions!.removeAt(selectedIndex);

                          // to safely handle the index out of range error
                          if (selectedIndex >= listOfPositions!.length) {
                            selectedIndex = listOfPositions!.length - 1;
                          }
                          scrollToChild(selectedIndex);
                        });

                        dev.log(
                          "List of Positions Length: ${listOfPositions!.length}",
                        );
                        Navigator.pop(context);
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

  // this will make the listview to scroll to the selected index
  void scrollToChild(int index) {
    scrollController.animateToItem(
      selectedIndex,
      duration: Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
    );
  }

  // this is responsible for
  List<Widget> myIterator() {
    // int length = MyMapGeofence.customShapePoints.length;
    List<Widget> widgets = <Widget>[];
    for (var position in listOfPositions!) {
      widgets.add(_myCustomContainer(position));
    }
    return widgets;
  }

  // containers for the ListWheelScrollView childred, the UI
  Container _myCustomContainer(Position postion) {
    return Container(
      width: MyDimensionAdapter.getWidth(context) * 0.8,
      height: MyDimensionAdapter.getHeight(context) * 0.25,
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
