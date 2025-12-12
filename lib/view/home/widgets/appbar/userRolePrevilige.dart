import 'package:flutter/material.dart';
import 'package:wanderhuman_app/helper/personal_info_repository.dart';
import 'package:wanderhuman_app/view/home/widgets/appbar/userPriviligeOptions.dart/admin.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';

class MyUserRolePrevilige extends StatelessWidget {
  const MyUserRolePrevilige({super.key});

  @override
  Widget build(BuildContext context) {
    switch (MyPersonalInfoRepository.getUserType()) {
      case "admin":
        return AdminPrivilege();

      case "":
        return AdminPrivilege();

      default:
        {
          return Container(
            height: MyDimensionAdapter.getHeight(context) * 0.06,
            child: Center(child: Text("Oops..Something Went Wrong!!")),
          );
        }
    }
  }
}

// Container userRolePrivilege(BuildContext context) {
//   return Container(
//     child: Column(
//       children: [
//         // admin exclusive options
//         (MyFirebaseServices.getUserType() == "admin")
//             ? Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: [
//                   SizedBox(height: 10),
//                   optionsContainer(
//                     context,
//                     Icons.person_pin_circle_outlined,
//                     bgColor: Colors.green[300]!,
//                     "Simulate",
//                     onTap: () {
//                       //
//                       // Navigator.pop(context);
//                       Navigator.of(context).pushReplacement(
//                         MaterialPageRoute(
//                           builder: (context) => PatientSimulatorContainer(),
//                         ),
//                       );
//                     },
//                   ),
//                   SizedBox(height: 10),
//                   optionsContainer(
//                     context,
//                     Icons.add_outlined,
//                     "Placeholder",
//                     onTap: () {
//                       showMyAnimatedSnackBar(
//                         context: context,
//                         dataToDisplay: "Admin Privilege",
//                       );
//                     },
//                   ),
//                   SizedBox(height: 10),
//                 ],
//               )
//             : SizedBox(height: 0),

//         SizedBox(height: MySizes.buttonsHorizontalGap),

//         // buttons/options
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             SizedBox(height: 10),
//             optionsContainer(
//               context,
//               Icons.person_outline_rounded,
//               "Acount",
//               onTap: () {
//                 MyFirebaseServices.getAllPersonalInfoRecords()
//                     .then((value) {
//                       showMyAnimatedSnackBar(
//                         context: context,
//                         dataToDisplay: "${value.length}",
//                       );
//                     })
//                     .catchError((error) {
//                       showMyAnimatedSnackBar(
//                         context: context,
//                         dataToDisplay: error.toString(),
//                       );
//                     });
//               },
//             ),
//             SizedBox(height: 10),
//             optionsContainer(
//               context,
//               Icons.add_outlined,
//               "Add Patient",
//               onTap: () {
//                 AddPatientForm();
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => AddPatientForm()),
//                 );
//               },
//             ),
//             SizedBox(height: 10),
//           ],
//         ),
//       ],
//     ),
//   );
// }
