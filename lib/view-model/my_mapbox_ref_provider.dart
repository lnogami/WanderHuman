import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MyMapboxRefProvider extends ChangeNotifier {
  MapboxMap? _mapboxMapController;

  // // Getter
  // MapboxMap? getMapboxMapController() {
  //   return _mapboxMapController;
  // }

  // Getter
  MapboxMap? get getMapboxMapController => _mapboxMapController;

  // Setter
  void setMapboxMapController(MapboxMap controller) {
    _mapboxMapController = controller;
    notifyListeners();
  }
}
