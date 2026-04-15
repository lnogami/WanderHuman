import 'package:flutter/material.dart';
import 'package:wanderhuman_app/model/history_model.dart';
import 'package:wanderhuman_app/utilities/properties/date_formatter.dart';
import 'package:wanderhuman_app/utilities/properties/text_formatter.dart';
import 'package:wanderhuman_app/view/components/lines.dart';

class MyInDangerCard extends StatefulWidget {
  final double width;
  final double height;
  final MyHistoryModel history;
  const MyInDangerCard({
    super.key,
    required this.width,
    required this.height,
    required this.history,
  });

  @override
  State<MyInDangerCard> createState() => _MyInDangerCardState();
}

class _MyInDangerCardState extends State<MyInDangerCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width * 0.80,
      padding: EdgeInsets.all(7),
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
      child: ClipRRect(
        borderRadius: BorderRadiusGeometry.circular(10),
        clipBehavior: Clip.hardEdge,
        child: cardHeaderArea(),
      ),
    );
  }

  Container cardHeaderArea() {
    return Container(
      // height: widget.height * 0.045,
      // color: Colors.amber,
      margin: EdgeInsets.only(left: 10, right: 10),
      child: Column(
        children: [
          Row(
            children: [
              MyTextFormatter.p(text: "In Danger"),
              Spacer(),
              MyLine(
                length: widget.height * 0.04,
                thickness: 1,
                margin: 7,
                isRounded: true,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // MMM dd yyyy
                  Row(
                    children: [
                      MyTextFormatter.p(
                        text: MyDateFormatter.formatDate(
                          dateTimeInString: widget.history.timeStamp,
                        ),
                        fontsize: kDefaultFontSize - 2,
                      ),
                      // (EEE)
                      MyTextFormatter.p(
                        text:
                            " (${MyDateFormatter.formatDate(dateTimeInString: widget.history.timeStamp, formatOptions: 7, customedFormat: "EEE")})",
                        fontsize: kDefaultFontSize - 3,
                      ),
                    ],
                  ),

                  // (hh:mm a)
                  MyTextFormatter.p(
                    text: MyDateFormatter.formatDate(
                      dateTimeInString: widget.history.timeStamp,
                      formatOptions: 7,
                      customedFormat: "hh:mm a",
                    ),
                    fontsize: kDefaultFontSize,
                  ),
                ],
              ),
            ],
          ),

          if (widget.history.assistedByWhenInDanger != "")
            MyTextFormatter.p(
              text: "Helped by: ${widget.history.assistedByWhenInDanger}",
              color: Colors.grey.shade700,
              fontsize: kDefaultFontSize - 4,
            ),
        ],
      ),
    );
  }
}
