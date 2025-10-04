import 'package:flutter/material.dart';
import 'package:wanderhuman_app/utilities/dimension_adapter.dart';

class PatientDetailsPage extends StatefulWidget {
  const PatientDetailsPage({super.key});

  @override
  State<PatientDetailsPage> createState() => _PatientDetailsPageState();
}

class _PatientDetailsPageState extends State<PatientDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 212, 212, 212),
      body: Container(
        width: MyDimensionAdapter.getWidth(context),
        height: MyDimensionAdapter.getHeight(context),
        color: Colors.amber,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              // backgroundColor: Colors.green,
              expandedHeight: 200,
              flexibleSpace: FlexibleSpaceBar(
                // background: Image.asset("assets/icons/isagi.jpg"),
                background: SafeArea(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.withAlpha(200),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(width: 0),
                            Text(
                              "Hori Zontal",
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            CircleAvatar(backgroundColor: Colors.white),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
