import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wanderhuman_app/helper/emergency_hotlines_repository.dart';
import 'package:wanderhuman_app/model/emergency_hotlines_model.dart';
import 'package:wanderhuman_app/utilities/properties/color_palette.dart';
import 'package:wanderhuman_app/utilities/properties/date_formatter.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';
import 'package:wanderhuman_app/utilities/properties/text_formatter.dart';
import 'package:wanderhuman_app/view/components/alert_dialogue.dart';
import 'package:wanderhuman_app/view/components/button.dart';
import 'package:wanderhuman_app/view/components/my_animated_snackbar.dart';
import 'package:wanderhuman_app/view/components/textfield.dart';
import 'package:wanderhuman_app/view/components/tooltip.dart';

class EmergencyHotlineContents extends StatefulWidget {
  const EmergencyHotlineContents({super.key});

  @override
  State<EmergencyHotlineContents> createState() =>
      _EmergencyHotlineContentsState();
}

class _EmergencyHotlineContentsState extends State<EmergencyHotlineContents> {
  TextEditingController hotlineNameController = TextEditingController();
  TextEditingController hotlineNumberController = TextEditingController();

  /// Is only for adding a new contact hotline.
  bool isToAddContact = false;

  /// Is only for updating a contact hotline.
  bool isToUpdateContact = false;
  String theIDUsedToUpdateContact = "";

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: MyDimensionAdapter.getWidth(context),
        height:
            MyDimensionAdapter.getHeight(context) *
            ((isToAddContact) ? 0.7 : 0.6),
        padding: EdgeInsets.only(top: 20),
        decoration: BoxDecoration(
          color: (isToAddContact) ? MyColorPalette.formColor : Colors.white70,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          children: [
            header(context),
            SizedBox(height: 15),

            (isToAddContact)
                ? addContactHotlineArea()
                : fetchedContactHotlines(),
            SizedBox(height: 10),

            buttonsArea(context),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  MyCustTooltip header(BuildContext context) {
    return MyCustTooltip(
      message:
          "[Tap] to copy the number. [Double Tap] to edit. [Long Press] to delete.",
      triggerMode: TooltipTriggerMode.tap,
      child: Container(
        width: MyDimensionAdapter.getWidth(context) * 0.9,
        height: 45,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: (isToAddContact) ? Colors.transparent : Colors.white30,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.call, size: 32, color: Colors.grey.shade700),
            SizedBox(width: 10),
            MyTextFormatter.h3(
              text: (isToAddContact)
                  ? "Add Emergency Contact"
                  : "Emergency Hotlines",
              color: (isToAddContact)
                  ? Colors.grey.shade700
                  : Colors.grey.shade800,
            ),
          ],
        ),
      ),
    );
  }

  Expanded fetchedContactHotlines() {
    return Expanded(
      child: FutureBuilder(
        future: MyEmergencyHotlinesRepository.getContacts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: MyTextFormatter.h3(
                text: "No Data Found..",
                color: Colors.grey.shade700,
              ),
            );
          } else {
            return RawScrollbar(
              thumbColor: Colors.grey.shade300,
              padding: EdgeInsets.only(right: 2),
              thumbVisibility: true,
              trackVisibility: true,
              thickness: 5,
              radius: Radius.circular(7),
              child: ListView.builder(
                primary: true,
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return Container(
                    // width: MyDimensionAdapter.getWidth(context) * 0.8,
                    // height: MyDimensionAdapter.getHeight(context) * 0.05,
                    padding: EdgeInsets.only(
                      left: 5,
                      right: 5,
                      top: 15,
                      bottom: 15,
                    ),
                    margin: EdgeInsets.fromLTRB(25, 0, 25, 7),
                    decoration: BoxDecoration(
                      color: Colors.white38,
                      borderRadius: BorderRadius.all(Radius.circular(7)),
                      border: BoxBorder.all(color: Colors.white, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          // color: Colors.amber,
                          offset: Offset(0, 1),
                          blurRadius: 2,
                          blurStyle: BlurStyle.outer,
                        ),
                      ],
                    ),
                    child: GestureDetector(
                      // Save
                      onTap: () async {
                        // copy the text (hotlineNumber) to clipboard
                        Clipboard.setData(
                          ClipboardData(
                            text: snapshot.data![index].hotLineNumber,
                          ),
                        );

                        // get the copied text
                        ClipboardData? copiedText = await Clipboard.getData(
                          Clipboard.kTextPlain,
                        );

                        // just to show that the data was copied successfully to clipboard
                        showMyAnimatedSnackBar(
                          // ignore: use_build_context_synchronously
                          context: context,
                          dataToDisplay:
                              "${copiedText?.text} copied to clipboard.",
                        );
                      },
                      // Edit
                      onDoubleTap: () {
                        setState(() {
                          hotlineNameController.text =
                              snapshot.data![index].hotLineName;
                          hotlineNumberController.text =
                              snapshot.data![index].hotLineNumber;
                          isToAddContact = true;
                          isToUpdateContact = true;
                          theIDUsedToUpdateContact =
                              snapshot.data![index].hotLineID;
                        });
                      },
                      // Delete
                      onLongPress: () {
                        myAlertDialogue(
                          context: context,
                          alertTitle:
                              "Confirm to delete ${snapshot.data![index].hotLineName}?",
                          alertContent:
                              "Are you sure you want to delete this hotline?",
                          onApprovalPressed: () {
                            MyEmergencyHotlinesRepository.deleteContact(
                              docID: snapshot.data![index].hotLineID,
                            );
                            setState(() {});
                            Navigator.pop(context);
                          },
                        );
                      },
                      // The Content Tile
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(width: 10),

                          // Title
                          SizedBox(
                            width: MyDimensionAdapter.getWidth(context) * 0.38,
                            child: MyTextFormatter.h3(
                              text: snapshot.data![index].hotLineName,
                              fontsize: kDefaultFontSize + 2,
                              color: Colors.grey.shade800,
                              maxLines: 2,
                            ),
                          ),
                          Spacer(),

                          // Number
                          MyTextFormatter.p(
                            text: snapshot.data![index].hotLineNumber,
                          ),
                          SizedBox(width: 10),

                          // Copy Icon
                          Icon(
                            Icons.copy_all_rounded,
                            color: Colors.blue.shade400,
                          ),
                          SizedBox(width: 10),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }

  Column addContactHotlineArea() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 10),
        MyCustTextfield(
          labelText: "Hotline Name",
          prefixIcon: Icons.abc,
          textController: hotlineNameController,
          borderRadius: 7,
          color: Colors.white10,
          activeBorderColor: Colors.blue.shade400,
        ),
        SizedBox(height: 10),
        MyCustTextfield(
          labelText: "Hotline Number",
          prefixIcon: Icons.phone,
          textController: hotlineNumberController,
          borderRadius: 7,
          color: Colors.white10,
          activeBorderColor: Colors.blue.shade400,
        ),
        SizedBox(height: 10),
      ],
    );
  }

  SingleChildScrollView buttonsArea(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Cancel Button
          if (isToAddContact) calcelButton(),
          // Add / Save Button
          addSaveUpdateButton(context),
        ],
      ),
    );
  }

  GestureDetector addSaveUpdateButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          // only triggers if in the state of adding a contact hotline
          if (isToAddContact && !isToUpdateContact) {
            FocusManager.instance.primaryFocus?.unfocus();
            if (hotlineNameController.text.isNotEmpty &&
                hotlineNumberController.text.isNotEmpty) {
              myAlertDialogue(
                context: context,
                alertTitle: "Confirm To Save?",
                alertContent: "Are you sure the provided number is correct?",
                onApprovalPressed: () {
                  MyEmergencyHotlinesRepository.addContact(
                    MyEmergencyHotlinesModel(
                      hotLineID: "",
                      hotLineName: hotlineNameController.text,
                      hotLineNumber: hotlineNumberController.text,
                      savedAt: MyDateFormatter.formatDate(
                        dateTimeInString: DateTime.now(),
                      ),
                      savedBy: FirebaseAuth.instance.currentUser!.uid,
                    ),
                  );
                  setState(() {
                    isToAddContact = false;
                    hotlineNameController.text = "";
                    hotlineNumberController.text = "";
                  });
                  Navigator.pop(context);
                },
              );
            } else {
              showMyAnimatedSnackBar(
                context: context,
                dataToDisplay: "Please fill out all the required fields.",
              );
            }
          }
          // for Editing a contact hotline
          else if (isToUpdateContact) {
            FocusManager.instance.primaryFocus?.unfocus();
            if (hotlineNameController.text.isNotEmpty &&
                hotlineNumberController.text.isNotEmpty) {
              myAlertDialogue(
                context: context,
                alertTitle: "Confirm To Save Update?",
                alertContent: "Are you sure the provided number is correct?",
                onApprovalPressed: () {
                  MyEmergencyHotlinesRepository.updateContact(
                    docID: theIDUsedToUpdateContact,
                    hotline: MyEmergencyHotlinesModel(
                      hotLineID: theIDUsedToUpdateContact,
                      hotLineName: hotlineNameController.text,
                      hotLineNumber: hotlineNumberController.text,
                      savedAt: MyDateFormatter.formatDate(
                        dateTimeInString: DateTime.now(),
                      ),
                      savedBy: FirebaseAuth.instance.currentUser!.uid,
                    ),
                  );
                  setState(() {
                    isToAddContact = false;
                    hotlineNameController.text = "";
                    hotlineNumberController.text = "";
                    isToUpdateContact = false;
                    theIDUsedToUpdateContact = "";
                  });
                  Navigator.pop(context);
                },
              );
            } else {
              showMyAnimatedSnackBar(
                context: context,
                dataToDisplay: "Please do not leave any required field empty.",
              );
            }
          }
          //
          else if (!isToAddContact) {
            isToAddContact = true;
          }
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        width:
            MyDimensionAdapter.getWidth(context) *
            ((isToAddContact) ? 0.45 : 0.8),
        height: 50,
        decoration: BoxDecoration(
          color: Colors.blue.shade400,
          border: BoxBorder.all(color: Colors.white, width: 1.5),
          borderRadius: BorderRadius.circular(50),
        ),
        alignment: Alignment.center,
        child: MyTextFormatter.h3(
          text: (isToAddContact) ? "Save Contact" : "Add Emergency Contact",
          color: Colors.white,
        ),
      ),
    );
  }

  MyCustButton calcelButton() {
    return MyCustButton(
      buttonText: "Cancel",
      widthPercentage: 0.3,
      height: 45,
      color: Colors.transparent,
      enableShadow: false,
      borderColor: Colors.transparent,
      onTap: () {
        setState(() {
          hotlineNameController.clear();
          hotlineNumberController.clear();
          isToAddContact = false;
        });
      },
    );
  }
}
