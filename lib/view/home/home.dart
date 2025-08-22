import 'package:flutter/material.dart';
import 'package:wanderhuman_app/utilities/dimension_adapter.dart';
import 'package:wanderhuman_app/view/home/widgets/home_appbar.dart';
import 'package:wanderhuman_app/view/home/widgets/map_body.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Center(child: const Text('Home Page')),
      //   backgroundColor: Colors.blue,
      //   foregroundColor: Colors.white,
      // ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            HomeAppBar(),
            SliverToBoxAdapter(
              child: Container(
                width: MyDimensionAdapter.getWidth(context),
                height: MyDimensionAdapter.getHeight(context) * 0.85,
                child: MapBody(),
              ),
            ),
            // SliverToBoxAdapter(
            //   child: Padding(
            //     padding: const EdgeInsets.all(20.0),
            //     child: ClipRRect(
            //       borderRadius: BorderRadius.circular(50),
            //       child: Container(color: Colors.amber, width: 50, height: 60),
            //     ),
            //   ),
            // ),
            // SliverToBoxAdapter(
            //   child: Padding(
            //     padding: const EdgeInsets.all(20.0),
            //     child: ClipRRect(
            //       borderRadius: BorderRadius.circular(50),
            //       child: Container(color: Colors.amber, width: 50, height: 300),
            //     ),
            //   ),
            // ),
            // SliverToBoxAdapter(
            //   child: Padding(
            //     padding: const EdgeInsets.all(20.0),
            //     child: ClipRRect(
            //       borderRadius: BorderRadius.circular(50),
            //       child: Container(color: Colors.amber, width: 50, height: 500),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
