import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:wanderhuman_app/helper/history_reposity.dart';

/// This function will move the camera to a specific location on the map (based on patient's location)
/// patientID must be provided to enable flyTo
Future<void> myMapFlyTo({
  required MapboxMap mapboxController,
  required Position position,
  required String patientID,
  double zoomLevel = 15.0,
}) async {
  // TODO: this MyHistoryReposity is just temporary and must be change to RealtimeRepository if data from the device is available
  // first get the patient's location data from the database
  final patientLocationData = await MyHistoryReposity.getSpecificPatientHistory(
    patientID,
  );
  double lng = double.parse(patientLocationData.currentLocationLng);
  double lat = double.parse(patientLocationData.currentLocationLat);

  mapboxController.flyTo(
    CameraOptions(
      center: Point(coordinates: Position(lng, lat)),
      zoom: zoomLevel,
    ),
    MapAnimationOptions(duration: 700),
  );

  // var interaction = TapInteraction(, );
  // mapboxController.addInteraction(interaction);
}
