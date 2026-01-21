import 'package:flutter/material.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';
import 'package:wanderhuman_app/utilities/properties/text_formatter.dart';

class PsychologicalPrivilege extends StatelessWidget {
  const PsychologicalPrivilege({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          //// buttons/options
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceAround,
          //   children: [
          //     SizedBox(height: 10),
          //     optionsContainer(
          //       context,
          //       Icons.person_outline_rounded,
          //       "Acount",
          //       onTap: () {
          //         MyPersonalInfoRepository.getAllPersonalInfoRecords()
          //             .then((value) {
          //               showMyAnimatedSnackBar(
          //                 context: context,
          //                 dataToDisplay: "${value.length}",
          //               );
          //             })
          //             .catchError((error) {
          //               showMyAnimatedSnackBar(
          //                 context: context,
          //                 dataToDisplay: error.toString(),
          //               );
          //             });
          //       },
          //     ),
          //     SizedBox(height: 10),
          //     optionsContainer(
          //       context,
          //       Icons.add_outlined,
          //       "Add Patient",
          //       onTap: () {
          //         // AddPatientForm();
          //         // Navigator.push(
          //         //   context,
          //         //   MaterialPageRoute(builder: (context) => AddPatientForm()),
          //         // );
          //       },
          //     ),
          //     SizedBox(height: 10),
          //   ],
          // ),
          Container(
            // color: Colors.amber,
            height: MyDimensionAdapter.getHeight(context) * 0.068,
            alignment: Alignment.center,
            child: MyTextFormatter.p(text: "Sorry, there's nothing here."),
          ),
        ],
      ),
    );
  }
}
