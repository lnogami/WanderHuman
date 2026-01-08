import 'package:flutter/material.dart';
import 'package:wanderhuman_app/utilities/properties/color_palette.dart';

class IndividualTaskCard extends StatefulWidget {
  final double widthPercentage;
  final double heightPercentage;
  const IndividualTaskCard({
    super.key,
    this.widthPercentage = 0.9,
    this.heightPercentage = 0.2,
  });

  @override
  State<IndividualTaskCard> createState() => _IndividualTaskCardState();
}

class _IndividualTaskCardState extends State<IndividualTaskCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(left: 20, right: 20),
      color: const Color.fromARGB(255, 224, 238, 255),
      borderOnForeground: true,
      surfaceTintColor: MyColorPalette.splashColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
      shadowColor: Colors.blue.shade100,
      child: Theme(
        data: Theme.of(context).copyWith(
          splashColor: const Color.fromARGB(
            51,
            74,
            173,
            255,
          ), // The ripple color (Splash)
          // highlightColor:
          //     MyColorPalette.formColor, // The background hold color
        ),
        child: CheckboxListTile.adaptive(
          // to match the Card's shape
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
          side: BorderSide(color: Colors.blue.shade200, width: 1.5),
          overlayColor: WidgetStatePropertyAll(Colors.amber),
          // secondary: Icon(Icons.person_outline_rounded),
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: Colors.blue.shade400,
          contentPadding: EdgeInsets.only(left: 5, right: 5),
          value: true,
          title: Text("Task Name"),
          // tileColor: Colors.blue.shade100,
          onChanged: (value) {},
        ),
      ),
    );
  }
}
