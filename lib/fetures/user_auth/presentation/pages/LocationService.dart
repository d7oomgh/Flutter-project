import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LocationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> updateUserLocation(String userId) async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    await _firestore.collection('users').doc(userId).update({
      'location': {
        'latitude': position.latitude,
        'longitude': position.longitude,
      },
    });
  }

  // Remove 'async' since no need to await here
  Stream<QuerySnapshot> getAllUserLocations() {
    return _firestore.collection('users').snapshots();
  }


 // Send alert to a specific user
  Future<void> sendAlert(String adminId, String userId, String message) async {
    await _firestore.collection('alerts').add({
      'userId': userId,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
      'sentBy': adminId,
    });
  }

  // Get all alerts for a specific user
  Stream<QuerySnapshot> getUserAlerts(String userId) {
    return _firestore
        .collection('alerts')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }


}
