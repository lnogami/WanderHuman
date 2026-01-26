import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

/// This function will move the camera to a specific location on the map (based on patient's location)
/// patientID must be provided to enable flyTo
Future<void> myMapFlyTo({
  required MapboxMap mapboxController,
  required Position position,
  required String patientID,
  double zoomLevel = 15.0,
}) async {
  mapboxController.flyTo(
    CameraOptions(
      center: Point(coordinates: position),
      zoom: zoomLevel,
    ),
    MapAnimationOptions(duration: 700),
  );

  // var interaction = TapInteraction(, );
  // mapboxController.addInteraction(interaction);
}
