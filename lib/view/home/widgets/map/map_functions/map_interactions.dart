import 'dart:developer';

import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MyMapInteractions {
  /// Tap interection within the map itself.
  static void tapInteraction({required MapboxMap mapboxMapController}) {
    // It can be written this way as well
    // var tapInteraction = TapInteraction.onMap((context) {
    //   log(
    //     "NOTICEEEEEEEEEEEEEEEEEEEEEEE: The tapped position is:  lng: ${context.point.coordinates.lng}, lat: ${context.point.coordinates.lat}",
    //   );
    // });
    // mapboxMapController.addInteraction(tapInteraction);

    mapboxMapController.addInteraction(
      TapInteraction.onMap((context) {
        log(
          "NOTICEEEEEEEEEEEEEEEEEEEEEEE: The tapped position is:  lng: ${context.point.coordinates.lng}, lat: ${context.point.coordinates.lat}",
        );
      }),
    );
  }

  /// Long tap interection within the map itself.
  static void longTapInteraction({required MapboxMap mapboxMapController}) {
    mapboxMapController.addInteraction(
      LongTapInteraction.onMap((context) {
        log(
          "NOTICEEEEEEEEEEEEEEEEEEEEEEE: The long tapped position is:  lng: ${context.point.coordinates.lng}, lat: ${context.point.coordinates.lat}",
        );
      }),
    );
  }
}
