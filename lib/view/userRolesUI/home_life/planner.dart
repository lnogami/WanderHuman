import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wanderhuman_app/utilities/properties/color_palette.dart';
import 'package:wanderhuman_app/utilities/properties/date_formatter.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';
import 'package:wanderhuman_app/view/components/appbar.dart';
import 'package:wanderhuman_app/view/components/button.dart';
import 'package:wanderhuman_app/view/components/date_picker.dart';
import 'package:wanderhuman_app/view/components/page_navigator.dart';
import 'package:wanderhuman_app/view/home/widgets/home_utility_functions/my_animated_snackbar.dart';
import 'package:wanderhuman_app/view/login/widgets/textfield.dart';

class HomeLifePlanner extends StatefulWidget {
  const HomeLifePlanner({super.key});

  @override
  State<HomeLifePlanner> createState() => _HomeLifePlannerState();
}

class _HomeLifePlannerState extends State<HomeLifePlanner> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  DateTime? fromDate;
  // String fromDateButtonDisplay = "FROM";
  DateTime? untilDate;
  // String untilDateButtonDisplay = "UNTIL";
  List<String> participants = [];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    return Scaffold(
      body: SafeArea(
        child: Container(
          width: MyDimensionAdapter.getWidth(context),
          // height: MyDimensionAdapter.getHeight(context),
          color: MyColorPalette.formColor,
          child: Column(
            children: [
              // APPBAR
              MyCustAppBar(
                title: "Planner",
                backButton: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  MyNavigator.goTo(context, HomeLifePlanner());
                },
                backButtonColor: Colors.blue.shade300,
              ),
              SizedBox(height: 40),

              //
              MyCustTextfield(
                labelText: "Title",
                prefixIcon: Icons.title_rounded,
                textController: titleController,
                borderRadius: 7,
                borderColor: MyColorPalette.borderColor,
                activeBorderColor: MyColorPalette.borderColor,
              ),
              SizedBox(height: 10),

              //
              MyCustTextfield(
                labelText: "Description",
                prefixIcon: Icons.description_outlined,
                textController: descriptionController,
                borderRadius: 7,
                borderColor: MyColorPalette.borderColor,
                activeBorderColor: MyColorPalette.borderColor,
              ),
              SizedBox(height: 10.5),

              // FROM and UNTIL date buttons
              dateButtons(context),

              // SizedBox(height: 10),
              Spacer(),

              saveAndCancelButtons(
                onPressSave: () {
                  showMyAnimatedSnackBar(
                    context: context,
                    dataToDisplay: "SAVE button is pressed",
                  );
                },
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Row saveAndCancelButtons({required VoidCallback onPressSave}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        MyCustButton(
          buttonText: "CANCEL",
          widthPercentage: 0.40,
          color: MyColorPalette.formColor,
          borderColor: Colors.transparent,
          enableShadow: false,
          buttonTextSpacing: 1,
          onTap: () {
            Navigator.pop(context);
          },
        ),
        MyCustButton(
          buttonText: "SAVE",
          widthPercentage: 0.40,
          buttonTextFontSize: kDefaultFontSize + 1,
          buttonTextColor: Colors.white,
          buttonTextSpacing: 1,
          onTap: onPressSave,
        ),
      ],
    );
  }

  SizedBox dateButtons(BuildContext context) {
    return SizedBox(
      width: MyDimensionAdapter.getWidth(context) * 0.9,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MyCustButton(
            buttonText: (fromDate == null)
                ? "FROM"
                : MyDateFormatter.formatDate(dateTimeInString: fromDate),
            borderRadius: 7,
            color: MyColorPalette.formColor,
            borderColor: MyColorPalette.borderColor,
            buttonShadowColor: Colors.blue.shade200,
            widthPercentage: 0.39,
            buttonTextSpacing: 1,
            onTap: () async {
              DateTime? tempFromDate = await myDatePicker(
                context,
                initialYear: DateTime.now().year,
              );

              // if tempDate is null, do nothing
              if (tempFromDate != null) {
                // if untilDate is null, still set fromDate value
                if (untilDate == null) {
                  setState(() {
                    fromDate = tempFromDate;
                  });
                }
                // tempFromDate must be before untilDate (if untilDate has value)
                else if (tempFromDate.isBefore(untilDate!)) {
                  print("is BEFOREEEEEEEEEEEEEEEEE");
                  setState(() {
                    fromDate = tempFromDate;
                  });
                }
                // just a visual dialog saying you can't choose a date that is before FROM date
                else {
                  showMyAnimatedSnackBar(
                    context: context,
                    dataToDisplay: "FROM date must be before UNTIL date",
                  );
                }
              }
              // for debugging purposes only (deletable)
              print("FROM DATE CURRENT VALUE: $fromDate");
            },
          ),
          SizedBox(width: 7),
          MyCustButton(
            buttonText: (untilDate == null)
                ? "UNTIL"
                : MyDateFormatter.formatDate(dateTimeInString: untilDate),
            borderRadius: 7,
            color: MyColorPalette.formColor,
            borderColor: MyColorPalette.borderColor,
            buttonShadowColor: Colors.blue.shade200,
            widthPercentage: 0.39,
            buttonTextSpacing: 1,
            onTap: () async {
              DateTime? tempUntilDate = await myDatePicker(
                context,
                initialYear: DateTime.now().year,
              );
              // if tempDate is null, do nothing
              if (tempUntilDate != null) {
                print("tempUntilDate is NOT NULLLLLLLLLLLL");
                // if fromDate is null a snackbar will appear to ensure fromDate must be fillout first
                if (fromDate == null) {
                  showMyAnimatedSnackBar(
                    context: context,
                    dataToDisplay: "Please, fill out the FROM date first.",
                  );
                }
                // tempUntilDate must be after fromDate (if fromDate has value)
                else if (tempUntilDate.isAfter(fromDate!)) {
                  print(
                    "TEMPUNTILDATE isAfter FROM DATEEEEEEEEEEEEEEEEEEEEEEEEEEE",
                  );
                  setState(() {
                    untilDate = tempUntilDate;
                  });
                }
                // just a visual dialog saying you can't choose a date that is before FROM date
                else {
                  showMyAnimatedSnackBar(
                    context: context,
                    dataToDisplay: "UNTIL date must be after FROM date",
                  );
                }
                // for debugging purposes only (deletable)
                print("UNTIL DATE CURRENT VALUE: $untilDate");
              }
            },
          ),
        ],
      ),
    );
  }
}
