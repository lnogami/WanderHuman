import 'package:flutter/material.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';
import 'package:wanderhuman_app/utilities/properties/text_formatter.dart';

class MyHomeEmergencyContactsList extends StatelessWidget {
  const MyHomeEmergencyContactsList({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showMyBottomPanel(context);
      },
      child: Container(
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          color: Colors.white54,
        ),
        child: Column(
          children: [
            Icon(Icons.call_outlined, color: Colors.grey.shade800, size: 16),
            MyTextFormatter.p(
              text: "Emergency",
              fontWeight: FontWeight.w500,
              fontsize: kDefaultFontSize - 6,
            ),
            MyTextFormatter.p(
              text: "Contacts",
              fontWeight: FontWeight.w500,
              fontsize: kDefaultFontSize - 6,
            ),
          ],
        ),
      ),
    );
  }

  void showMyBottomPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          width: MyDimensionAdapter.getWidth(context),
          height: MyDimensionAdapter.getHeight(context) * 0.4,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.call, size: 32, color: Colors.blue.shade600),
                  MyTextFormatter.h3(
                    text: "Emergency Hotlines",
                    color: Colors.grey.shade900,
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MyTextFormatter.p(text: "Hello, "),
                  MyTextFormatter.p(text: "World!"),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
