// import 'package:flutter/material.dart';
// import 'package:wanderhuman_app/utilities/properties/color_palette.dart';
// import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';
// import 'package:wanderhuman_app/utilities/properties/text_formatter.dart';
// import 'package:wanderhuman_app/view/components/image_displayer.dart';
// import 'package:wanderhuman_app/view/components/image_picker.dart';

// class MySocialServiceCardInfoDisplayer extends StatelessWidget {
//   final VoidCallback? onTap;
//   final VoidCallback? onLongPress;
//   final String profilePicture;
//   // acts as the title of the card
//   final String name;
//   // acts as the subtitle of the card
//   final String role;
//   // acts as the description/additional info of the card
//   final String contactNumber;
//   final String emailAdd;
//   const MySocialServiceCardInfoDisplayer({
//     super.key,
//     this.onTap,
//     this.onLongPress,
//     required this.name,
//     required this.role,
//     required this.contactNumber,
//     this.emailAdd = "No Email",
//     required this.profilePicture,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap ?? () {},
//       onLongPress: onLongPress ?? () {},
//       child: Container(
//         width: MyDimensionAdapter.getWidth(context) * 0.85,
//         height: MyDimensionAdapter.getHeight(context) * 0.145,
//         margin: EdgeInsets.only(top: 5, bottom: 5),
//         decoration: BoxDecoration(
//           color: Colors.white70,
//           borderRadius: BorderRadius.circular(10),
//           border: BoxBorder.all(color: Colors.white, width: 1.5),
//           boxShadow: [
//             BoxShadow(
//               color: const Color.fromARGB(56, 96, 181, 252),
//               blurRadius: 4,
//               // spreadRadius: 1,
//               offset: Offset(2, 2),
//             ),
//           ],
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [profilePictureArea(context), informationArea(context)],
//         ),
//       ),
//     );
//   }

//   ClipRRect profilePictureArea(BuildContext context) {
//     return ClipRRect(
//       borderRadius: BorderRadiusGeometry.only(
//         topLeft: Radius.circular(8),
//         bottomLeft: Radius.circular(8),
//       ),
//       child: Container(
//         width: MyDimensionAdapter.getWidth(context) * 0.25,
//         height: MyDimensionAdapter.getHeight(context),
//         margin: EdgeInsets.only(left: 20),
//         padding: EdgeInsets.only(top: 12, bottom: 12, left: 5, right: 7),
//         // color: Colors.blue,
//         child: CircleAvatar(
//           // radius: 10,
//           backgroundColor: const Color.fromARGB(179, 255, 255, 255),
//           child: MyImageDisplayer(
//             profileImageSize: 80,
//             base64ImageString: MyImageProcessor.decodeStringToUint8List(
//               profilePicture,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Expanded informationArea(BuildContext context) {
//     return Expanded(
//       child: ClipRRect(
//         borderRadius: BorderRadiusGeometry.only(
//           topRight: Radius.circular(8),
//           bottomRight: Radius.circular(8),
//         ),
//         child: Container(
//           width: MyDimensionAdapter.getWidth(context) * 0.25,
//           height: MyDimensionAdapter.getHeight(context),
//           padding: EdgeInsets.only(left: 10, right: 20),
//           // color: Colors.green,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               MyTextFormatter.h3(
//                 text: name,
//                 // fontsize: kDefaultFontSize + 2,
//                 fontWeight: FontWeight.w600,
//               ),
//               Container(
//                 width: MyDimensionAdapter.getWidth(context),
//                 height: 1,
//                 margin: EdgeInsets.only(top: 5, bottom: 5),
//                 color: MyColorPalette.lightBlue,
//               ),
//               MyTextFormatter.h5(text: role),
//               Text(
//                 emailAdd,
//                 overflow: TextOverflow.ellipsis,
//                 style: TextStyle(
//                   fontSize: (kDefaultFontSize - 1),
//                   // color: Colors.blue.shade400,
//                 ),
//               ),
//               Row(
//                 children: [
//                   Text(
//                     contactNumber,
//                     style: TextStyle(
//                       fontSize: (kDefaultFontSize - 1),
//                       // color: Colors.blue.shade400,
//                     ),
//                   ),
//                   Spacer(),
//                   CircleAvatar(backgroundColor: Colors.green, radius: 5),
//                   SizedBox(width: 2.5),
//                   MyTextFormatter.p(
//                     text: "Active",
//                     fontsize: kDefaultFontSize - 1,
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
