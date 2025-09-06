// import 'package:flutter/material.dart';
// import 'package:wanderhuman_app/view/add_patient_form/add_patient_form.dart';

// // ignore: must_be_immutable
// class MyCustGenderRadioButton extends StatefulWidget {
//   final Sex value;
//   final String title;
//   String finalValueRetriever;
//   MyCustGenderRadioButton({
//     super.key,
//     required this.value,
//     required this.title,
//     required this.finalValueRetriever,
//   });

//   @override
//   State<MyCustGenderRadioButton> createState() =>
//       MyCustGenderRadioButtonState();
// }

// class MyCustGenderRadioButtonState extends State<MyCustGenderRadioButton> {
//   Sex? currentGroupValue;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: RadioListTile.adaptive(
//         title: Text(widget.title),
//         // tileColor: Colors.amber,
//         value: widget.value,
//         groupValue: currentGroupValue,
//         onChanged: (value) {
//           setState(() {
//             currentGroupValue = value!;
//             widget.finalValueRetriever = value.toString();
//           });
//         },
//       ),
//     );
//   }
// }
