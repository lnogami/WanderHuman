class MedicationModel {
  String? recordID;
  String patientID;
  String diagnosis;
  String treatment;
  String medic;
  String fromDate;
  String untilDate;
  bool isNowOkay;
  String createdAt;

  MedicationModel({
    this.recordID,
    required this.patientID,
    required this.diagnosis,
    required this.treatment,
    required this.medic,
    required this.fromDate,
    required this.untilDate,
    required this.isNowOkay,
    required this.createdAt,
  });

  factory MedicationModel.fromFirestore(String id, Map<String, dynamic> data) {
    return MedicationModel(
      recordID: data['recordID'] ?? "",
      patientID: data['patientID'] ?? "",
      diagnosis: data['diagnosis'] ?? "",
      treatment: data['treatment'] ?? "",
      medic: data['medic'] ?? "",
      fromDate: data['fromDate'] ?? "",
      untilDate: data['untilDate'] ?? "",
      isNowOkay: data['isNowOkay'] ?? "",
      createdAt: data['createdAt'] ?? "",
    );
  }
}
