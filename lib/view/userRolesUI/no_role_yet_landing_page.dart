import 'package:flutter/material.dart';
import 'package:wanderhuman_app/utilities/properties/color_palette.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';
import 'package:wanderhuman_app/utilities/properties/text_formatter.dart';

class NoRoleYetLandingPage extends StatelessWidget {
  final String userNameToDisplay;
  const NoRoleYetLandingPage({super.key, required this.userNameToDisplay});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColorPalette.formColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Icon(
              Icons.lock_outline_rounded,
              size: 72,
              color: Colors.grey.shade500,
            ),
          ),
          Container(
            width: MyDimensionAdapter.getWidth(context),
            // margin: EdgeInsets.only(left: 50, right: 40),
            padding: EdgeInsets.only(top: 20, left: 50, right: 20, bottom: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyTextFormatter.p(
                      text: "Hello there, ",
                      fontsize: kDefaultFontSize + 6,
                    ),
                    SizedBox(
                      width: MyDimensionAdapter.getWidth(context) * 0.45,
                      // color: Colors.amber,
                      child: MyTextFormatter.h3(
                        text: "$userNameToDisplay!",
                        fontsize: kDefaultFontSize + 10,
                        maxLines: 10,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                MyTextFormatter.p(
                  maxLines: 5,
                  text: "Access Pending",
                  fontWeight: FontWeight.w500,
                  fontsize: kDefaultFontSize + 1,
                  // color: Colors.grey.shade700,
                ),

                SizedBox(height: 8),
                SizedBox(
                  width: MyDimensionAdapter.getWidth(context) * 0.78,
                  child: MyTextFormatter.p(
                    maxLines: 5,
                    text:
                        "You do not have an assigned role yet. Please wait for the admin to assign you one.",
                    // color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
