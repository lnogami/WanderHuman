class MySettingsModel {
  String userID;
  double zoomLevel;
  bool alwaysFollowYourAvatar;
  bool useDefaultAvatar;
  bool enableAvatarDistanceAccuracy;

  MySettingsModel({
    required this.userID,
    required this.zoomLevel,
    required this.alwaysFollowYourAvatar,
    required this.useDefaultAvatar,
    required this.enableAvatarDistanceAccuracy,
  });

  factory MySettingsModel.fromMap(Map<String, dynamic> map) {
    return MySettingsModel(
      userID: map['userID'],
      zoomLevel: map['zoomLevel'],
      alwaysFollowYourAvatar: map['alwaysFollowYourAvatar'],
      useDefaultAvatar: map['useDefaultAvatar'] ?? true,
      enableAvatarDistanceAccuracy: map['enableAvatarDistanceAccuracy'] ?? true,
    );
  }
}
