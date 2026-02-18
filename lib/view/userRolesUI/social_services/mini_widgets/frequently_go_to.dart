import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:wanderhuman_app/helper/history_reposity.dart';
import 'package:wanderhuman_app/model/history_model.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';
import 'package:wanderhuman_app/utilities/properties/text_formatter.dart';

class FrequentlyGoToArea extends StatefulWidget {
  final String patientID;
  const FrequentlyGoToArea({super.key, required this.patientID});

  @override
  State<FrequentlyGoToArea> createState() => _FrequentlyGoToAreaState();
}

class _FrequentlyGoToAreaState extends State<FrequentlyGoToArea> {
  ScrollController frequentlyGoToScrollController = ScrollController();

  Future<Map<String, Duration>> calculateTotalTimePerArea(
    String patientID,
  ) async {
    try {
      Map<String, Duration> totalTimeMap = {};

      // 1. Fetch History sorted by TIME (Crucial!)
      // We need strict chronological order to measure duration.
      List<MyHistoryModel> logs = await MyHistoryReposity.getPatientHistory(
        patientID,
        orderBy: "timeStamp", // Ensure your repo uses this
      );

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

  @override
  void dispose() {
    frequentlyGoToScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MyDimensionAdapter.getWidth(context),
      height: 500,
      margin: EdgeInsets.only(top: 20),
      padding: EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: MyDimensionAdapter.getWidth(context),
            height: 1,
            color: Colors.blue.shade100,
          ),
          SizedBox(height: 20),
          MyTextFormatter.h1(
            text: "Frequently Go-To",
            fontWeight: FontWeight.w600,
            fontsize: kDefaultFontSize + 9,
          ),
          SizedBox(height: 20),
          Container(
            width: MyDimensionAdapter.getWidth(context),
            height: MyDimensionAdapter.getHeight(context) * 0.45,
            // color: Colors.green,
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
                  final List<MapEntry<String, Duration>> areaList = snapshot
                      .data!
                      .entries
                      .toList();

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
                          height: MyDimensionAdapter.getHeight(context) * 0.065,
                          margin: EdgeInsets.fromLTRB(2, 1.5, 6, 1.5),
                          decoration: BoxDecoration(
                            color: (index % 2 == 0)
                                ? const Color.fromARGB(255, 203, 230, 253)
                                : Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(7),
                            border: Border.all(
                              width: 1,
                              color: Colors.blue.shade100,
                            ),
                          ),
                          child: Row(
                            // spacing: 20,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(width: 20),
                              Text(areaName),
                              Spacer(),
                              (timeSpent.inSeconds < 60)
                                  ? Row(
                                      children: [
                                        MyTextFormatter.p(
                                          text: timeSpent.inSeconds.toString(),
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade900,
                                        ),
                                        MyTextFormatter.p(
                                          text: " sec",
                                          fontsize: kDefaultFontSize - 1,
                                        ),
                                      ],
                                    )
                                  : Row(
                                      children: [
                                        MyTextFormatter.p(
                                          text: timeSpent.inMinutes.toString(),
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade900,
                                        ),
                                        MyTextFormatter.p(
                                          text: " min",
                                          fontsize: kDefaultFontSize - 1,
                                        ),
                                      ],
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
    );
  }
}
