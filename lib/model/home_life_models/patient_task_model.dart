class HLPatientTaskModel {
  final String? id;
  final String patientName;
  final String assignedCaregiver;

  HLPatientTaskModel({
    this.id,
    required this.patientName,
    required this.assignedCaregiver,
  });

  // The Packer
  Map<String, dynamic> toMap() {
    return {'patientName': patientName, 'assignedCaregiver': assignedCaregiver};
  }

  // The Unpacker
  factory HLPatientTaskModel.fromFirestore(
    Map<String, dynamic> data,
    String docId,
  ) {
    return HLPatientTaskModel(
      id: docId,
      patientName: data['patientName'] ?? 'Unknown Patient',
      assignedCaregiver: data['assignedCaregiver'] ?? '',
    );
  }
}
