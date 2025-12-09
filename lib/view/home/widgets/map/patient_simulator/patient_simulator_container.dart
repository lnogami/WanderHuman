import 'package:flutter/material.dart';
import 'package:wanderhuman_app/utilities/dimension_adapter.dart';
import 'package:wanderhuman_app/view/home/home.dart';
import 'package:wanderhuman_app/view/home/widgets/map/patient_simulator/patient_simulator_map.dart';

class PatientSimulatorContainer extends StatefulWidget {
  const PatientSimulatorContainer({super.key});

  @override
  State<PatientSimulatorContainer> createState() =>
      _PatientSimulatorContainerState();
}

class _PatientSimulatorContainerState extends State<PatientSimulatorContainer> {
  @override
  void initState() {
    // WakelockPlus.enable();
    super.initState();
  }

  @override
  void dispose() {
    // WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: UniqueKey(),
      appBar: AppBar(title: Text("Patient Simulation")),
      body: SafeArea(
        child: Container(
          width: MyDimensionAdapter.getWidth(context),
          height: MyDimensionAdapter.getHeight(context),
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              PatientSimulator(),
              // Positioned(top: 0, child: ),
              Positioned(
                top: -20,
                right: 30,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) {
                          return HomePage();
                        },
                      ),
                    );
                  },
                  child: Icon(Icons.undo_rounded),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
