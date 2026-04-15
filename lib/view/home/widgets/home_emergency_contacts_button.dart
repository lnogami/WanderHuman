import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wanderhuman_app/utilities/properties/text_formatter.dart';
import 'package:wanderhuman_app/view-model/home_settings_provider.dart';
import 'package:wanderhuman_app/view/home/widgets/home_utility_functions/emergency_hotline_contents.dart';

class MyHomeEmergencyContactsButton extends StatelessWidget {
  const MyHomeEmergencyContactsButton({super.key});

  @override
  Widget build(BuildContext context) {
    MyHomeSettingsProvider settingsProvider = context
        .watch<MyHomeSettingsProvider>();

    return GestureDetector(
      onTap: () {
        showMyBottomPanel(context);
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
              : BorderRadius.circular(7),
          color: Colors.white54,
        ),
        child: (settingsProvider.minimizeHomePageButtons)
            ? Icon(Icons.call_outlined, color: Colors.grey.shade600, size: 28)
            : Column(
                children: [
                  Icon(
                    Icons.call_outlined,
                    color: Colors.grey.shade800,
                    size: 16,
                  ),
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
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return EmergencyHotlineContents();
      },
    );
  }

  // void addContactBottomPanel(BuildContext context) {
  //   showBottomSheet(
  //     context: context,
  //     builder: (context) {
  //       return Container(
  //         width: MyDimensionAdapter.getWidth(context),
  //         height: MyDimensionAdapter.getHeight(context) * 0.56,
  //         padding: EdgeInsets.only(top: 20),
  //         decoration: BoxDecoration(
  //           color: Colors.white70,
  //           borderRadius: BorderRadius.only(
  //             topLeft: Radius.circular(30),
  //             topRight: Radius.circular(30),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }
}
