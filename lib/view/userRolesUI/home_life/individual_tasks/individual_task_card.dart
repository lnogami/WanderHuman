import 'package:flutter/material.dart';
import 'package:wanderhuman_app/helper/home_life_repository.dart';
import 'package:wanderhuman_app/model/home_life_models/task_model.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';
import 'package:wanderhuman_app/utilities/properties/text_formatter.dart';
import 'package:wanderhuman_app/view/components/alert_dialogue.dart';
import 'package:wanderhuman_app/view/components/lines.dart';
import 'package:wanderhuman_app/view/home/widgets/home_utility_functions/my_animated_snackbar.dart';

class IndividualTaskCard extends StatefulWidget {
  final String dateID;
  final String participantID;
  final HLTaskModel plannedTask;
  final double widthPercentage;
  final double heightPercentage;
  const IndividualTaskCard({
    super.key,
    this.widthPercentage = 0.9,
    this.heightPercentage = 0.2,
    required this.dateID,
    required this.participantID,
    required this.plannedTask,
  });

  @override
  State<IndividualTaskCard> createState() => _IndividualTaskCardState();
}

class _IndividualTaskCardState extends State<IndividualTaskCard> {
  bool isDone = false;

  /// to update isDone property of a task
  Future<void> updateIsDoneTask() async {
    await HomeLifeRepository.updateIsDoneTaskStatus(
      dateID: widget.dateID,
      participantID: widget.participantID,
      taskID: widget.plannedTask.taskID!,
      isDone: isDone,
    );
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
            // if task is not yet done
            if (!isDone) {
              myAlertDialogue(
                context: context,
                alertTitle: "Confirm Task Completion",
                alertContent:
                    "\nAre you sure this task [${widget.plannedTask.taskName}] is done? \nOnce confirmed, it cannot be undone",
                onApprovalPressed: () {
                  setState(() {
                    isDone = true;
                  });
                  updateIsDoneTask();
                  // to pop the dialog box
                  Navigator.pop(context);
                },
              );
            }
            // if already done, just showing a visual cue that this task is already done
            else {
              showMyAnimatedSnackBar(
                context: context,
                bgColor: Colors.white70,
                dataToDisplay: "You already marked this task as done!",
              );
            }
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
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
                    // text:
                    //     "jsjb skjfb sfdkjbf skdjbfdksjbf skjbfksbfs fkjbdsfbs fsdkbfbsdfdfk sfkbsf sdkfks",
                    text: widget.plannedTask.description,
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                MyTextFormatter.p(text: "Date", fontsize: kDefaultFontSize - 3),
                MyTextFormatter.p(
                  text: widget.plannedTask.time,
                  // text: "07:30 AM",
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
