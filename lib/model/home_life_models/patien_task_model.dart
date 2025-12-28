class Patient {
  final String? id;
  final String patientName;
  final String assignedCaregiver;

  // Notice we do NOT put 'List<Task> tasks' here.
  // WHY? Because in your database design, tasks are in a SUBCOLLECTION.
  // They are not physically inside this document. We fetch them separately.

  Patient({
    this.id,
    required this.patientName,
    required this.assignedCaregiver,
  });

  // The Packer
  Map<String, dynamic> toMap() {
    return {'patientName': patientName, 'assignedCaregiver': assignedCaregiver};
  }

  // The Unpacker
  factory Patient.fromFirestore(Map<String, dynamic> data, String docId) {
    return Patient(
      id: docId,
      patientName: data['patientName'] ?? 'Unknown Patient',
      assignedCaregiver: data['assignedCaregiver'] ?? '',
    );
  }
}
