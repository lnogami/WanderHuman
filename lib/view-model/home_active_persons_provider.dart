import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:wanderhuman_app/model/personal_info.dart';
import 'package:wanderhuman_app/view/components/image_picker.dart';

class MyHomeActivePersonsProvider extends ChangeNotifier {
  final List<PersonalInfo> _activePersons = [];
  final Map<String, Position> _personCurrentPosition = {};
  final Map<String, Uint8List> _decodedImagesBuffer = {};
  final Map<String, int> _devicesBattery = {};

  List<PersonalInfo> get activePersons => _activePersons;
  Map<String, Position> get personCurrentPosition => _personCurrentPosition;
  Map<String, Uint8List> get decodedImagesBuffer => _decodedImagesBuffer;
  Map<String, int> get devicesBattery => _devicesBattery;

  // Active Status
  void addActivePerson(PersonalInfo person) {
    // return immediately if this person already in the list
    if (_activePersons.any((p) {
      return p.userID == person.userID;
    })) {
      return;
    }

    _activePersons.add(person);

    _activePersons.sort((a, b) {
      return a.name.compareTo(b.name);
    });

    notifyListeners();
    log("Successfully Added ${person.name} to the Active List");
  }

  // Active Status
  void removeActivePerson(String userID) {
    _activePersons.removeWhere((person) {
      return person.userID == userID;
    });
    notifyListeners();
    log("Successfully remove userID from the Active List");
  }

  // Position
  void updatePersonCurrentPosition(String userID, Position position) {
    _personCurrentPosition[userID] = position;
    notifyListeners();
  }

  // Position
  void removePersonCurrentPosition(String userID) {
    _personCurrentPosition.remove(userID);
    notifyListeners();
  }

  // Decoded Image Buffer
  void decodeAndAddImageInBuffer(String userID, String base64ImageString) {
    var tempImage = MyImageProcessor.decodeStringToUint8List(base64ImageString);
    _decodedImagesBuffer[userID] = tempImage;
    notifyListeners();
  }

  // Decoded Image Buffer
  void removeDecodedImageInBuffer(String userID) {
    _decodedImagesBuffer.remove(userID);
    notifyListeners();
  }

  // Device Battery
  void addDeviceBattery(String userID, int batteryPercentage) {
    // for (var entry in _devicesBattery.entries) {
    //   log(
    //     "`````````````````````Current Device Battery in Provider: ${entry.key}: ${entry.value}%",
    //   );
    // }
    // log(
    //   "AAAAAAAAAAAAAAAAAAAAAAAAAAAADDED DEVICE BATTERY: ${_devicesBattery.length}",
    // );
    _devicesBattery[userID] = batteryPercentage;
    notifyListeners();
  }

  // Device Battery
  void removeDeviceBattery(String userID) {
    if (_devicesBattery.containsKey(userID)) {
      _devicesBattery.remove(userID);
    }
    notifyListeners();
  }
}
