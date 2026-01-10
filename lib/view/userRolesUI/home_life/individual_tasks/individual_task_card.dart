import 'package:flutter/material.dart';
import 'package:wanderhuman_app/model/home_life_models/hl_planner_model.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';
import 'package:wanderhuman_app/utilities/properties/text_formatter.dart';
import 'package:wanderhuman_app/view/components/lines.dart';

class IndividualTaskCard extends StatefulWidget {
  final HomeLifePlannerModel? plannedTask; // not yet implemented
  final double widthPercentage;
  final double heightPercentage;
  const IndividualTaskCard({
    super.key,
    this.widthPercentage = 0.9,
    this.heightPercentage = 0.2,
    this.plannedTask,
  });

  @override
  State<IndividualTaskCard> createState() => _IndividualTaskCardState();
}

class _IndividualTaskCardState extends State<IndividualTaskCard> {
  @override
  Widget build(BuildContext context) {
    // to make the ripple effect of Inkwell visible
    return Container(
      width: MyDimensionAdapter.getWidth(context) * 0.8,
      height: MyDimensionAdapter.getHeight(context) * 0.14,
      margin: EdgeInsets.only(top: 10),
      // padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
      decoration: BoxDecoration(
        // color: Colors.blue.shade100,
        color: Colors.white70,
        border: Border.all(color: Colors.white, width: 1.5),
        borderRadius: BorderRadius.all(Radius.circular(7)),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(56, 96, 181, 252),
            blurRadius: 4,
            // spreadRadius: 1,
            offset: Offset(2, 2),
          ),
          BoxShadow(
            color: const Color.fromARGB(56, 96, 181, 252),
            blurRadius: 4,
            // spreadRadius: 1,
            offset: Offset(-2, 1),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          splashColor: const Color.fromARGB(
            51,
            74,
            173,
            255,
          ), // The ripple color (Splash)
          // highlightColor:
          //     MyColorPalette.formColor, // The background hold color
        ),
        child: InkWell(
          onTap: () {},
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: -(MyDimensionAdapter.getWidth(context) * 0.0018),
                child: Checkbox.adaptive(
                  activeColor: Colors.blue.shade300,
                  side: BorderSide(color: Colors.blue.shade200, width: 1.5),
                  value: true,
                  onChanged: (value) {},
                ),
              ),
              Positioned(
                left: MyDimensionAdapter.getWidth(context) * 0.115,
                child: MyLine(
                  color: Colors.blue.shade100,
                  thickness: 1,
                  length: MyDimensionAdapter.getHeight(context) * 0.12,
                ),
              ),
              topArea(context),
              Positioned(
                top: MyDimensionAdapter.getHeight(context) * 0.05,
                left: MyDimensionAdapter.getWidth(context) * 0.14,
                child: Container(
                  width: MyDimensionAdapter.getWidth(context) * 0.645,
                  padding: EdgeInsets.only(left: 5, right: 5),
                  // color: Colors.amber,
                  alignment: Alignment.centerLeft,
                  child: MyTextFormatter.p(
                    // text: "hello",
                    text:
                        "jsjb skjfb sfdkjbf skdjbfdksjbf skjbfksbfs fkjbdsfbs fsdkbfbsdfdfk sfkbsf sdkfks",
                    maxLines: 3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Positioned topArea(BuildContext context) {
    return Positioned(
      top: 2,
      left: MyDimensionAdapter.getWidth(context) * 0.14,
      child: Container(
        width: MyDimensionAdapter.getWidth(context) * 0.645,
        height: MyDimensionAdapter.getHeight(context) * 0.045,
        // color: Colors.amber,
        padding: EdgeInsets.only(left: 5, right: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            MyTextFormatter.h3(text: "Hello, World!"),
            Spacer(),
            MyLine(
              color: const Color.fromARGB(180, 144, 202, 249),
              length: MyDimensionAdapter.getHeight(context) * 0.038,
            ),
            SizedBox(width: 2),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                MyTextFormatter.p(text: "Date", fontsize: kDefaultFontSize - 3),
                MyTextFormatter.p(
                  text: "07:30PM",
                  fontsize: kDefaultFontSize - 2,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Card(
  //     margin: EdgeInsets.only(left: 20, right: 20),
  //     color: const Color.fromARGB(255, 224, 238, 255),
  //     borderOnForeground: true,
  //     surfaceTintColor: MyColorPalette.splashColor,
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
  //     shadowColor: Colors.blue.shade100,
  //     child: Theme(
  //       data: Theme.of(context).copyWith(
  //         splashColor: const Color.fromARGB(
  //           51,
  //           74,
  //           173,
  //           255,
  //         ), // The ripple color (Splash)
  //         // highlightColor:
  //         //     MyColorPalette.formColor, // The background hold color
  //       ),
  //       child: CheckboxListTile.adaptive(
  //         // to match the Card's shape
  //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
  //         side: BorderSide(color: Colors.blue.shade200, width: 1.5),
  //         overlayColor: WidgetStatePropertyAll(Colors.amber),
  //         // secondary: Icon(Icons.person_outline_rounded),
  //         controlAffinity: ListTileControlAffinity.leading,
  //         activeColor: Colors.blue.shade400,
  //         contentPadding: EdgeInsets.only(left: 5, right: 5),
  //         value: true,
  //         title: Text("Task Name"),
  //         // tileColor: Colors.blue.shade100,
  //         onChanged: (value) {},
  //       ),
  //     ),
  //   );
  // }
}
