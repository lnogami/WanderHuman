import 'package:flutter/material.dart';

class MyHomeSettingsProvider extends ChangeNotifier {
  double? _zoomLevel;

  double get zoomLevel => _zoomLevel ?? 15.0;

  void setZoomLevel(double value) {
    _zoomLevel = value;
    notifyListeners();
  }
}
