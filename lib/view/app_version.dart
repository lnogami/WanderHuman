import 'package:flutter/material.dart';
import 'package:wanderhuman_app/utilities/properties/text_formatter.dart';

class MyAppVersion extends StatelessWidget {
  const MyAppVersion({super.key});

  final String appVersion = "1.12.0";

  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //   body: Container(
    //     width: MyDimensionAdapter.getWidth(context),
    //     height: MyDimensionAdapter.getHeight(context),
    //     color: Colors.blue.shade100,
    //     child: Column(
    //       children: [

    //       ],
    //     ),
    //   ),
    // );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        MyTextFormatter.p(
          text: "App Version: ",
          fontsize: kDefaultFontSize - 4,
          color: Colors.blueGrey.withAlpha(180),
        ),
        MyTextFormatter.p(
          text: appVersion,
          fontsize: kDefaultFontSize - 3,
          color: Colors.blueGrey.withAlpha(200),
        ),
      ],
    );
  }
}
