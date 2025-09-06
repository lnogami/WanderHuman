// Navigation methods
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mp;
import 'package:wanderhuman_app/view/home/widgets/map/users_history.dart';

void moveToUser({
  required mp.MapboxMap mapboxMapController,
  required FirebaseUserHistory user,
}) {
  mapboxMapController.setCamera(
    mp.CameraOptions(
      center: mp.Point(
        coordinates: mp.Position(
          user.currentLocation.longitude,
          user.currentLocation.latitude,
        ),
      ),
      zoom: 16.0,
    ),
  );
}
