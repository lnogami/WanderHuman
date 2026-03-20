import 'package:flutter/material.dart';
import 'package:wanderhuman_app/model/history_model.dart';
import 'package:wanderhuman_app/utilities/properties/date_formatter.dart';
import 'package:wanderhuman_app/utilities/properties/text_formatter.dart';
import 'package:wanderhuman_app/view/components/lines.dart';

class MyStaticMiniMapCard extends StatefulWidget {
  final double width;
  final double height;
  final MyHistoryModel history;
  const MyStaticMiniMapCard({
    super.key,
    required this.width,
    required this.height,
    required this.history,
  });

  @override
  State<MyStaticMiniMapCard> createState() => _MyStaticMiniMapStateCard();
}

class _MyStaticMiniMapStateCard extends State<MyStaticMiniMapCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width * 0.80,
      height: widget.height * 0.25,
      margin: EdgeInsets.only(top: 5, bottom: 5, left: 30, right: 30),
      decoration: BoxDecoration(
        color: Colors.white70,
        borderRadius: BorderRadius.circular(10),
        border: BoxBorder.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(56, 96, 181, 252),
            blurRadius: 4,
            // spreadRadius: 1,
            offset: Offset(0, 2),
            // blurStyle: BlurStyle.outer,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: widget.height * 0.045,
            // color: Colors.amber,
            margin: EdgeInsets.only(top: 5, left: 10, right: 10),
            child: Row(
              children: [
                MyTextFormatter.p(
                  text: (widget.history.isInSafeZone)
                      ? "In Danger"
                      : "Outside Safe Zone",
                ),
                Spacer(),
                MyLine(
                  length: widget.height * 0.035,
                  thickness: 1,
                  margin: 7,
                  isRounded: true,
                ),
                Column(
                  children: [
                    MyTextFormatter.p(
                      text: MyDateFormatter.formatDate(
                        dateTimeInString: widget.history.timeStamp,
                      ),
                      fontsize: kDefaultFontSize - 2,
                    ),

                    MyTextFormatter.p(
                      text: MyDateFormatter.formatDate(
                        dateTimeInString: widget.history.timeStamp,
                        formatOptions: 7,
                        customedFormat: "(EEE) hh:mm a",
                      ),
                      fontsize: kDefaultFontSize - 4,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// String getStaticMapWithHistoryUrl({
//   required List<mp.Position> history, // The last 5-10 locations
//   int width = 600,
//   int height = 400,
// }) {
//   final String accessToken = dotenv.env['MAPBOX_ACCESS_TOKEN']!;
//  
//   // 1. Convert your list of positions into the "lng,lat;lng,lat" format
//   String pathCoordinates = history
//       .map((pos) => "${pos.lng},${pos.lat}")
//       .join(";");
//
//   // 2. Define the look of the path (Red line, 5px wide, 80% opaque)
//   String pathParam = "path-5+f44336-0.8($pathCoordinates)";
//
//   // 3. Add a marker for the CURRENT (last) position
//   mp.Position current = history.last;
//   String markerParam = "pin-s+007bff(${current.lng},${current.lat})";
//
//   // 4. Set the view to "auto" so Mapbox automatically fits the whole path in the frame
//   // Instead of passing zoom/lat/lng, we use 'auto'
//   return "https://api.mapbox.com/styles/v1/mapbox/satellite-streets-v12/static/$pathParam,$markerParam/auto/$width" + "x" + "$height?access_token=$accessToken";
// }