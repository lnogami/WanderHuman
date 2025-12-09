import 'package:flutter/material.dart';
import 'package:wanderhuman_app/view/components/button.dart';
import 'package:wanderhuman_app/view/userRolesUI/admin/add_staff_form.dart';

class ManageStaff extends StatelessWidget {
  const ManageStaff({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: MyCustButton(
            buttonText: "Add Staff",
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddStaffForm()),
              );
            },
          ),
        ),
      ),
    );
  }
}
