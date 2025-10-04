import 'package:flutter/material.dart';
import 'package:wanderhuman_app/utilities/dimension_adapter.dart';

class PatientDetailsPage extends StatefulWidget {
  final String name;
  const PatientDetailsPage({super.key, required this.name});

  @override
  State<PatientDetailsPage> createState() => _PatientDetailsPageState();
}

class _PatientDetailsPageState extends State<PatientDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 212, 212, 212),
      body: Container(
        width: MyDimensionAdapter.getWidth(context),
        height: MyDimensionAdapter.getHeight(context),
        color: Colors.amber,
        child: CustomScrollView(
          slivers: [
            appBar(context),
            SliverList(
              delegate: SliverChildBuilderDelegate(childCount: 15, (
                builder,
                index,
              ) {
                return Container(
                  width: 200,
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                  ),
                  padding: EdgeInsets.only(bottom: 20),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  SliverAppBar appBar(BuildContext context) {
    return SliverAppBar(
      primary: true,
      actionsPadding: EdgeInsets.all(0),
      title: Container(
        width: MyDimensionAdapter.getWidth(context),
        height: kToolbarHeight,
        color: Colors.amber.withAlpha(100),
        child: Row(
          children: [
            Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            SizedBox(width: 15),
            SizedBox(
              // color: Colors.grey,
              width: MyDimensionAdapter.getWidth(context) * 0.63,
              child: Text(
                widget.name, // the name of the patient
                // "Hellooooooooooooooooooooooooooo",
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
      centerTitle: true,
      forceElevated: true,
      pinned: true,
      floating: true,
      automaticallyImplyLeading: false,
      // backgroundColor: Colors.green,
      collapsedHeight: kToolbarHeight,
      expandedHeight: 200,
      flexibleSpace: FlexibleSpaceBar(
        // background: Image.asset("assets/icons/isagi.jpg"),
        background: Container(
          decoration: BoxDecoration(
            color: Colors.blue.withAlpha(200),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(15),
              bottomRight: Radius.circular(15),
            ),
          ),
          child: Container(
            color: Colors.blue,
            child: SafeArea(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    right: -5,
                    child: Container(
                      width: MyDimensionAdapter.getWidth(context) * 0.45,
                      height: MyDimensionAdapter.getHeight(context),
                      // color: Colors.green.withAlpha(100),
                      child: Image.asset(
                        "assets/icons/isagi.jpg",
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    child: Container(
                      width: MyDimensionAdapter.getWidth(context) * 0.65,
                      height: MyDimensionAdapter.getHeight(context),
                      color: Colors.green.withAlpha(100),
                    ),
                  ),
                ],
              ),
              // child: Row(
              //   children: [
              //     Flexible(
              //       flex: 2,
              //       child: Column(
              //         children: [
              //           Expanded(child: Container(color: Colors.green)),
              //         ],
              //       ),
              //     ),
              //     Flexible(
              //       flex: 1,
              //       child: Column(
              //         children: [
              //           // displays name and avatar
              //           expandedPatientDemographicHeader(context),
              //         ],
              //       ),
              //     ),
              //   ],
              // ),
            ),
          ),
          // ),
        ),
      ),
    );
  }

  // Container collapsedPatientDemographicHeader(BuildContext context) {
  //   return Container(
  //     color: Colors.amber,
  //     width: MyDimensionAdapter.getWidth(context),
  //     height: kToolbarHeight,
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.start,
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       children: [
  //         SizedBox(width: 13),
  //         Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
  //         SizedBox(width: 15),
  //         SizedBox(
  //           // color: Colors.grey,
  //           width: MyDimensionAdapter.getWidth(context) * 0.63,
  //           child: Text(
  //             widget.name, // the name of the patient
  //             // "Hellooooooooooooooooooooooooooo",
  //             overflow: TextOverflow.ellipsis,
  //             style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
  //           ),
  //         ),
  //         Spacer(),
  //         Expanded(child: CircleAvatar(backgroundColor: Colors.white)),
  //         SizedBox(width: 12),
  //       ],
  //     ),
  //   );
  // }

  SizedBox expandedPatientDemographicHeader(BuildContext context) {
    return SizedBox(
      width: MyDimensionAdapter.getWidth(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // SizedBox(width: 13),
          Spacer(),
          Image.asset(
            "assets/icons/isagi.jpg",
            height: MyDimensionAdapter.getHeight(context) * 0.15,
          ),
          SizedBox(width: 12),
        ],
      ),
    );
  }
}
