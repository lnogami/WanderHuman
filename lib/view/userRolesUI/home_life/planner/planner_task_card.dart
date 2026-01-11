import 'package:flutter/material.dart';
import 'package:wanderhuman_app/model/home_life_models/hl_planner_model.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';
import 'package:wanderhuman_app/utilities/properties/text_formatter.dart';
import 'package:wanderhuman_app/view/components/lines.dart';

class TaskCard extends StatefulWidget {
  final HomeLifePlannerModel task;
  const TaskCard({super.key, required this.task});

  // const TaskCard({super.key});

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  /// To have more control about displaying of this repeatInterval logic
  List<String> daysToRepeat = [];

  // /// Will hold the formatted value of Time that was converted to String back to TimeOfDay
  // String formattedTimeOfDay = "";

  @override
  void initState() {
    super.initState();
    daysToRepeat = widget.task.repeatInterval.split(",");
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // this one is not in initState because it will take time to look up for the context (.format()) so thats why its in here
    // formattedTimeOfDay = (MyTimeFormatter.stringToTimeOfDay(
    //   widget.task.time,
    // ).format(context).toString());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MyDimensionAdapter.getWidth(context) * 0.8,
      height: MyDimensionAdapter.getHeight(context) * 0.125,
      margin: EdgeInsets.only(top: 10),
      padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
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
        ],
      ),
      child: Column(
        children: [
          upperCardPart(context),
          // SizedBox(height: 5),
          SizedBox(height: 5),
          Expanded(
            child: Container(
              width: MyDimensionAdapter.getWidth(context) * 0.8,
              // color: Colors.blue.shade50,
              child: MyTextFormatter.p(
                text: widget.task.taskDescription,
                fontsize: kDefaultFontSize - 2,
                maxLines: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Row upperCardPart(BuildContext context) {
    return Row(
      children: [
        Container(
          width: MyDimensionAdapter.getWidth(context) * 0.37,
          height: MyDimensionAdapter.getHeight(context) * 0.05,
          // color: Colors.amber.shade100,
          alignment: Alignment.centerLeft,
          child: MyTextFormatter.h3(
            text: widget.task.taskName,
            // this logic will ensure that if the Title's length is too long for the container can occupy, it will shrink a little bit
            fontsize: (widget.task.taskName.length > 13)
                ? kDefaultFontSize
                : kDefaultFontSize + 2,
            // this logic will also ensure that if the Title's length is too long for the container width can occupy, it will have 2 lines instead of 1
            maxLines: (widget.task.taskName.length > 13) ? 2 : 1,
          ),
        ),
        Spacer(),
        MyLine(length: MyDimensionAdapter.getWidth(context) * 0.07),
        Container(
          width: MyDimensionAdapter.getWidth(context) * 0.15,
          height: MyDimensionAdapter.getHeight(context) * 0.05,
          // color: Colors.amber.shade100,
          child: Column(
            children: [
              MyTextFormatter.p(text: "Every", fontsize: kDefaultFontSize - 4),
              FittedBox(
                fit: BoxFit.fill,
                child: MyTextFormatter.p(
                  text: (daysToRepeat.length > 7)
                      // ? "${daysToRepeat.length}x /week"
                      ? "Day"
                      : (daysToRepeat.length > 1)
                      ? "${daysToRepeat.length}x /week"
                      : daysToRepeat[0],
                  // maxLines: 2,
                ),
              ),
            ],
          ),
        ),
        MyLine(length: MyDimensionAdapter.getWidth(context) * 0.07),
        Container(
          width: MyDimensionAdapter.getWidth(context) * 0.15,
          height: MyDimensionAdapter.getHeight(context) * 0.05,
          // color: Colors.amber.shade100,
          child: Column(
            children: [
              MyTextFormatter.p(text: "Time", fontsize: kDefaultFontSize - 4),
              FittedBox(
                child: MyTextFormatter.p(text: widget.task.time, maxLines: 2),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
