import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wanderhuman_app/helper/hl_planner_repository.dart';
import 'package:wanderhuman_app/model/home_life_models/hl_planner_model.dart';
import 'package:wanderhuman_app/utilities/properties/color_palette.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';
import 'package:wanderhuman_app/view/components/alert_dialogue.dart';
import 'package:wanderhuman_app/view/components/appbar.dart';
import 'package:wanderhuman_app/view/components/info_dialogue.dart';
import 'package:wanderhuman_app/view/components/page_navigator.dart';
import 'package:wanderhuman_app/view/components/my_animated_snackbar.dart';
import 'package:wanderhuman_app/view/userRolesUI/home_life/planner/planner.dart';
import 'package:wanderhuman_app/view/userRolesUI/home_life/planner/planner_task_card.dart';

class HomeLifeManageTask extends StatefulWidget {
  const HomeLifeManageTask({super.key});

  @override
  State<HomeLifeManageTask> createState() => _HomeLifeManageTaskState();
}

class _HomeLifeManageTaskState extends State<HomeLifeManageTask> {
  Future<List<HomeLifePlannerModel>> getTasks() async {
    List<HomeLifePlannerModel> tasks =
        await HomeLifePlannerRepository.getAllTasks();

    // // sort by createdAt
    // tasks.sort((a, b) {
    //   return a.createdAt.compareTo(b.createdAt);
    // });

    // sort by taskName
    tasks.sort((a, b) {
      return a.taskName.compareTo(b.taskName);
    });
    print("TASKSSSSSSSSSSSSSSSSSS: ${tasks.length}");
    return tasks.reversed.toList();

    // print("TASKSSSSSSSSSSSSSSSSSS: ${tasks.length}");
    // return tasks;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColorPalette.formColor,
      body: SafeArea(
        child: Container(
          width: MyDimensionAdapter.getWidth(context),
          height: MyDimensionAdapter.getHeight(context),
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              MyCustAppBar(
                title: "Manage Tasks",
                backButton: () {
                  Navigator.pop(context);
                  // the 2 lines below are for debugging purposes only
                  // Navigator.pop(context);
                  // MyNavigator.goTo(context, HomeLifeManageTask());
                },
                actionButtons: [
                  GestureDetector(
                    onTap: () {
                      MyNavigator.goTo(context, HomeLifePlanner());
                    },
                    child: Icon(
                      Icons.add_rounded,
                      color: Colors.blue.shade300,
                      size: 32,
                    ),
                  ),
                  // IconButton(
                  //   onPressed: () {},
                  //   iconSize: 32,
                  //   // splashRadius: 24,
                  //   splashColor: MyColorPalette.splashColor,
                  //   icon: Icon(
                  //     Icons.add_rounded,
                  //     color: Colors.blue.shade300,
                  //     // size: 32,
                  //   ),
                  // ),
                  SizedBox(width: 5),
                ],
              ),

              body(context),

              // floatingButton(
              //   onTap: () {
              //     MyNavigator.goTo(context, HomeLifePlanner());
              //   },
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Positioned body(BuildContext context) {
    return Positioned(
      top: kToolbarHeight,
      child: Container(
        width: MyDimensionAdapter.getWidth(context) * 0.8,
        height: MyDimensionAdapter.getHeight(context) * 0.9,
        // color: Colors.amber.shade100,
        child: FutureBuilder(
          future: getTasks(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator.adaptive());
            } else if (snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  "No Task Found . .\n\nCreate Tasks\nPress the + icon above.\n\n\n\n",
                ),
              );
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      MyNavigator.goTo(
                        context,
                        HomeLifePlanner(plannedTask: snapshot.data![index]),
                      );
                    },
                    onLongPress: () {
                      if (FirebaseAuth.instance.currentUser!.uid ==
                          snapshot.data![index].createdBy) {
                        myAlertDialogue(
                          context: context,
                          alertTitle:
                              "Delete ${snapshot.data![index].taskName}?",
                          alertContent:
                              "You created this task, are you sure you want to delete this task?",
                          onApprovalPressed: () {
                            Future.delayed(Duration(milliseconds: 800), () {
                              HomeLifePlannerRepository.deleteTask(
                                participantID:
                                    snapshot.data![index].participants,
                                taskID: snapshot.data![index].taskID,
                              );
                            });
                            // Navigator.pop(context);
                            myInfoDialogue(
                              context: context,
                              alertTitle: "Notice",
                              alertContent:
                                  "The Task '${snapshot.data![index].taskName}' was Successfuly Deleted!",
                              onPress: () {
                                // to simulate a refreshing interface
                                Navigator.pop(context);
                                Navigator.pop(context);
                                Navigator.pop(context);
                                MyNavigator.goTo(context, HomeLifeManageTask());
                              },
                            );
                          },
                        );
                      } else {
                        showMyAnimatedSnackBar(
                          context: context,
                          dataToDisplay:
                              "You did not created this task, therefore you cannot delete it.",
                        );
                      }
                    },
                    child: TaskCard(task: snapshot.data![index]),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  // Positioned floatingButton({required VoidCallback onTap}) {
  //   return Positioned(
  //     right: 50,
  //     bottom: 50,
  //     child: GestureDetector(
  //       onTap: onTap,
  //       child: Container(
  //         width: 60,
  //         height: 60,
  //         decoration: BoxDecoration(
  //           color: const Color.fromARGB(100, 66, 164, 245),
  //           borderRadius: BorderRadius.circular(50),
  //           border: Border.all(color: Colors.white60, width: 2),
  //           boxShadow: [
  //             BoxShadow(
  //               color: const Color.fromARGB(80, 1, 100, 200),
  //               blurRadius: 4,
  //               offset: Offset(0, 2),
  //               blurStyle: BlurStyle.normal,
  //             ),
  //             // BoxShadow(
  //             //   color: Colors.white70,
  //             //   blurRadius: 10,
  //             //   offset: Offset(0, 4),
  //             //   blurStyle: BlurStyle.inner,
  //             // ),
  //           ],
  //         ),
  //         child: Icon(Icons.add_rounded, color: Colors.white, size: 32),
  //       ),
  //     ),
  //   );
  // }
}
