class MySettingsModel {
  String userID;
  double zoomLevel;
  bool alwaysFollowYourAvatar;

  MySettingsModel({
    required this.userID,
    required this.zoomLevel,
    required this.alwaysFollowYourAvatar,
  });

  factory MySettingsModel.fromMap(Map<String, dynamic> map) {
    return MySettingsModel(
      userID: map['userID'],
      zoomLevel: map['zoomLevel'],
      alwaysFollowYourAvatar: map['alwaysFollowYourAvatar'],
    );
  }
}
