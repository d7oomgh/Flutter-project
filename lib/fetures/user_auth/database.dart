import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> storeUserProfile(UserProfile userProfile) async {
    await _firestore.collection('user_profiles').doc(userProfile.id).set(userProfile.toMap());
  }

  Future<UserProfile> getUserProfile(String userId) async {
    DocumentSnapshot snapshot = await _firestore.collection('user_profiles').doc(userId).get();
    return UserProfile.fromMap(snapshot.data() as Map<String, dynamic>);
  }

  Future<void> updateUserProfile(String userId, Map<String, dynamic> updates) async {
    await _firestore.collection('user_profiles').doc(userId).update(updates);
  }

  Future<void> storeRetailInformation(RetailInformation retailInformation) async {
    await _firestore.collection('retail_informations').doc(retailInformation.id).set(retailInformation.toMap());
  }

  Future<RetailInformation> getRetailInformation(String retailInformationId) async {
    DocumentSnapshot snapshot = await _firestore.collection('retail_informations').doc(retailInformationId).get();
    return RetailInformation.fromMap(snapshot.data() as Map<String, dynamic>);
  }

  Future<void> updateRetailInformation(String retailInformationId, Map<String, dynamic> updates) async {
    await _firestore.collection('retail_informations').doc(retailInformationId).update(updates);
  }

  Future<void> storeSupportInformation(SupportInformation supportInformation) async {
    await _firestore.collection('support_informations').doc(supportInformation.id).set(supportInformation.toMap());
  }

  Future<SupportInformation> getSupportInformation(String supportInformationId) async {
    DocumentSnapshot snapshot = await _firestore.collection('support_informations').doc(supportInformationId).get();
    return SupportInformation.fromMap(snapshot.data() as Map<String, dynamic>);
  }

  Future<void> updateSupportInformation(String supportInformationId, Map<String, dynamic> updates) async {
    await _firestore.collection('support_informations').doc(supportInformationId).update(updates);
  }

  Future<void> storePrivacyConcern(PrivacyConcern privacyConcern) async {
    await _firestore.collection('privacy_concerns').doc(privacyConcern.id).set(privacyConcern.toMap());
  }

  Future<PrivacyConcern> getPrivacyConcern(String privacyConcernId) async {
    DocumentSnapshot snapshot = await _firestore.collection('privacy_concerns').doc(privacyConcernId).get();
    return PrivacyConcern.fromMap(snapshot.data() as Map<String, dynamic>);
  }

  Future<void> updatePrivacyConcern(String privacyConcernId, Map<String, dynamic> updates) async {
    await _firestore.collection('privacy_concerns').doc(privacyConcernId).update(updates);
  }
}

class UserProfile {
  String id;
  String phoneNumber;
  String name;
  String email;

  UserProfile({required this.id, required this.phoneNumber, required this.name, required this.email});

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'],
      phoneNumber: map['phoneNumber'],
      name: map['name'],
      email: map['email'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'name': name,
      'email': email,
    };
  }
}

class RetailInformation {
  String id;
  String name;
  String description;
  String address;

  RetailInformation({required this.id, required this.name, required this.description, required this.address});

  factory RetailInformation.fromMap(Map<String, dynamic> map) {
    return RetailInformation(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      address: map['address'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
    };
  }
}

class SupportInformation {
  String id;
  String title;
  String description;

  SupportInformation({required this.id, required this.title, required this.description});

  factory SupportInformation.fromMap(Map<String, dynamic> map) {
    return SupportInformation(
      id: map['id'],
      title: map['title'],
      description: map['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
    };
  }
}

class PrivacyConcern {
  String id;
  String title;
  String description;

  PrivacyConcern({required this.id, required this.title, required this.description});

  factory PrivacyConcern.fromMap(Map<String, dynamic> map) {
    return PrivacyConcern(
      id: map['id'],
      title: map['title'],
      description: map['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
    };
  }
}