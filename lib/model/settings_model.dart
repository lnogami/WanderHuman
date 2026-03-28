class MySettingsModel {
  String userID;
  double zoomLevel;
  bool alwaysFollowYourAvatar;
  bool useDefaultAvatar;
  bool enableAvatarDistanceAccuracy;
  int mapView;
  bool minimizeHomePageButtons;

  MySettingsModel({
    required this.userID,
    required this.zoomLevel,
    required this.alwaysFollowYourAvatar,
    required this.useDefaultAvatar,
    required this.enableAvatarDistanceAccuracy,
    required this.mapView,
    required this.minimizeHomePageButtons,
  });

  factory MySettingsModel.fromMap(Map<String, dynamic> map) {
    return MySettingsModel(
      userID: map['userID'],
      zoomLevel: map['zoomLevel'],
      alwaysFollowYourAvatar: map['alwaysFollowYourAvatar'],
      useDefaultAvatar: map['useDefaultAvatar'] ?? true,
      enableAvatarDistanceAccuracy: map['enableAvatarDistanceAccuracy'] ?? true,
      mapView: map['mapView'] ?? 0,
      minimizeHomePageButtons: map['minimizeHomePageButtons'] ?? false,
    );
  }
}
