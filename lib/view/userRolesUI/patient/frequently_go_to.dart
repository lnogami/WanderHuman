import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:wanderhuman_app/helper/history_reposity.dart';
import 'package:wanderhuman_app/model/history_model.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';
import 'package:wanderhuman_app/utilities/properties/text_formatter.dart';
import 'package:wanderhuman_app/view/components/button.dart';
import 'package:wanderhuman_app/view/components/tooltip.dart';

class FrequentlyGoToArea extends StatefulWidget {
  final String patientID;
  const FrequentlyGoToArea({super.key, required this.patientID});

  @override
  State<FrequentlyGoToArea> createState() => _FrequentlyGoToAreaState();
}

class _FrequentlyGoToAreaState extends State<FrequentlyGoToArea> {
  final ScrollController frequentlyGoToScrollController = ScrollController();
  final List<String> filterChoices = const [
    "All",
    "Today",
    "Yesterday",
    "This Week",
    "This Month",
    "This Year",
  ];
  String selectedFilter = "All";

  Future<Map<String, Duration>> calculateTotalTimePerArea(
    String patientID,
  ) async {
    try {
      Map<String, Duration> totalTimeMap = {};

      // 1. Fetch History sorted by TIME (Crucial!)
      // We need strict chronological order to measure duration.
      List<MyHistoryModel> logs = await dynamicQueryBasedOnSelectedFilter(
        patientID,
      );

      // (deletable) for debugging purposes only
      log("$patientID's total logs: ${logs.length} ");

      if (logs.isEmpty) return {};

      // 2. Sort Oldest -> Newest
      // Your Repo returns Newest First (Descending), so we reverse it.
      // It is much easier to calculate time going forward.
      logs = logs.reversed.toList();

      // 3. Loop through the logs
      for (int i = 0; i < logs.length - 1; i++) {
        var currentLog = logs[i];
        var nextLog = logs[i + 1];

        String areaName = currentLog.currentlyIn;

        // Skip empty or invalid areas
        if (areaName.isEmpty) continue;

        late DateTime startTime;
        late DateTime endTime;
        // to catch if an error occured during parsing
        try {
          // 4. Calculate the duration "Gap"
          startTime = DateTime.parse(currentLog.timeStamp);
          endTime = DateTime.parse(nextLog.timeStamp);
        } catch (e) {
          continue; // skip this iteration if there's an error
        }

        Duration timeSpentHere = endTime.difference(startTime);

        // (Optional Safety) If the gap is huge (e.g., > 1 hour) because the
        // device was off, you might want to ignore it or cap it.
        // For now, we accept it as is.

        // 5. Add to the Total Map
        if (totalTimeMap.containsKey(areaName)) {
          totalTimeMap[areaName] = totalTimeMap[areaName]! + timeSpentHere;
        } else {
          totalTimeMap[areaName] = timeSpentHere;
        }
      }

      // (Optional) Handle the very last log
      // Since there is no "next log", we don't know when they left.
      // You can either ignore it, or assume a standard 30 seconds.
      var lastLog = logs.last;
      if (lastLog.currentlyIn.isNotEmpty) {
        Duration standardGap = Duration(seconds: 30); // Your recording interval
        if (totalTimeMap.containsKey(lastLog.currentlyIn)) {
          totalTimeMap[lastLog.currentlyIn] =
              totalTimeMap[lastLog.currentlyIn]! + standardGap;
        } else {
          totalTimeMap[lastLog.currentlyIn] = standardGap;
        }
      }

      return totalTimeMap;
    } catch (e, stackTrace) {
      log("ERROR CALCULATING TIME: $e \nAT: $stackTrace");
      return {};
    }
  }

  // Future dynamicQueryBasedOnSelectedFilter(String patientID) async {
  //   switch (selectedFilter) {
  //     case "Today":
  //       return await MyHistoryReposity.getPatientFrequentlyGoToHistory(
  //         patientID,
  //         orderBy: "timeStamp",
  //         fieldToLookFor: "timeStamp",
  //         fieldValue: DateTime.now().toString()
  //       );
  //     case "This Week":
  //       return await MyHistoryReposity.getPatientFrequentlyGoToHistory(
  //         patientID,
  //         orderBy: "timeStamp",
  //       );
  //     case "This Month":
  //       return await MyHistoryReposity.getPatientFrequentlyGoToHistory(
  //         patientID,
  //         orderBy: "timeStamp",
  //       );
  //     case "This Year":
  //       return await MyHistoryReposity.getPatientFrequentlyGoToHistory(
  //         patientID,
  //         orderBy: "timeStamp",
  //       );
  //     default: // All
  //       return await MyHistoryReposity.getPatientFrequentlyGoToHistory(
  //         patientID,
  //         orderBy: "timeStamp",
  //       );
  //   }
  // }

  Future<dynamic> dynamicQueryBasedOnSelectedFilter(String patientID) async {
    DateTime now = DateTime.now();

    switch (selectedFilter) {
      case "Today":
        // Start: Midnight today | End: 11:59:59 PM today
        DateTime startOfToday = DateTime(now.year, now.month, now.day);
        DateTime endOfToday = DateTime(
          now.year,
          now.month,
          now.day,
          23,
          59,
          59,
        );
        return await MyHistoryReposity.getPatientFrequentlyGoToHistory(
          patientID,
          fieldToLookFor: "timeStamp",
          fieldValueStart: startOfToday.toString(),
          fieldValueEnd: endOfToday.toString(),
        );

      case "Yesterday":
        // Start: Midnight yesterday | End: 11:59:59 PM yesterday
        DateTime startOfYesterday = DateTime(now.year, now.month, now.day - 1);
        DateTime endOfYesterday = DateTime(
          now.year,
          now.month,
          now.day - 1,
          23,
          59,
          59,
        );
        return await MyHistoryReposity.getPatientFrequentlyGoToHistory(
          patientID,
          fieldToLookFor: "timeStamp",
          fieldValueStart: startOfYesterday.toString(),
          fieldValueEnd: endOfYesterday.toString(),
        );

      case "This Week":
        // Dart considers Monday as weekday 1.
        // Subtracting (weekday - 1) days gets us back to Monday.
        DateTime startOfWeek = DateTime(
          now.year,
          now.month,
          now.day - (now.weekday - 1),
        );
        DateTime endOfWeek = startOfWeek.add(
          const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
        );
        return await MyHistoryReposity.getPatientFrequentlyGoToHistory(
          patientID,
          fieldToLookFor: "timeStamp",
          fieldValueStart: startOfWeek.toString(),
          fieldValueEnd: endOfWeek.toString(),
        );

      case "This Month":
        // Start: 1st day of current month | End: Move to 1st day of next month, subtract 1 second
        DateTime startOfMonth = DateTime(now.year, now.month, 1);
        DateTime endOfMonth = DateTime(
          now.year,
          now.month + 1,
          1,
        ).subtract(const Duration(seconds: 1));
        return await MyHistoryReposity.getPatientFrequentlyGoToHistory(
          patientID,
          fieldToLookFor: "timeStamp",
          fieldValueStart: startOfMonth.toString(),
          fieldValueEnd: endOfMonth.toString(),
        );

      case "This Year":
        // Start: Jan 1st | End: Dec 31st
        DateTime startOfYear = DateTime(now.year, 1, 1);
        DateTime endOfYear = DateTime(now.year, 12, 31, 23, 59, 59);
        return await MyHistoryReposity.getPatientFrequentlyGoToHistory(
          patientID,
          fieldToLookFor: "timeStamp",
          fieldValueStart: startOfYear.toString(),
          fieldValueEnd: endOfYear.toString(),
        );

      default: // All
        return await MyHistoryReposity.getPatientFrequentlyGoToHistory(
          patientID,
          orderBy: "timeStamp",
        );
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    frequentlyGoToScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MyDimensionAdapter.getWidth(context);
    double height = MyDimensionAdapter.getHeight(context);
    return Container(
      width: width,
      height: height * 0.7,
      // color: Colors.yellow,
      margin: EdgeInsets.only(top: 20, bottom: 30),
      padding: EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // MyLine(
          //   length: width * 0.9,
          //   color: Colors.blue.shade100,
          //   isVertical: false,
          //   isRounded: true,
          // ),
          SizedBox(height: 10),
          MyCustTooltip(
            triggerMode: TooltipTriggerMode.tap,
            message: "You can use these info for something significant.",
            child: MyTextFormatter.h1(
              text: "Frequently Go-To",
              fontWeight: FontWeight.w600,
              fontsize: kDefaultFontSize + 9,
            ),
          ),
          SizedBox(height: 10),
          Container(
            width: width,
            height: height * 0.56,
            // color: Colors.green,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyTextFormatter.p(
                  text: "Filters",
                  fontsize: kDefaultFontSize - 4,
                ),
                Container(
                  height: 45,
                  padding: EdgeInsets.only(bottom: 5),
                  // color: Colors.amber,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      spacing: 4.5,
                      children: [
                        filterButton(withPercentage: 0.15, index: 0),
                        filterButton(withPercentage: 0.2, index: 1),
                        filterButton(withPercentage: 0.26, index: 2),
                        filterButton(withPercentage: 0.28, index: 3),
                        filterButton(withPercentage: 0.3, index: 4),
                        filterButton(withPercentage: 0.27, index: 5),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: FutureBuilder<Map<String, Duration>>(
                    future: calculateTotalTimePerArea(widget.patientID),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (!snapshot.hasData) {
                        return Center(
                          child: MyTextFormatter.p(text: "No History Found"),
                        );
                      } else {
                        final List<MapEntry<String, Duration>> areaList =
                            snapshot.data!.entries.toList();

                        // sort the list based on value in descending order
                        areaList.sort((a, b) {
                          return b.value.compareTo(a.value);
                        });

                        return RawScrollbar(
                          controller: frequentlyGoToScrollController,
                          thumbColor: Colors.blue.shade200,
                          padding: EdgeInsets.only(right: 0, top: 7, bottom: 7),
                          thumbVisibility: true,
                          trackVisibility: true,
                          thickness: 4,
                          radius: Radius.circular(7),
                          child: ListView.builder(
                            padding: EdgeInsets.only(top: 7, bottom: 7),
                            controller: frequentlyGoToScrollController,
                            dragStartBehavior: DragStartBehavior.down,
                            shrinkWrap: true,
                            physics: ScrollPhysics(
                              parent: AlwaysScrollableScrollPhysics(),
                            ),
                            itemCount: areaList.length,
                            itemBuilder: (context, index) {
                              // 4. Extract data using the index
                              String areaName = areaList[index].key;
                              Duration timeSpent = areaList[index].value;

                              return Container(
                                width: MyDimensionAdapter.getWidth(context),
                                height:
                                    MyDimensionAdapter.getHeight(context) *
                                    0.065,
                                margin: EdgeInsets.fromLTRB(2, 1.5, 7, 1.5),
                                decoration: BoxDecoration(
                                  color: (index % 2 == 0)
                                      ? const Color.fromARGB(180, 203, 230, 253)
                                      : Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(7),
                                  border: Border.all(
                                    width: 1.5,
                                    color: (index % 2 == 0)
                                        ? const Color.fromARGB(
                                            180,
                                            180,
                                            220,
                                            255,
                                          )
                                        : const Color.fromARGB(
                                            255,
                                            207,
                                            232,
                                            249,
                                          ),
                                    // color: Colors.white70,
                                  ),
                                  // boxShadow: [
                                  //   BoxShadow(
                                  //     color: Colors.black12,
                                  //     offset: Offset(0, 2),
                                  //     blurStyle: BlurStyle.outer,
                                  //     blurRadius: 4,
                                  //   ),
                                  // ],
                                ),
                                child: Row(
                                  // spacing: 20,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(width: 20),
                                    SizedBox(
                                      width:
                                          MyDimensionAdapter.getWidth(context) *
                                          0.43,
                                      child: MyTextFormatter.p(
                                        text: areaName,
                                        maxLines: 2,
                                      ),
                                    ),
                                    Spacer(),
                                    durationUnitDeterminer(
                                      timeSpent: timeSpent,
                                    ),
                                    SizedBox(width: 20),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  MyCustButton filterButton({
    required int index,
    required double withPercentage,
  }) {
    return MyCustButton(
      buttonText: filterChoices[index],
      buttonTextFontSize: kDefaultFontSize - 2,
      color: (selectedFilter == filterChoices[index])
          ? Colors.blue.shade400
          : Colors.transparent,
      buttonTextColor: (selectedFilter == filterChoices[index])
          ? Colors.white
          : Colors.grey.shade900,
      buttonTextFontWeight: (selectedFilter == filterChoices[index])
          ? FontWeight.w600
          : FontWeight.w400,
      enableShadow: (selectedFilter == filterChoices[index]) ? true : false,
      buttonTextSpacing: 1.2,
      widthPercentage: withPercentage,
      height: 30,
      onTap: () {
        setState(() => selectedFilter = filterChoices[index]);
      },
    );
  }

  /// This will return a corresponding value based on duration equivalent, may it days, hours, mins, secs
  Widget durationUnitDeterminer({required Duration timeSpent}) {
    // DAY
    if (timeSpent.inHours > 24) {
      bool isPlural = timeSpent.inDays > 1;
      return Row(
        children: [
          MyTextFormatter.p(
            text: timeSpent.inDays.toString(),
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade900,
          ),
          MyTextFormatter.p(
            text: (isPlural) ? " days" : " day",
            fontsize: kDefaultFontSize - 1,
          ),
        ],
      );
    }
    // HOUR
    else if (timeSpent.inMinutes > 60) {
      bool isPlural = timeSpent.inHours > 1;
      return Row(
        children: [
          MyTextFormatter.p(
            text: timeSpent.inHours.toString(),
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade900,
          ),
          MyTextFormatter.p(
            text: (isPlural) ? " hours" : " hour",
            fontsize: kDefaultFontSize - 1,
          ),
        ],
      );
    }
    // MINUTES
    else if (timeSpent.inSeconds > 60) {
      bool isPlural = timeSpent.inMinutes > 1;
      return Row(
        children: [
          MyTextFormatter.p(
            text: timeSpent.inMinutes.toString(),
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade900,
          ),
          MyTextFormatter.p(
            text: (isPlural) ? " mins" : " min",
            fontsize: kDefaultFontSize - 1,
          ),
        ],
      );
    }
    // SECONDS
    else {
      bool isPlural = timeSpent.inSeconds > 1;
      return Row(
        children: [
          MyTextFormatter.p(
            text: timeSpent.inSeconds.toString(),
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade900,
          ),
          MyTextFormatter.p(
            text: (isPlural) ? " secs" : " sec",
            fontsize: kDefaultFontSize - 1,
          ),
        ],
      );
    }
  }
}
