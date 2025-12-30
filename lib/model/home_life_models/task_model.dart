class HLTaskModel {
  // 1. Properties: The actual data we want to store
  final String?
  taskID; // Nullable because a new task doesn't have an ID until Firestore gives it one
  final String taskName;
  final String description;
  final bool isDone;
  final String?
  caregiverId; // Added for that "Collection Group Query" capability we discussed

  // 2. Constructor: How we create the object in our app
  HLTaskModel({
    this.taskID,
    required this.taskName,
    required this.description,
    this.isDone = false, // Default to false (not done) when creating
    this.caregiverId,
  });

  // 3. toMap(): The "Packer"
  // WHY? Firestore only understands JSON (Maps). This converts our fancy Dart object
  // into a simple Map that Firestore can save.
  Map<String, dynamic> toMap() {
    return {
      'taskName': taskName,
      'description': description,
      'isDone': isDone,
      'caregiverId': caregiverId,
      // Note: We rarely save 'id' inside the map because it's already the document name!
    };
  }

  // 4. fromFirestore(): The "Unpacker"
  // WHY? When data comes back from Firestore, it's a messy Map.
  // This factory constructor organizes it back into a clean Dart object we can use.
  factory HLTaskModel.fromFirestore(Map<String, dynamic> data, String docId) {
    return HLTaskModel(
      taskID: docId, // We inject the Document ID separately here
      taskName:
          data['taskName'] ??
          '', // '??' is a safety check: if null, use empty string
      description: data['description'] ?? '',
      isDone: data['isDone'] ?? false,
      caregiverId: data['caregiverId'],
    );
  }
}
