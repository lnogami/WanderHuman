import 'package:flutter/material.dart';
import 'package:wanderhuman_app/view/home_appbar/userPriviligeOptions.dart/admin.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';
import 'package:wanderhuman_app/view/home_appbar/userPriviligeOptions.dart/home_life.dart';
import 'package:wanderhuman_app/view/home_appbar/userPriviligeOptions.dart/medical_services.dart';
import 'package:wanderhuman_app/view/home_appbar/userPriviligeOptions.dart/psd.dart';
import 'package:wanderhuman_app/view/home_appbar/userPriviligeOptions.dart/psychological_services.dart';
import 'package:wanderhuman_app/view/home_appbar/userPriviligeOptions.dart/social_services.dart';

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
