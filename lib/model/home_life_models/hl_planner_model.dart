class HomeLifePlanner {
  final String taskID;
  final String taskName;
  final String participants;
  final String scheduledDate;
  final String createdAt;
  final String createdBy;

  const HomeLifePlanner({
    required this.taskID,
    required this.taskName,
    required this.participants,
    required this.scheduledDate,
    required this.createdAt,
    required this.createdBy,
  });

  factory HomeLifePlanner.fromFirebase({
    required String taskID,
    required Map<String, dynamic> data,
  }) {
    return HomeLifePlanner(
      taskID: taskID,
      taskName: data['taskName'] ?? '',
      participants: data['participants'] ?? '',
      scheduledDate: data["scheduledDate"] ?? '',
      createdAt: data["createdAt"] ?? '',
      createdBy: data["createdBy"] ?? '',
    );
  }
}
