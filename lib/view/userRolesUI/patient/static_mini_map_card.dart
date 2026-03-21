import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:wanderhuman_app/model/history_model.dart';
import 'package:wanderhuman_app/utilities/properties/date_formatter.dart';
import 'package:wanderhuman_app/utilities/properties/text_formatter.dart';
import 'package:wanderhuman_app/view/components/lines.dart';

class MyStaticMiniMapCard extends StatefulWidget {
  final double width;
  final double height;
  // final MyHistoryModel history;
  final List<MyHistoryModel> history;
  final Position centerPoint;
  const MyStaticMiniMapCard({
    super.key,
    required this.width,
    required this.height,
    required this.history,
    required this.centerPoint,
  });

  @override
  State<MyStaticMiniMapCard> createState() => _MyStaticMiniMapStateCard();
}

class _MyStaticMiniMapStateCard extends State<MyStaticMiniMapCard> {
  final BorderRadiusGeometry cardBorderRadius = BorderRadius.circular(10);
  bool isExpanded = false;
  List<Position> pathCoordinates = [];

  void compileCoordinates() {
    if (pathCoordinates.isNotEmpty) pathCoordinates.clear();
    // pathCoordinates.add(widget.centerPoint); // first in the path

    pathCoordinates.addAll(
      widget.history.map((historyModel) {
        return Position(
          double.parse(historyModel.currentLocationLng),
          double.parse(historyModel.currentLocationLat),
        );
      }).toList(),
    );
  }

  @override
  void initState() {
    super.initState();
    compileCoordinates();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => isExpanded = !isExpanded),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 400),
        width: widget.width * 0.80,
        height: widget.height * ((isExpanded) ? 0.5 : 0.25),
        margin: EdgeInsets.only(top: 5, bottom: 5, left: 30, right: 30),
        decoration: BoxDecoration(
          color: Colors.white70,
          borderRadius: cardBorderRadius,
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
        child: ClipRRect(
          borderRadius: cardBorderRadius,
          clipBehavior: Clip.hardEdge,
          child: Column(
            children: [
              cardHeaderArea(),
              // Expanded(child: Container(color: Colors.amber)),
              Expanded(
                child:
                    // --- THE STATIC MINI MAP ---
                    (!(widget.history.last.isCurrentlySafe))
                    ? Container(color: Colors.amber)
                    : CachedNetworkImage(
                        height: 200,
                        width: double.infinity,
                        imageUrl: getStaticMapWithHistoryUrl(
                          // history: [
                          //   Position(
                          //     double.parse(widget.history.last.currentLocationLng),
                          //     double.parse(widget.history.last.currentLocationLat),
                          //   ),
                          // ],
                          history: pathCoordinates,
                          width: (widget.width * 0.80).toInt(),
                          height: (widget.height * 0.4).toInt(),
                        ),
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Container cardHeaderArea() {
    String dayOfFirstLog = MyDateFormatter.formatDate(
      dateTimeInString: widget.history.first.timeStamp,
      formatOptions: 7,
      customedFormat: "EEE",
    );

    String dayOfSecondLog = MyDateFormatter.formatDate(
      dateTimeInString: widget.history.last.timeStamp,
      formatOptions: 7,
      customedFormat: "EEE",
    );

    return Container(
      height: widget.height * 0.045,
      // color: Colors.amber,
      margin: EdgeInsets.only(top: 5, left: 10, right: 10),
      child: Row(
        children: [
          MyTextFormatter.p(
            text: (widget.history.last.isInSafeZone)
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
              // If the same day display only one day, otherwise display both (shorten versions)
              (dayOfFirstLog != dayOfSecondLog)
                  ? Row(
                      children: [
                        // MMM dd
                        MyTextFormatter.p(
                          text: MyDateFormatter.formatDate(
                            dateTimeInString: widget.history.first.timeStamp,
                            formatOptions: 7,
                            customedFormat: "MMM dd-",
                          ),
                          fontsize: kDefaultFontSize - 3,
                        ),
                        // dd, yy
                        MyTextFormatter.p(
                          text: MyDateFormatter.formatDate(
                            dateTimeInString: widget.history.last.timeStamp,
                            formatOptions: 7,
                            customedFormat: "dd, yy",
                          ),
                          fontsize: kDefaultFontSize - 3,
                        ),
                        // DAY (EEE)
                        MyTextFormatter.p(
                          text:
                              " (${MyDateFormatter.formatDate(dateTimeInString: widget.history.first.timeStamp, formatOptions: 7, customedFormat: "EEE")}-",
                          fontsize: kDefaultFontSize - 4,
                        ),
                        // DAY (EEE)
                        MyTextFormatter.p(
                          text:
                              "${MyDateFormatter.formatDate(dateTimeInString: widget.history.last.timeStamp, formatOptions: 7, customedFormat: "EEE")})",
                          fontsize: kDefaultFontSize - 4,
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        // MMM dd yyyy
                        MyTextFormatter.p(
                          text: MyDateFormatter.formatDate(
                            dateTimeInString: widget.history.first.timeStamp,
                          ),
                          fontsize: kDefaultFontSize - 2,
                        ),
                        // (EEE)
                        MyTextFormatter.p(
                          text:
                              " (${MyDateFormatter.formatDate(dateTimeInString: widget.history.first.timeStamp, formatOptions: 7, customedFormat: "EEE")})",
                          fontsize: kDefaultFontSize - 3,
                        ),
                      ],
                    ),

              Row(
                children: [
                  // (hh:mm a)
                  MyTextFormatter.p(
                    text: MyDateFormatter.formatDate(
                      dateTimeInString: widget.history.first.timeStamp,
                      formatOptions: 7,
                      customedFormat: "hh:mm a - ",
                    ),
                    fontsize: kDefaultFontSize - 3,
                  ),
                  // (hh:mm a)
                  MyTextFormatter.p(
                    text: MyDateFormatter.formatDate(
                      dateTimeInString: widget.history.last.timeStamp,
                      formatOptions: 7,
                      customedFormat: "hh:mm a",
                    ),
                    fontsize: kDefaultFontSize - 3,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String getStaticMapWithHistoryUrl({
    required List<Position> history,
    int width = 600,
    int height = 400,
  }) {
    final String accessToken = dotenv.env['MAPBOX_ACCESS_TOKEN']!;

    // 1. Polyline encoding requires a list of [latitude, longitude] arrays
    List<List<num>> coordinatesForPolyline = history
        .map((pos) => [pos.lat, pos.lng])
        .toList();

    // 2. Encode the coordinates into the scrambled string Mapbox wants
    String encodedPolyline = encodePolyline(coordinatesForPolyline);

    // 3. URL-encode the string (because polylines have weird characters like ? and &)
    String safePolyline = Uri.encodeComponent(encodedPolyline);

    // 4. Build the correct path parameter
    String pathParam = "path-5+5ca7f6-0.8($safePolyline)";

    // 5. Add a marker for the CURRENT (last) position
    Position current = history.last;
    String markerParam = "pin-s+007bff(${current.lng},${current.lat})";

    // 6. Define the padding (in pixels) so the path doesn't touch the edges
    // You can increase or decrease this number to give it more or less breathing room
    int padding = 30;

    // 7. Add '?padding=$padding' to the query parameters
    return "https://api.mapbox.com/styles/v1/mapbox/satellite-streets-v12/static/$pathParam,$markerParam/auto/${width}x$height?padding=$padding&access_token=$accessToken";
  }
}
