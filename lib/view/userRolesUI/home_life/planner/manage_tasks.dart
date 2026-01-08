import 'package:flutter/material.dart';
import 'package:wanderhuman_app/utilities/properties/color_palette.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';
import 'package:wanderhuman_app/view/components/appbar.dart';
import 'package:wanderhuman_app/view/components/page_navigator.dart';
import 'package:wanderhuman_app/view/userRolesUI/home_life/planner/task_card.dart';

class HomeLifeManageTask extends StatefulWidget {
  const HomeLifeManageTask({super.key});

  @override
  State<HomeLifeManageTask> createState() => _HomeLifeManageTaskState();
}

class _HomeLifeManageTaskState extends State<HomeLifeManageTask> {
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
                  Navigator.pop(context);
                  MyNavigator.goTo(context, HomeLifeManageTask());
                },
              ),

              body(context),

              floatingButton(onTap: () {}),
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
        child: ListView.builder(
          itemCount: 10,
          itemBuilder: (context, index) {
            return TaskCard();
          },
        ),
      ),
    );
  }

  Positioned floatingButton({required VoidCallback onTap}) {
    return Positioned(
      right: 50,
      bottom: 50,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.blue.shade400,
            borderRadius: BorderRadius.circular(7),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(100, 1, 106, 203),
                blurRadius: 4,
                offset: Offset(0, 2),
                blurStyle: BlurStyle.normal,
              ),
              // BoxShadow(
              //   color: Colors.white70,
              //   blurRadius: 10,
              //   offset: Offset(0, 4),
              //   blurStyle: BlurStyle.inner,
              // ),
            ],
          ),
          child: Icon(Icons.add_outlined, color: Colors.white, size: 32),
        ),
      ),
    );
  }
}
