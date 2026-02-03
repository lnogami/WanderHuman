class MyRealtimeActiveStatusModel {
  String userID;
  bool isActive;

  MyRealtimeActiveStatusModel({required this.userID, required this.isActive});

  factory MyRealtimeActiveStatusModel.fromMap(Map<String, dynamic> map) {
    return MyRealtimeActiveStatusModel(
      userID: map["userID"],
      isActive: map["isActive"],
    );
  }
}
