import 'package:flutter/material.dart';
import 'package:wanderhuman_app/helper/realtime_location_repository.dart';

class RealtimeTemporaryTest extends StatefulWidget {
  const RealtimeTemporaryTest({super.key});

  @override
  State<RealtimeTemporaryTest> createState() => _RealtimeTemporaryTestState();
}

class _RealtimeTemporaryTestState extends State<RealtimeTemporaryTest> {
  // int price = 0;

  // Future<void> getPrice() async {
  //   price = await MyRealtimeLocationReposity.getPrice();
  //   setState(() {});
  // }

  @override
  void initState() {
    super.initState();
    // getPrice();
  }

  @override
  Widget build(BuildContext context) {
    // Future<void> getPrice() async {
    //   Map mapPrice = await MyRealtimeLocationReposity.getPrice();
    //   return mapPrice["price"];
    // }

    return Scaffold(
      appBar: AppBar(title: Text("Realtime Temporary Test")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // StreamBuilder(
            //   stream: MyRealtimeLocationReposity.priceStream(),
            //   builder: (context, snapshot) {
            //     if (snapshot.hasData) {
            //       return Text(
            //         snapshot.data.toString(),
            //         style: TextStyle(fontSize: 48),
            //       );
            //     }
            //     return CircularProgressIndicator();
            //   },
            // ),
            // ElevatedButton(
            //   onPressed: () async {
            //     print("Button pressed");
            //     await MyRealtimeLocationReposity.add(20);
            //     // getPrice();
            //   },
            //   child: Text("Set Price 20"),
            // ),
            // ElevatedButton(
            //   onPressed: () async {
            //     print("Button pressed");
            //     await MyRealtimeLocationReposity.add(25);
            //     setState(() {});
            //     // getPrice();
            //   },
            //   child: Text("Set Price 25"),
            // ),
            StreamBuilder(
              stream:
                  MyRealtimeLocationReposity.getRealtimePatientLocationStream(
                    deviceID: "0000000001",
                  ),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(
                    snapshot.data!.patientID,
                    style: TextStyle(fontSize: 48),
                  );
                } else if (snapshot.hasError) {
                  print(snapshot.error.toString());
                  return Text(
                    snapshot.error.toString(),
                    // style: TextStyle(fontSize: 48),
                  );
                }
                return CircularProgressIndicator();
              },
            ),
            ElevatedButton(
              onPressed: () async {
                await MyRealtimeLocationReposity.setPatientDevice(
                  deviceID: "0000000001",
                  patientID: "123",
                );
              },
              child: Icon(Icons.pending_actions),
            ),
            ElevatedButton(
              onPressed: () async {
                await MyRealtimeLocationReposity.setPatientDevice(
                  deviceID: "0000000001",
                  patientID: "456",
                );
              },
              child: Icon(Icons.pending_actions),
            ),
          ],
        ),
      ),
    );
  }
}
