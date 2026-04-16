import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wanderhuman_app/helper/home_life_repository.dart';
import 'package:wanderhuman_app/model/home_life_models/task_model.dart';
import 'package:wanderhuman_app/model/personal_info.dart';
import 'package:wanderhuman_app/utilities/properties/date_formatter.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';
import 'package:wanderhuman_app/utilities/properties/text_formatter.dart';
import 'package:wanderhuman_app/view-model/home_active_persons_provider.dart';
import 'package:wanderhuman_app/view-model/home_appbar_provider.dart';
import 'package:wanderhuman_app/view/components/dropdown_button.dart';
import 'package:wanderhuman_app/view/components/page_navigator.dart';
import 'package:wanderhuman_app/view/components/tooltip.dart';
import 'package:wanderhuman_app/view/userRolesUI/home_life/individual_tasks/individual_task_card.dart';
import 'package:wanderhuman_app/view/userRolesUI/patient/patient_details_page.dart';
import 'package:wanderhuman_app/view/userRolesUI/patient/tabs.dart';

class CaregiverTasks extends StatefulWidget {
  final PersonalInfo patientInfo;

  const CaregiverTasks({super.key, required this.patientInfo});

  @override
  State<CaregiverTasks> createState() => _CaregiverTasks();
}

class _CaregiverTasks extends State<CaregiverTasks> {
  String loggedInUserType = "";

  /// This function is for refreshing this page if it is the veryyy first time opening it for the day.
  Future<void> refreshPageWhenFirstTimeOpeningThisPage() async {
    // this will automate the process of creating the tasks per patients for the day
    bool firstTimeOpeningThePageToday =
        await HomeLifeRepository.createDailyRecord(
          dateID: MyDateFormatter.formatDate(
            dateTimeInString: DateTime.now().toString(),
          ),
        );
    // if there is at least one homelife staff to open this page for the first time for the day,
    //    this page needs to refresh as it wont display anything because the automation of
    //    Task registration to the database happens during the first opening of this page.
    if (firstTimeOpeningThePageToday && mounted) {
      Navigator.pop(context);
      MyNavigator.goTo(
        context,
        // CaregiverTasks(patientInfo: widget.patientInfo),
        // MyTabBar(
        //   patient: widget.patientInfo,
        //   width: MyDimensionAdapter.getWidth(context),
        //   height: MyDimensionAdapter.getHeight(context),
        // ),
        PatientDetailsPage(
          personalInfo: widget.patientInfo,
          batteryPercentage:
              context
                  .read<MyHomeActivePersonsProvider>()
                  .devicesBattery[widget.patientInfo.userID] ??
              0,
        ),
      );

      // setState(() {});
    }
  }

  /// Will contain all the days to display as options
  List<String> allDaysToDisplayOptions = ["All Dates"];

  /// Selected option, by default it is set today
  String selectedDayToDisplay = MyDateFormatter.formatDate(
    dateTimeInString: DateTime.now().toString(),
  );

  /// This is for the loading animation, like what FutureBuilder is doing under the hood
  bool isDropdownLoading = true;

  /// Load all days
  Future<void> getDaysToDisplayInDropdown() async {
    List<String> days = await HomeLifeRepository.getAllDaysOfRecordedTasks(
      widget.patientInfo.userID,
    );
    days.sort((a, b) {
      DateTime dateA = DateTime.parse(
        MyDateFormatter.formatDate(
          dateTimeInString: a,
          formatOptions: 7,
          customedFormat: "yyyy-MM-dd",
        ),
      );
      DateTime dateB = DateTime.parse(
        MyDateFormatter.formatDate(
          dateTimeInString: b,
          formatOptions: 7,
          customedFormat: "yyyy-MM-dd",
        ),
      );
      return dateA.compareTo(dateB);
    });

    setState(() {
      allDaysToDisplayOptions.addAll(days.reversed);
      // why [1]? because [0] is All, and today's date is the [1]
      selectedDayToDisplay = allDaysToDisplayOptions[1];
      isDropdownLoading = false;
    });
  }

  /// This is relative to the FutureBuilder for displaying the task of a specific day.
  Future<List<HLTaskModel>> pageDisplayOptions(String option) {
    switch (option) {
      case "All Dates":
        // temporary pa ni
        // return HomeLifeRepository.getIndividualPatientTasks(
        //   dateID: MyDateFormatter.formatDate(
        //     dateTimeInString: DateTime.now().toString(),
        //   ),
        //   participantID: widget.patientInfo.userID,
        // );
        print("ALL HAS BEEN SELECTEDDDDDDDDDDDDDDDDDDD");
        return HomeLifeRepository.getAllIndividualPatientTasks(
          dateID:
              "Jan 12, 2026", // this is just a dummy date, the date parameter will not be used in the backend when fetching all tasks, so it can be anything
          participantID: widget.patientInfo.userID,
        );
      default:
        print("$option HAS BEEN SELECTEDDDDDDDDDDDDDDDDDDD");
        return HomeLifeRepository.getIndividualPatientTasks(
          dateID: option,
          participantID: widget.patientInfo.userID,
        );
    }
  }

  @override
  void initState() {
    super.initState();
    // this will create the tasks once a day, and at the same time it will reload this page to simulate a reshing animation
    refreshPageWhenFirstTimeOpeningThisPage();
    // this will load the days to display as options in the dropdown menu
    getDaysToDisplayInDropdown();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    loggedInUserType = context
        .read<HomeAppBarProvider>()
        .loggedInUserData
        .userType;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: MyDimensionAdapter.getWidth(context),
          child: Column(
            children: [
              appBar(context),
              SizedBox(height: 10),

              // BODY
              Expanded(
                child: Container(
                  width: MyDimensionAdapter.getWidth(context) * 0.8,
                  // height: MyDimensionAdapter.getHeight(context) * 0.715,
                  margin: EdgeInsets.only(bottom: 7),
                  // color: Colors.amber,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      MyTextFormatter.p(
                        text: "Display Options",
                        fontsize: kDefaultFontSize - 2,
                      ),
                      SizedBox(height: 4),
                      (isDropdownLoading)
                          ? CircularProgressIndicator()
                          : Container(
                              width: MyDimensionAdapter.getWidth(context) * 0.8,
                              // height: MyDimensionAdapter.getHeight(context) * 0.07,
                              // color: Colors.white,
                              child: MyDropdownMenuButton(
                                items: allDaysToDisplayOptions,
                                initialValue: selectedDayToDisplay,
                                isLeadingIconVisible: false,
                                onChanged: (value) {
                                  setState(() {
                                    selectedDayToDisplay = value!;
                                  });
                                },
                              ),
                            ),
                      // Tasks area
                      Expanded(
                        child: Container(
                          width: MyDimensionAdapter.getWidth(context) * 0.8,
                          height: MyDimensionAdapter.getHeight(context) * 0.56,
                          // color: Colors.green,
                          child: (isDropdownLoading)
                              ? Center(
                                  child: CircularProgressIndicator.adaptive(),
                                )
                              : FutureBuilder(
                                  future: pageDisplayOptions(
                                    selectedDayToDisplay,
                                  ),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    } else if (snapshot.data!.isEmpty) {
                                      return Center(
                                        child: MyTextFormatter.p(
                                          text:
                                              "No Tasks for ${widget.patientInfo.name.trim()} on this day.\n\n",
                                          maxLines: 2,
                                        ),
                                      );
                                    }
                                    // this is where data is displayed
                                    else {
                                      if (selectedDayToDisplay == "All Dates") {
                                        return listViewBuilderThatCatersAllDates(
                                          snapshot,
                                        );
                                      }
                                      // specific dates are catered here
                                      else {
                                        return ListView.builder(
                                          itemCount: snapshot.data?.length ?? 0,
                                          itemBuilder: (context, index) {
                                            return IndividualTaskCard(
                                              // // ✅ FIX: Add a unique Key!
                                              // // This forces Flutter to rebuild the card from scratch when the date changes.
                                              // key: ValueKey(
                                              //   "${widget.patientInfo.userID}_$selectedDayToDisplay",
                                              // ),
                                              dateID: selectedDayToDisplay,
                                              participantID:
                                                  widget.patientInfo.userID,
                                              plannedTask:
                                                  snapshot.data![index],
                                              isAccessedByHomeLifeStaff:
                                                  loggedInUserType ==
                                                  "Home Life",
                                            );
                                          },
                                        );
                                      }
                                    }
                                  },
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

  MyCustTooltip appBar(BuildContext context) {
    // return MyCustTooltip(
    //   message: "Tasks for ${widget.patientInfo.name}",
    //   triggerMode: TooltipTriggerMode.tap,
    //   opacity: 200,
    //   child: MyCustAppBar(
    //     title: "Tasks for ${widget.patientInfo.name}",
    //     // // newly added, not yet final
    //     // color: Colors.blue.shade200,
    //     // textColor: Colors.white,
    //     // backButtonColor: Colors.white70,
    //     //
    //     backButton: () {
    //       Navigator.pop(context);
    //       Navigator.pop(context);
    //       MyNavigator.goTo(
    //         context,
    //         // IndividualTasks(patientInfo: widget.patientInfo),
    //         HomeLifePatientRecords(),
    //       );
    //     },
    //   ),
    // );

    return MyCustTooltip(
      message: "These are the tasks for ${widget.patientInfo.name}.",
      triggerMode: TooltipTriggerMode.tap,
      heightConstraints: 90,
      duration: 3000,
      child: MyTextFormatter.h3(
        text: "Home Life Tasks",
        fontsize: kDefaultFontSize + 9,
        lineHeight: 1,
      ),
    );
  }

  ListView listViewBuilderThatCatersAllDates(
    // AsyncSnapshot<List<HLTaskModel>> rawSnapshot,
    AsyncSnapshot<List<HLTaskModel>> snapshot,
  ) {
    // rawSnapshot.data?.sort((a,b){
    //   return a..compareTo(b.createdAt!);
    // });

    return ListView.builder(
      itemCount: snapshot.data?.length ?? 0,
      itemBuilder: (context, index) {
        final task = snapshot.data![index];

        // 1. Get Current Date
        String currentDate = task.createdAt!;

        // 2. Get Previous Date (Safe check)
        String previousDate = "";
        // if the date of the current task is not the same as the previous task then store it as the previous date
        if (index > 0) {
          previousDate = snapshot.data![index - 1].createdAt!;
        }

        // 3. Compare: Show header if it's the very first item OR date changed
        bool showHeader = (index == 0) || (currentDate != previousDate);

        // 4. Return the UI
        if (showHeader) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // The Header Design
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 0, 10),
                child: Row(
                  children: [
                    MyTextFormatter.h3(
                      text: currentDate,
                      color: Colors.grey.shade600,
                      fontsize: kDefaultFontSize + 2,
                    ),
                    if (isTheDateToday(currentDate))
                      MyTextFormatter.h3(
                        text: "  (Today)",
                        color: Colors.blue.shade400,
                        fontsize: kDefaultFontSize + 1,
                      ),
                  ],
                ),
              ),
              // The Task
              IndividualTaskCard(
                key: ValueKey("${task.taskID}_$selectedDayToDisplay"),
                dateID: currentDate,
                participantID: widget.patientInfo.userID,
                plannedTask: task,
                isAccessedByHomeLifeStaff: loggedInUserType == "Home Life",
              ),
            ],
          );
        } else {
          // Just the Task (No Header)
          return IndividualTaskCard(
            key: ValueKey("${task.taskID}_$selectedDayToDisplay"),
            dateID: currentDate,
            participantID: widget.patientInfo.userID,
            plannedTask: task,
            isAccessedByHomeLifeStaff: loggedInUserType == "Home Life",
          );
        }
      },
    );
  }

  /// This method is ssociated with listViewBuilderThatCatersAllDates
  bool isTheDateToday(String dateToCompare) {
    return MyDateFormatter.formatDate(
          dateTimeInString: DateTime.now().toString(),
        ) ==
        dateToCompare;
  }
}
