class MyEmergencyHotlinesModel {
  String hotLineID;
  String hotLineName;
  String hotLineNumber;
  String savedAt;
  String savedBy;

  MyEmergencyHotlinesModel({
    required this.hotLineID,
    required this.hotLineName,
    required this.hotLineNumber,
    required this.savedAt,
    required this.savedBy,
  });

  /// Use this method when retrieving data from Firebase, to efficiently retrieve data
  factory MyEmergencyHotlinesModel.fromFirebase({
    required String docID,
    required Map<String, dynamic> data,
  }) {
    return MyEmergencyHotlinesModel(
      hotLineID: docID,
      hotLineName: data["hotLineName"] ?? "",
      hotLineNumber: data["hotLineNumber"] ?? "",
      savedAt: data["savedAt"] ?? "",
      savedBy: data["savedBy"] ?? "",
    );
  }
}
