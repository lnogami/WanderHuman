import 'package:flutter/material.dart';
import 'package:wanderhuman_app/utilities/properties/dimension_adapter.dart';

class HomePatientListDropDown extends StatefulWidget {
  const HomePatientListDropDown({super.key});

  @override
  State<HomePatientListDropDown> createState() =>
      _HomePatientListDropDownState();
}

class _HomePatientListDropDownState extends State<HomePatientListDropDown> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isExpanded = !isExpanded;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 800),
        width: MyDimensionAdapter.getWidth(context) * 0.12,
        height: (isExpanded) ? MyDimensionAdapter.getHeight(context) * 0.7 : 20,
        decoration: BoxDecoration(
          color: Colors.white70,
          borderRadius: BorderRadius.all(Radius.circular(7)),
        ),
        child: (isExpanded)
            ? Column(
                children: [
                  Icon(Icons.keyboard_arrow_up_rounded, size: 32),
                  Expanded(
                    child: FutureBuilder(
                      future: Future.delayed(Duration(seconds: 1)),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else {
                          return ListView.builder(
                            itemBuilder: (context, index) {
                              return Column(children: []);
                            },
                          );
                        }
                      },
                    ),
                  ),
                ],
              )
            : Icon(Icons.keyboard_arrow_down_rounded, size: 24),
      ),
    );
  }
}
