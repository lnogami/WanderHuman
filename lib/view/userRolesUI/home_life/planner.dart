import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wanderhuman_app/utilities/properties/color_palette.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';
import 'package:wanderhuman_app/view/components/appbar.dart';
import 'package:wanderhuman_app/view/components/button.dart';
import 'package:wanderhuman_app/view/components/date_picker.dart';
import 'package:wanderhuman_app/view/components/page_navigator.dart';
import 'package:wanderhuman_app/view/login/widgets/textfield.dart';

class HomeLifePlanner extends StatelessWidget {
  const HomeLifePlanner({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    return Scaffold(
      body: Container(
        width: MyDimensionAdapter.getWidth(context),
        // height: MyDimensionAdapter.getHeight(context),
        color: MyColorPalette.formColor,
        child: Column(
          children: [
            // APPBAR
            SafeArea(
              child: MyCustAppBar(
                title: "Planner",
                backButton: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  MyNavigator.goTo(context, HomeLifePlanner());
                },
                backButtonColor: Colors.blue.shade300,
              ),
            ),
            SizedBox(height: 10),

            //
            MyCustTextfield(
              labelText: "Title",
              prefixIcon: Icons.title_rounded,
              textController: TextEditingController(),
              borderRadius: 7,
              borderColor: MyColorPalette.borderColor,
              activeBorderColor: MyColorPalette.borderColor,
            ),
            SizedBox(height: 10),

            //
            MyCustTextfield(
              labelText: "Description",
              prefixIcon: Icons.description_outlined,
              textController: TextEditingController(),
              borderRadius: 7,
              borderColor: MyColorPalette.borderColor,
              activeBorderColor: MyColorPalette.borderColor,
            ),
            SizedBox(height: 10.5),

            //
            SizedBox(
              width: MyDimensionAdapter.getWidth(context) * 0.9,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MyCustButton(
                    buttonText: "FROM",
                    borderRadius: 7,
                    color: MyColorPalette.formColor,
                    borderColor: MyColorPalette.borderColor,
                    buttonShadowColor: Colors.blue.shade200,
                    widthPercentage: 0.39,
                    buttonTextSpacing: 1,
                    onTap: () {
                      myDatePicker(context);
                    },
                  ),
                  SizedBox(width: 7),
                  MyCustButton(
                    buttonText: "UNTIL",
                    borderRadius: 7,
                    color: MyColorPalette.formColor,
                    borderColor: MyColorPalette.borderColor,
                    buttonShadowColor: Colors.blue.shade200,
                    widthPercentage: 0.39,
                    buttonTextSpacing: 1,
                    onTap: () {
                      myDatePicker(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
