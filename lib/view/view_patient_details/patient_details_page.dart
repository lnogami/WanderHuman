import 'package:flutter/material.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';

class PatientDetailsPage extends StatefulWidget {
  final String name;
  const PatientDetailsPage({super.key, required this.name});

  @override
  State<PatientDetailsPage> createState() => _PatientDetailsPageState();
}

class _PatientDetailsPageState extends State<PatientDetailsPage> {
  double headerBarExpandedHeight = 200;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 7, 191, 53),
      body: Container(
        width: MyDimensionAdapter.getWidth(context),
        height: MyDimensionAdapter.getHeight(context),
        color: Colors.purple.shade200,
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
      forceMaterialTransparency: true,
      // backgroundColor: const Color.fromARGB(255, 239, 249, 255),
      title: Container(
        width: MyDimensionAdapter.getWidth(context),
        height: kToolbarHeight,
        decoration: BoxDecoration(
          // color: Colors.amber.withAlpha(100),
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(100),
            topLeft: Radius.circular(10),
            bottomLeft: Radius.circular(10),
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color.fromARGB(255, 209, 234, 255),
              const Color.fromARGB(255, 242, 248, 250),
              Colors.white70,
              Colors.white12,
              // Colors.white10,
              Colors.transparent,
            ],
          ),
        ),
        child: appBarTitleArea(context),
      ),
      centerTitle: true,
      forceElevated: true,
      pinned: true,
      floating: true,
      automaticallyImplyLeading: false,
      // backgroundColor: Colors.green,
      collapsedHeight: kToolbarHeight,
      expandedHeight: headerBarExpandedHeight,
      flexibleSpace: FlexibleSpaceBar(
        // background: Image.asset("assets/icons/isagi.jpg"),
        background: Container(
          decoration: BoxDecoration(
            // color: Colors.blue.withAlpha(200),
            gradient: LinearGradient(
              colors: [
                const Color.fromARGB(255, 209, 234, 255),
                const Color.fromARGB(255, 246, 248, 249),
                Colors.white,
              ],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(15),
              bottomRight: Radius.circular(15),
            ),
          ),
          child: Container(
            // color: Colors.blue,
            child: SafeArea(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    right: -5,
                    child: Container(
                      width: MyDimensionAdapter.getWidth(context) * 0.45,
                      height: headerBarExpandedHeight,
                      // color: Colors.green.withAlpha(100),
                      child: Image.asset(
                        "assets/icons/isagi.jpg",
                        // "assets/icons/longwidth_placeholder.jpg",
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  ),

                  // image's left gradient
                  imageLeftGradient(context),

                  // image's top gradient
                  imageTopGradient(context),

                  // image's bottom gradient
                  imageBottomGradient(context),

                  Positioned(
                    left: 0,
                    child: Container(
                      width: MyDimensionAdapter.getWidth(context) * 0.65,
                      height: MyDimensionAdapter.getHeight(context),
                      // color: Colors.green.withAlpha(100),
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

  Row appBarTitleArea(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.blue),
        ),
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
    );
  }

  Positioned imageBottomGradient(BuildContext context) {
    return Positioned(
      // this is proportionally based on the container widht of the image
      bottom: 0,
      right: 0,
      child: Container(
        width: MyDimensionAdapter.getWidth(context) * 0.44,
        height: 35,
        decoration: BoxDecoration(
          // color: Colors.deepOrange.withAlpha(150),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            stops: [0.0, 0.15, 0.3, 0.6, 1.0],
            colors: [
              Colors.white,
              Colors.white70,
              Colors.white38,
              Colors.white10,
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  Positioned imageTopGradient(BuildContext context) {
    return Positioned(
      // this is proportionally based on the container widht of the image
      top: 0,
      right: 0,
      child: Container(
        width: MyDimensionAdapter.getWidth(context) * 0.44,
        height: 35,
        decoration: BoxDecoration(
          // color: Colors.deepOrange.withAlpha(150),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.1, 0.3, 0.6, 1.0],
            colors: [
              Colors.white,
              Colors.white70,
              Colors.white38,
              Colors.white10,
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  Positioned imageLeftGradient(BuildContext context) {
    return Positioned(
      // this is proportionally based on the container widht of the image
      right: MyDimensionAdapter.getWidth(context) * 0.34,
      child: Container(
        width: MyDimensionAdapter.getWidth(context) * 0.10,
        height: headerBarExpandedHeight,
        decoration: BoxDecoration(
          // color: Colors.deepOrange.withAlpha(150),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            // stops: [0.0, 0.6, 1.0],
            colors: [
              const Color.fromARGB(255, 246, 248, 249),
              const Color.fromARGB(255, 247, 248, 249),
              // Colors.white,
              //   Colors.white,
              // Colors.white70,
              Colors.white54,
              Colors.white24,
              Colors.white10,
              Colors.transparent,
            ],
          ),
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

  // SizedBox expandedPatientDemographicHeader(BuildContext context) {
  //   return SizedBox(
  //     width: MyDimensionAdapter.getWidth(context),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.end,
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       children: [
  //         // SizedBox(width: 13),
  //         Spacer(),
  //         Image.asset(
  //           "assets/icons/isagi.jpg",
  //           height: MyDimensionAdapter.getHeight(context) * 0.15,
  //         ),
  //         SizedBox(width: 12),
  //       ],
  //     ),
  //   );
  // }
}
