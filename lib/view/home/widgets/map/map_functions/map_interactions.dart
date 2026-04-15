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

        //----------------------------------------------------------------------
        // Special Event: if the tap is happening during adding a center point
        if (context
            .read<MyHomeGeofenceConfigurationProvider>()
            .isAboutToAddCenterPoint) {
          _initCenterPointAnnotationManager(
            mapboxMapController: mapboxMapController,
            context: context,
            mapContext: mapContext,
          );

          // to prevent the other lines of code below from running
          return;
        }

        //----------------------------------------------------------------------
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

  // this is only for centerPoint
  static Future<void> _initCenterPointAnnotationManager({
    required MapboxMap mapboxMapController,
    required BuildContext context,
    required MapContentGestureContext mapContext,
  }) async {
    MyHomeGeofenceConfigurationProvider geofenceConfigProvider = context
        .read<MyHomeGeofenceConfigurationProvider>();

    // set a PointAnnotationManager
    if (geofenceConfigProvider.centerPointAnnotationManager == null) {
      geofenceConfigProvider.setCenterPointManager(
        await mapboxMapController.annotations.createPointAnnotationManager(),
      );
    }

    // to prevent having more than one centerpoint
    geofenceConfigProvider.centerPointAnnotationManager?.deleteAll();

    // // delete the polygonManager data because it is not need here anymore
    // if (polygonManager != null) polygonManager.deleteAll();

    // ignore: use_build_context_synchronously
    context.read<MyHomeGeofenceConfigurationProvider>().setCenterPoint(
      mapContext.point.coordinates,
    );

    MyMapGeofenceDrawer.markPressedPoints(
      pointManager: geofenceConfigProvider.centerPointAnnotationManager!,
      tappedPoint: Point(coordinates: (mapContext.point.coordinates)),
      context: context,
      isACenterPoint: true,
    );
  }
}
