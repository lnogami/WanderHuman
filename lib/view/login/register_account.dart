import 'package:flutter/material.dart';
import 'package:wanderhuman_app/utilities/dimension_adapter.dart';
import 'package:wanderhuman_app/view/login/widgets/register_account_form.dart';

/// context is for BuildContext, email and password will be used for RegisterAccountForm
void bottomModalSheetOfSignUp({
  required BuildContext context,
  required String email,
  required String password,
}) {
  showModalBottomSheet(
    backgroundColor: Colors.white70,
    context: context,
    builder: (context) {
      return Container(
        width: MyDimensionAdapter.getWidth(context),
        height: MyDimensionAdapter.getHeight(context) * 0.90,
        decoration: BoxDecoration(
          // color: Colors.purple[100],
          borderRadius: borderRadius(),
        ),
        child: RegisterAccountForm(
          email: email,
          password: password,
          borderRadius: borderRadius(),
        ),
      );
    },
    // this property removes the default limit of the modal bottom sheet (.50 of the screen height)
    isScrollControlled: true,
  );
}

BorderRadius borderRadius() {
  return const BorderRadius.only(
    topLeft: Radius.circular(20),
    topRight: Radius.circular(20),
  );
}
