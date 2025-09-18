import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:wanderhuman_app/utilities/dimension_adapter.dart';
import 'package:wanderhuman_app/view/home/widgets/appbar/home_appbar.dart';
import 'package:wanderhuman_app/view/home/widgets/map/map_body.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // //pang full screen ra ni
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // this will prevent the screen from sleeping.
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Positioned(
              // child: Container()
              child: SizedBox(
                width: MyDimensionAdapter.getWidth(context),
                height: MyDimensionAdapter.getHeight(context),
                child: MapBody(),
                // child: MyMapBody(),
              ),
            ),
            Positioned(top: 20, child: HomeAppBar()),
          ],
        ),
      ),
    );
  }
}
