class HomeLifePlannerModel {
  final String taskID;
  final String taskName;
  final String taskDescription;
  final String participants;
  final String repeatInterval;
  final String time;
  final String untilDate;
  final String fromDate;
  final String createdAt;
  final String createdBy;

  const HomeLifePlannerModel({
    required this.taskID,
    required this.taskName,
    required this.taskDescription,
    required this.participants,
    required this.repeatInterval,
    required this.time,
    required this.fromDate,
    required this.untilDate,
    required this.createdAt,
    required this.createdBy,
  });

  factory HomeLifePlannerModel.fromFirebase({
    required String taskID,
    required Map<String, dynamic> data,
  }) {
    return HomeLifePlannerModel(
      taskID: taskID,
      taskName: data['taskName'] ?? '',
      taskDescription: data['taskDescription'] ?? '',
      participants: data['participants'] ?? '',
      repeatInterval: data['repeatInterval'] ?? '',
      time: data['time'] ?? '',
      fromDate: data["fromDate"] ?? '',
      untilDate: data["untilDate"] ?? '',
      createdAt: data["createdAt"] ?? '',
      createdBy: data["createdBy"] ?? '',
    );
  }
}
