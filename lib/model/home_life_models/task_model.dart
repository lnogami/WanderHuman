class HLTaskModel {
  // 1. Properties: The actual data we want to store
  final String?
  taskID; // Nullable because a new task doesn't have an ID until Firestore gives it one
  final String taskName;
  final String description;
  final String time;
  final bool isDone;
  final String isDoneBy;
  // Added for that "Collection Group Query" capability we discussed
  final String? caregiverId;
  // newly added
  final String? createdAt;

  // 2. Constructor: How we create the object in our app
  HLTaskModel({
    required this.taskID,
    required this.taskName,
    required this.description,
    required this.time,
    required this.isDone, // Default to false (not done) when creating
    required this.isDoneBy,
    required this.caregiverId,
    // newly added
    required this.createdAt,
  });

  // 3. toMap(): The "Packer"
  // WHY? Firestore only understands JSON (Maps). This converts our fancy Dart object
  // into a simple Map that Firestore can save.
  Map<String, dynamic> toMap() {
    return {
      'taskName': taskName,
      'description': description,
      'time': time,
      'isDone': isDone,
      'isDoneBy': isDoneBy,
      'caregiverId': caregiverId,
      'createdAt': createdAt,
      // Note: We rarely save 'id' inside the map because it's already the document name!
    };
  }

  // 4. fromFirestore(): The "Unpacker"
  // WHY? When data comes back from Firestore, it's a messy Map.
  // This factory constructor organizes it back into a clean Dart object we can use.
  factory HLTaskModel.fromFirestore(Map<String, dynamic> data, String docId) {
    return HLTaskModel(
      taskID: docId, // We inject the Document ID separately here
      // '??' is a safety check: if null, use empty string
      taskName: data['taskName'] ?? '',
      description: data['description'] ?? '',
      time: data['time'] ?? '',
      isDone: data['isDone'] ?? false,
      isDoneBy: data['isDoneBy'] ?? '',
      caregiverId: data['caregiverId'] ?? '',
      // dateID is not really required when creating task, it only optional for displaying in UI
      createdAt: data['createdAt'] ?? '',
    );
  }
}
