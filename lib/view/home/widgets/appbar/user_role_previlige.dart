import 'package:flutter/material.dart';
import 'package:wanderhuman_app/view/home/widgets/appbar/userPriviligeOptions.dart/admin.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';
import 'package:wanderhuman_app/view/home/widgets/appbar/userPriviligeOptions.dart/home_life.dart';
import 'package:wanderhuman_app/view/home/widgets/appbar/userPriviligeOptions.dart/medical_services.dart';
import 'package:wanderhuman_app/view/home/widgets/appbar/userPriviligeOptions.dart/psd.dart';
import 'package:wanderhuman_app/view/home/widgets/appbar/userPriviligeOptions.dart/psychological_services.dart';
import 'package:wanderhuman_app/view/home/widgets/appbar/userPriviligeOptions.dart/social_services.dart';

class MyUserRolePrevilige extends StatelessWidget {
  final String userType;

  const MyUserRolePrevilige({super.key, required this.userType});

  @override
  Widget build(BuildContext context) {
    switch (userType.toUpperCase()) {
      case "ADMIN":
        return AdminPrivilege();

      case "SOCIAL SERVICE":
        return SocialServicesPrivilege();

      case "MEDICAL SERVICE":
        return MedicalPrivilege();

      case "HOME LIFE":
        return HomeLifePrivilege();

      case "PSYCHOLOGICAL SERVICE":
        return PsychologicalPrivilege();

      case "PSD":
        return PSDPrivilege();

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
