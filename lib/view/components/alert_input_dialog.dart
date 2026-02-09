// import 'package:flutter/material.dart';
// import 'package:wanderhuman_app/utilities/properties/text_formatter.dart';
// import 'package:wanderhuman_app/view/components/button.dart';
// import 'package:wanderhuman_app/view/components/textfield.dart';

// void myAlerInputDialog({
//   required BuildContext context,
//   required String alertTitle,
//   String? alertContent,
//   required String textFieldLabelText,
//   IconData prefixIcon = Icons.info_outline_rounded,
//   required TextEditingController textController,
//   List<Widget>? actions,
//   String confirmButtonText = "Confirm",
//   VoidCallback? onApprovalPressed,
// }) {
//   showDialog(
//     context: context,
//     builder: (context) {
//       return AlertDialog.adaptive(
//         title: MyTextFormatter.p(
//           text: alertTitle,
//           fontsize: 18,
//           fontWeight: FontWeight.w600,
//         ),
//         content: Column(
//           children: [
//             MyCustTextfield(
//               labelText: textFieldLabelText,
//               prefixIcon: prefixIcon,
//               borderRadius: 7,
//               textController: textController,
//             ),
//             // add some additional actions if needed
//             // if (actions != null && actions.isNotEmpty) ...actions,
//           ],
//         ),
//         actions: [
//           MaterialButton(
//             onPressed: () {
//               Navigator.pop(context);
//             },
//             child: Text("Cancel"),
//           ),
//           MyCustButton(
//             widthPercentage: 0.55,
//             buttonText: confirmButtonText,
//             onTap: onApprovalPressed ?? () {},
//           ),
//         ],
//       );
//     },
//   );
// }
