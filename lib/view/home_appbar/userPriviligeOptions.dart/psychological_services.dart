import 'package:flutter/material.dart';
import 'package:wanderhuman_app/utilities/properties/text_formatter.dart';

class PsychologicalPrivilege extends StatelessWidget {
  const PsychologicalPrivilege({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.only(bottom: 7),
            child: MyTextFormatter.p(text: "Sorry, there is nothing here."),
          ),
        ],
      ),
    );
  }
}
