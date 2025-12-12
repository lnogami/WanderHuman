class PersonalInfo {
  // Instance Variables
  final String userID;
  final String userType;
  final String name;
  final String age;
  final String sex;
  final String birthdate;

  /// For patients, this is for their guardians emergency contact.
  /// For caregiver and admin this is their contact number.
  final String contactNumber;
  final String address;
  final String notableBehavior;
  final String picture;
  final String createdAt;
  final String lastUpdatedAt;
  final String registeredBy;
  final String asignedCaregiver;
  final String deviceID;
  final String email;

  // Constructor
  PersonalInfo({
    required this.userID,
    required this.userType,
    required this.name,
    required this.age,
    required this.sex,
    required this.birthdate,
    required this.contactNumber,
    required this.address,
    required this.notableBehavior,
    required this.picture,
    required this.createdAt,
    required this.lastUpdatedAt,
    required this.registeredBy,
    required this.asignedCaregiver,
    required this.deviceID,
    required this.email,
  });

  // Method Declaration
  factory PersonalInfo.fromFirestore(String id, Map<String, dynamic> data) {
    return PersonalInfo(
      userID: data['userID'] ?? "",
      userType: data['userType'] ?? "",
      name: data['name'] ?? "",
      age: data['age'] ?? "",
      sex: data['sex'] ?? "",
      birthdate: data['birthdate'] ?? "",
      contactNumber: data['contactNumber'] ?? "",
      address: data['address'] ?? "",
      notableBehavior: data['notableBehavior'] ?? "",
      // picture: data['picture'] ?? "", // old line
      picture: data['profilePictureURL'] ?? "", // new line
      createdAt: data['createdAt'].toString(),
      lastUpdatedAt: data['lastUpdatedAt'].toString(),
      registeredBy: data['registeredBy'] ?? "",
      asignedCaregiver: data['asignedCaregiver'] ?? "",
      deviceID: data['deviceID'] ?? "",
      email: data['email'] ?? "",
    );
  }
}
