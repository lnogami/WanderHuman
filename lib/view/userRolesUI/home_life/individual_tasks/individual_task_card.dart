import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wanderhuman_app/helper/home_life_repository.dart';
import 'package:wanderhuman_app/helper/personal_info_repository.dart';
import 'package:wanderhuman_app/model/home_life_models/task_model.dart';
import 'package:wanderhuman_app/model/personal_info.dart';
import 'package:wanderhuman_app/utilities/properties/date_formatter.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';
import 'package:wanderhuman_app/utilities/properties/text_formatter.dart';
import 'package:wanderhuman_app/view/components/alert_dialogue.dart';
import 'package:wanderhuman_app/view/components/lines.dart';
import 'package:wanderhuman_app/view/components/my_animated_snackbar.dart';

class IndividualTaskCard extends StatefulWidget {
  final String dateID;
  final String participantID;
  final HLTaskModel plannedTask;
  final double widthPercentage;
  final double heightPercentage;
  final bool isAccessedByHomeLifeStaff;

  const IndividualTaskCard({
    super.key,
    this.widthPercentage = 0.9,
    this.heightPercentage = 0.2,
    required this.dateID,
    required this.participantID,
    required this.plannedTask,
    this.isAccessedByHomeLifeStaff = true,
  });

  @override
  State<IndividualTaskCard> createState() => _IndividualTaskCardState();
}

class _IndividualTaskCardState extends State<IndividualTaskCard> {
  bool isDone = false;
  // temporary variable to quickly reflect the name after clicking this card checkbox/button
  String tempIsDoneBy = "";
  String tempIsConfirmedDoneBy = "";
  bool isConfirmedByLoading = false;

  /// to update isDone property of a task
  Future<void> updateIsDoneTask() async {
    PersonalInfo personalInfo =
        await MyPersonalInfoRepository.getSpecificPersonalInfo(
          userID: FirebaseAuth.instance.currentUser!.uid,
        );

    await HomeLifeRepository.updateIsDoneTaskStatus(
      dateID: widget.dateID,
      participantID: widget.participantID,
      taskID: widget.plannedTask.taskID!,
      isDone: isDone,
      isDoneBy: personalInfo.name,
    );

    setState(() {
      tempIsDoneBy = personalInfo.name;
    });
  }

  Future<void> updateIsConfirmedDoneTask() async {
    setState(() => isConfirmedByLoading = true);
    PersonalInfo personalInfo =
        await MyPersonalInfoRepository.getSpecificPersonalInfo(
          userID: FirebaseAuth.instance.currentUser!.uid,
        );

    // Don't proceed if the one who marked it done is the same as the one who will confirm it as done.
    if (widget.plannedTask.isDoneBy == personalInfo.name) {
      showMyAnimatedSnackBar(
        // ignore: use_build_context_synchronously
        context: context,
        dataToDisplay: "Sorry, you can't confirm your own work.",
        bgColor: Colors.white,
      );
      setState(() => isConfirmedByLoading = false);
      return;
    }

    await HomeLifeRepository.updateIsConfirmedDoneTask(
      dateID: widget.dateID,
      participantID: widget.participantID,
      taskID: widget.plannedTask.taskID!,
      isConfirmedDoneBy: personalInfo.name,
      isConfirmedByDifferentPerson:
          widget.plannedTask.isDoneBy != personalInfo.name,
    );

    setState(() {
      tempIsConfirmedDoneBy = personalInfo.name;
      isConfirmedByLoading = false;
    });
  }

  /// to get isDone property of a task
  Future<void> getTaskStatus() async {
    bool tempIsDone = await HomeLifeRepository.getTaskStatus(
      dateID: widget.dateID,
      participantID: widget.participantID,
      taskID: widget.plannedTask.taskID!,
    );

    setState(() {
      isDone = tempIsDone;
    });
  }

  @override
  void initState() {
    super.initState();
    getTaskStatus();
  }

  @override
  Widget build(BuildContext context) {
    // to make the ripple effect of Inkwell visible
    return Container(
      width: MyDimensionAdapter.getWidth(context) * 0.8,
      height: MyDimensionAdapter.getHeight(context) * 0.14,
      margin: EdgeInsets.only(top: 7, left: 3, right: 3, bottom: 3),
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
          onTap: () {
            // Preventing non-home life staff to confirm the task as done, because only home life staff can confirm that a task is truly done by the one who marked it as done, to maintain the integrity of the task status.
            if (!widget.isAccessedByHomeLifeStaff) {
              showMyAnimatedSnackBar(
                context: context,
                dataToDisplay:
                    "Sorry, only a Home Life staff can mark and confirm tasks as done. (You only have view access.)",
                bgColor: Colors.white,
              );
              return;
            }

            // if task is out of date, it can't be done anymore
            if (MyDateFormatter.formatDate(
                  dateTimeInString: DateTime.now().toString(),
                ) !=
                widget.dateID) {
              showMyAnimatedSnackBar(
                context: context,
                dataToDisplay:
                    "Sorry, this task is already out of date, therefore it can't be done.",
                bgColor: Colors.white,
              );
            }
            // if task is not yet done
            else if (!isDone) {
              myAlertDialogue(
                context: context,
                alertTitle: "Confirm Task Completion",
                alertContent:
                    "\nAre you sure this task \n'${widget.plannedTask.taskName.trim()}' is done? \nONCE CONFIRMED,\nIT CANNOT BE UNDONE.",
                onApprovalPressed: () {
                  setState(() {
                    isDone = true;
                  });
                  updateIsDoneTask();
                  // to pop the dialog box
                  Navigator.pop(context);
                },
              );
            } else if (isDone &&
                widget.plannedTask.isConfirmedDoneBy == '' &&
                tempIsConfirmedDoneBy == '') {
              myAlertDialogue(
                context: context,
                alertTitle: "Confirm Task Completion",
                alertContent:
                    "Warning, only confirm if you are sure that this task is truly done by the one who marked it, as you will also hold accountable for this task's integrity.",
                onApprovalPressed: () {
                  updateIsConfirmedDoneTask();
                  // to pop the dialog box
                  Navigator.pop(context);
                },
              );
            }
            // if already done, just showing a visual cue that this task is already done
            else {
              String name = (widget.plannedTask.isConfirmedDoneBy == '')
                  ? tempIsConfirmedDoneBy
                  : widget.plannedTask.isConfirmedDoneBy;
              showMyAnimatedSnackBar(
                context: context,
                bgColor: Colors.white,
                // dataToDisplay: "This task was already marked as done!",
                dataToDisplay: "This task was already confirmed done by $name!",
              );
            }
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              // checkbox
              Positioned(
                left: -(MyDimensionAdapter.getWidth(context) * 0.0018),
                child: Checkbox.adaptive(
                  activeColor: Colors.blue.shade300,
                  side: BorderSide(color: Colors.blue.shade200, width: 1.5),
                  value: isDone,
                  onChanged: (value) {
                    // there's nothing here because it was handle by this widget as a whole button
                  },
                ),
              ),
              // vertical line
              Positioned(
                left: MyDimensionAdapter.getWidth(context) * 0.115,
                child: MyLine(
                  color: Colors.blue.shade100,
                  thickness: 1,
                  length: MyDimensionAdapter.getHeight(context) * 0.12,
                ),
              ),
              // card's top area (task name and date)
              topArea(context),
              // card's bottom area (task description)
              Positioned(
                top: MyDimensionAdapter.getHeight(context) * 0.05,
                left: MyDimensionAdapter.getWidth(context) * 0.14,
                child: Container(
                  width: MyDimensionAdapter.getWidth(context) * 0.632,
                  padding: EdgeInsets.only(left: 5, right: 5),
                  // color: Colors.amber,
                  alignment: Alignment.centerLeft,
                  child: MyTextFormatter.p(
                    // text:
                    // "jsjb skjfb sfdkjbf skdjbfdksj b s skjb jh h hjhjh jhvhjfksbfs fkjbdsfbs fsdkbfbsdfdfk sfkbsf sdkfks",
                    text: widget.plannedTask.description,
                    lineHeight: 1.2,
                    maxLines: 3,
                  ),
                ),
              ),
              Positioned(
                bottom: 2,
                left: MyDimensionAdapter.getWidth(context) * 0.14,
                child: Container(
                  width: MyDimensionAdapter.getWidth(context) * 0.645,
                  height: MyDimensionAdapter.getHeight(context) * 0.017,
                  margin: EdgeInsets.only(top: 2),
                  padding: EdgeInsets.only(left: 5, right: 5),
                  // color: Colors.yellow.shade100,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      FittedBox(
                        child: MyTextFormatter.p(
                          text:
                              (widget.plannedTask.isDoneBy != '' ||
                                  tempIsDoneBy != '')
                              ? "By: "
                              : "",
                          // text: widget.plannedTask.description,
                          maxLines: 1,
                        ),
                      ),
                      // this will display the person who have marked this task done, in short, the one who checked this task.
                      FittedBox(
                        child: MyTextFormatter.p(
                          // tempIsDoneBy is for when this task is not yet done and gets done,
                          //              just to quickly reflect a temporary version of the data being save in the database
                          text: (tempIsDoneBy != '')
                              ? tempIsDoneBy
                              : widget.plannedTask.isDoneBy,
                          fontWeight: FontWeight.w500,
                          maxLines: 1,
                        ),
                      ),

                      Spacer(),
                      if (widget.plannedTask.isConfirmedDoneBy != '' ||
                          tempIsConfirmedDoneBy != '')
                        MyLine(
                          length: MyDimensionAdapter.getHeight(context) * 0.017,
                          isRounded: true,
                        ),

                      FittedBox(
                        child: MyTextFormatter.p(
                          text:
                              (widget.plannedTask.isConfirmedDoneBy != '' ||
                                  tempIsConfirmedDoneBy != '')
                              ? "Confirmed by: "
                              : "",
                          // text: widget.plannedTask.description,
                          maxLines: 1,
                        ),
                      ),
                      // This will display the name of the home life staff who confirmed that the task was really done by a certain staff
                      (isConfirmedByLoading)
                          ? Container(
                              width:
                                  MyDimensionAdapter.getWidth(context) * 0.04,
                              height:
                                  MyDimensionAdapter.getWidth(context) * 0.04,
                              margin: EdgeInsets.only(left: 2, right: 2),
                              child: CircularProgressIndicator.adaptive(
                                strokeWidth: 2,
                              ),
                            )
                          : AnimatedOpacity(
                              duration: Duration(milliseconds: 400),
                              opacity: (isConfirmedByLoading) ? 0 : 1,
                              child: FittedBox(
                                child: MyTextFormatter.p(
                                  // tempIsConfirmedDone is for when this task is not yet done and gets done,
                                  //                     just to quickly reflect a temporary version of the data being save in the database
                                  text: (tempIsConfirmedDoneBy != '')
                                      ? tempIsConfirmedDoneBy
                                      : widget.plannedTask.isConfirmedDoneBy,
                                  fontWeight: FontWeight.w500,
                                  maxLines: 1,
                                ),
                              ),
                            ),
                    ],
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
            // TITLE
            Container(
              width: MyDimensionAdapter.getWidth(context) * 0.42,
              // color: Colors.white24,
              child: MyTextFormatter.h3(
                text: widget.plannedTask.taskName,
                maxLines: (widget.plannedTask.taskName.length > 14) ? 2 : 1,
                fontsize: (widget.plannedTask.taskName.length > 14)
                    ? kDefaultFontSize
                    : kDefaultFontSize + 2,
              ),
            ),
            Spacer(),
            MyLine(
              color: const Color.fromARGB(180, 144, 202, 249),
              length: MyDimensionAdapter.getHeight(context) * 0.038,
            ),
            SizedBox(width: 2),
            // Time
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                MyTextFormatter.p(text: "Time", fontsize: kDefaultFontSize - 3),
                MyTextFormatter.p(
                  text: widget.plannedTask.time,
                  // text: "07:30 AM",
                  fontsize: kDefaultFontSize - 2,
                ),
              ],
            ),
            SizedBox(width: 2),
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
