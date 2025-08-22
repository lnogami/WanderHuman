import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:wanderhuman_app/utilities/color_palette.dart';
import 'package:wanderhuman_app/utilities/dimension_adapter.dart';
import 'package:wanderhuman_app/view/home/widgets/bottom_modal_sheet.dart';

class HomeAppBar extends StatefulWidget {
  const HomeAppBar({super.key});

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<HomeAppBar> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadiusGeometry.circular(50),
      child: Container(
        width: MyDimensionAdapter.getWidth(context) * 0.80,
        height: 50,
        color: Colors.white70,
        padding: EdgeInsets.only(left: 8, right: 10, top: 5, bottom: 5),
        child: Row(
          children: [
            // the user avatar/pic/icon container
            CircleAvatar(
              backgroundColor: Colors.blue[100],
              child: Icon(Icons.person_rounded, color: Colors.blue),
            ),
            SizedBox(width: 10),
            // greeting text
            SizedBox(
              width: MyDimensionAdapter.getWidth(context) * 0.50,
              child: Text(
                "${dotenv.env['SAMPLE_TEXT']}",
                // "a dnbajbdjab ahbdhjabd ajbdhwbahw abdabhj",
                style: TextStyle(
                  // color: Colors.,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Spacer(),
            // menu button
            InkWell(
              onTap: () => bottomModalSheet(context),
              child: Icon(Icons.menu_rounded, size: 32, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
    // return SliverAppBar(
    //   automaticallyImplyLeading: false,
    //   // leading: Icon(Icons.menu),
    //   leading: Container(
    //     margin: const EdgeInsets.only(left: 20.0, top: 5.0, bottom: 5.0),
    //     child: CircleAvatar(
    //       backgroundColor: Colors.white,
    //       child: Icon(Icons.person, color: Colors.blue),
    //     ),
    //   ),
    //   actions: [
    //     InkWell(
    //       onTap: () {
    //         bottomModalSheet(context);
    //       },
    //       child: Icon(Icons.menu, color: Colors.white60),
    //     ),
    //     SizedBox(width: 20),
    //   ],
    //   title: Text(
    //     // "Hello!",
    //     "${dotenv.env['SAMPLE_TEXT']}",
    //     style: TextStyle(
    //       color: Colors.white,
    //       fontWeight: FontWeight.bold,
    //       letterSpacing: 2.0,
    //     ),
    //   ),
    //   // centerTitle: true,
    //   backgroundColor: Colors.blue,
    //   expandedHeight: MyDimensionAdapter.getHeight(context) * 0.15,
    //   pinned: true,
    //   elevation: 5.0,
    //   forceElevated: true,
    //   flexibleSpace: FlexibleSpaceBar(
    //     background: Container(
    //       margin: const EdgeInsets.only(
    //         top: kToolbarHeight,
    //         left: 20,
    //         right: 20,
    //       ),
    //       padding: EdgeInsets.only(bottom: 5.0),
    //       decoration: BoxDecoration(color: Colors.blue),
    //       child: SingleChildScrollView(
    //         scrollDirection: Axis.vertical,
    //         child: Text(
    //           "Placeholder text hewihhwb akjdbajb ajbdajwbdja abdab ajwbdjkwbaj waa d awbadba dakjbdkaj",
    //         ),
    //       ),
    //     ),
    //     // title: Text(
    //     //   "HOME",
    //     //   style: TextStyle(
    //     //     color: Colors.white,
    //     //     fontWeight: FontWeight.bold,
    //     //     letterSpacing: 2.0,
    //     //   ),
    //     // ),
    //     centerTitle: true,
    //     // titlePadding: EdgeInsets.all(0),
    //   ),
    // );
  }
}
