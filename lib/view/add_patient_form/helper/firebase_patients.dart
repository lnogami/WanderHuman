class Patients {
  // Instance Variables
  final String name;
  final String age;
  final String sex;
  final String birthdate;
  final String guardianContactNumber;
  final String address;
  final String notableBehavior;
  final String picture;
  final String createdAt;
  final String lastUpdatedAt;
  final String registeredBy;
  final String asignedCaregiver;
  final String deviceID;
  // final String email;

  // Constructor
  Patients({
    required this.name,
    required this.age,
    required this.sex,
    required this.birthdate,
    required this.guardianContactNumber,
    required this.address,
    required this.notableBehavior,
    required this.picture,
    required this.createdAt,
    required this.lastUpdatedAt,
    required this.registeredBy,
    required this.asignedCaregiver,
    required this.deviceID,
    // required this.email,
  });

  // Method Declaration
  factory Patients.fromFirestore(String id, Map<String, dynamic> data) {
    return Patients(
      name: data['name'] ?? "",
      age: data['age'] ?? "",
      sex: data['sex'] ?? "",
      birthdate: data['birthdate'] ?? "",
      guardianContactNumber: data['guardianContactNumber'] ?? "",
      address: data['address'] ?? "",
      notableBehavior: data['notableBehavior'] ?? "",
      picture: data['picture'] ?? "",
      createdAt: data['createdAt'] ?? "",
      lastUpdatedAt: data['lastUpdatedAt'] ?? "",
      registeredBy: data['registeredBy'] ?? "",
      asignedCaregiver: data['asignedCaregiver'] ?? "",
      deviceID: data['deviceID'] ?? "",
      // email: data['email'] ?? "",
    );
  }
}
