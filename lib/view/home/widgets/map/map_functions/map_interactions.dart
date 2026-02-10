import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:wanderhuman_app/view-model/home_geofence_config_provider.dart';
import 'package:wanderhuman_app/view/home/widgets/map/geofence_related_stuff/draw_geo/map_geofence_drawer.dart';

class MyMapInteractions {
  /// Tap interection within the map itself.
  /// polygonManager is for creating a polygon of the geofence area
  static void tapInteraction({
    required MapboxMap mapboxMapController,
    PolygonAnnotationManager? polygonManager,
    PointAnnotationManager? pointAnnotationManager,
    required BuildContext context,
  }) {
    // It can be written this way as well
    // var tapInteraction = TapInteraction.onMap((context) {
    //   log(
    //     "NOTICEEEEEEEEEEEEEEEEEEEEEEE: The tapped position is:  lng: ${context.point.coordinates.lng}, lat: ${context.point.coordinates.lat}",
    //   );
    // });
    // mapboxMapController.addInteraction(tapInteraction);

    mapboxMapController.addInteraction(
      TapInteraction.onMap((mapContext) {
        log(
          "NOTICEEEEEEEEEEEEEEEEEEEEEEE: The tapped position is:  lng: ${mapContext.point.coordinates.lng}, lat: ${mapContext.point.coordinates.lat}",
        );

        if (pointAnnotationManager != null) {
          MyMapGeofenceDrawer.markPressedPoints(
            pointManager: pointAnnotationManager,
            tappedPoint: Point(coordinates: (mapContext.point.coordinates)),
            context: context,
          );
        }

        final curretPositions = context
            .read<MyHomeGeofenceConfigurationProvider>()
            .listOfMarkedPositions;

        if (polygonManager != null) {
          MyMapGeofenceDrawer.drawPolygon(
            polygonManager: polygonManager,
            positions: curretPositions,
          );
        }
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
