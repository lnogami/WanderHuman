// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:wanderhuman_app/utilities/properties/date_formatter.dart';
// import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';
// import 'package:wanderhuman_app/utilities/properties/text_formatter.dart';

// class MyDateTimeTimerHeader extends StatefulWidget {
//   final String? dateTime;
//   const MyDateTimeTimerHeader({super.key, this.dateTime});

//   @override
//   State<MyDateTimeTimerHeader> createState() => _MyDateTimeTimerHeaderState();
// }

// class _MyDateTimeTimerHeaderState extends State<MyDateTimeTimerHeader> {
//   String? currentDateTime;
//   int seconds = 5;
//   // Timer? _timer;

//   @override
//   void initState() {
//     super.initState();
//     currentDateTime = widget.dateTime ?? DateTime.now().toString();
//     startTimer();
//   }

//   void startTimer() {
//     String timeNow = MyDateFormatter.formatDate(
//       dateTimeInString: currentDateTime!,
//       formatOptions: 6,
//     );
//     String timeToCompare = MyDateFormatter.formatDate(
//       dateTimeInString: DateTime.now(),
//       formatOptions: 6,
//     );

//     Timer.periodic(Duration(seconds: seconds), (timer) {
//       if (timeNow != timeToCompare) {
//         if (mounted) {
//           setState(() {
//             seconds = 60;
//             currentDateTime = DateTime.now().toString();
//           });
//         }
//         print("Timeeeeeeee: $currentDateTime");
//       }
//     });
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: MyDimensionAdapter.getWidth(context) * 0.85,
//       margin: EdgeInsets.only(bottom: 30),
//       padding: EdgeInsets.only(bottom: 7),
//       decoration: BoxDecoration(
//         color: Colors.blue.shade50,
//         borderRadius: BorderRadius.all(Radius.circular(7)),
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.baseline,
//             textBaseline: TextBaseline.alphabetic,
//             children: [
//               MyTextFormatter.p(
//                 text: "Today is ",
//                 fontsize: kDefaultFontSize + 1,
//               ),
//               MyTextFormatter.p(
//                 text: MyDateFormatter.formatDate(
//                   dateTimeInString: DateTime.now(),
//                   formatOptions: 7,
//                   customedFormat: "EEEE",
//                 ),
//                 fontsize: kDefaultFontSize + 7,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.blue.shade500,
//               ),
//             ],
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.baseline,
//             textBaseline: TextBaseline.alphabetic,
//             children: [
//               MyTextFormatter.p(
//                 text: MyDateFormatter.formatDate(
//                   dateTimeInString: currentDateTime,
//                   formatOptions: 7,
//                   customedFormat: "MMM d",
//                 ),
//                 fontsize: kDefaultFontSize + 5,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.blue.shade400,
//               ),
//               MyTextFormatter.p(text: ", "),
//               MyTextFormatter.p(
//                 text:
//                     "${MyDateFormatter.formatDate(dateTimeInString: currentDateTime, formatOptions: 7, customedFormat: "y")}  ",
//                 fontsize: kDefaultFontSize + 2,
//                 // color: Colors.blue.shade400,
//               ),
//               MyTextFormatter.p(
//                 text:
//                     "${MyDateFormatter.formatDate(dateTimeInString: currentDateTime, formatOptions: 7, customedFormat: "hh:mm")} ",
//                 fontsize: kDefaultFontSize + 5,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.blue.shade400,
//               ),
//               MyTextFormatter.p(
//                 text:
//                     "${MyDateFormatter.formatDate(dateTimeInString: currentDateTime, formatOptions: 7, customedFormat: "a")} ",
//                 fontsize: kDefaultFontSize + 2,
//                 // color: Colors.blue.shade400,
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
