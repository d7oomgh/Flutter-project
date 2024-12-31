import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:TafweejHub/fetures/user_auth/presentation/pages/LocationService.dart';

class MapScreen extends StatefulWidget {
   final bool isAdmin;
  final String userId;  // User ID passed from previous screen

  const MapScreen({super.key, required this.isAdmin, required this.userId});

  @override
  _MapScreenState createState() => _MapScreenState();
}

Future<void> _updateUserLocation(String userId) async {
  Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  
  // Update the user's location in Firestore
  await FirebaseFirestore.instance.collection('users').doc(userId).set({
    'location': {
      'latitude': position.latitude,
      'longitude': position.longitude,
    },
    'lastLogin': FieldValue.serverTimestamp(), // Optionally store last login time
  }, SetOptions(merge: true)); // Merge to avoid overwriting other user data
}


class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  late final Set<Marker> _markers = {};
  bool _isLoading = true;
  final LocationService _locationService = LocationService();
  bool _isAdmin = false;  // Variable to store the user role

  @override
  void initState() {
   super.initState();
  _updateUserLocation(widget.userId); // Update the user's location
  _getUserLocations(); // Fetch other users' locations (for admin)// Fetch user role on initialization
  }

  // Fetch the user's role from Firestore
  Future<void> _fetchUserRole() async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();

    if (userSnapshot.exists) {
      var data = userSnapshot.data() as Map<String, dynamic>;
      var role = data['role'];

      setState(() {
        _isAdmin = role == 'admin';  // Check if the user is an admin
      });

      // Fetch locations only after user role is determined
      _getUserLocations();
    }
  }

Future<void> _getUserLocations() async {
  if (widget.isAdmin) {
    // Await the Future to get the Stream
    Stream<QuerySnapshot> userLocationsStream = await _locationService.getAllUserLocations();
    
    userLocationsStream.listen((snapshot) {
      _markers.clear(); // Clear previous markers
      snapshot.docs.forEach((doc) {
        var data = doc.data() as Map<String, dynamic>;
        var location = data['location'];

        if (location != null && location is Map<String, dynamic>) {
          double? latitude = location['latitude']?.toDouble();
          double? longitude = location['longitude']?.toDouble();

          if (latitude != null && longitude != null) {
            _markers.add(Marker(
              markerId: MarkerId(doc.id),
              position: LatLng(latitude, longitude),
              infoWindow: InfoWindow(title: doc.id),
            ));
          }
        }
      });

      setState(() {
        _isLoading = false; // Stop loading when locations are fetched
      });
    });
  } else {
    // If not admin, show own location
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    
    setState(() {
      _markers.add(Marker(
        markerId: MarkerId(widget.userId), // Assuming widget.userId holds the user's ID
        position: LatLng(position.latitude, position.longitude),
        infoWindow: InfoWindow(title: 'Your Location'),
      ));
      _isLoading = false; // Stop loading when the user's location is fetched
    });
    
    // Move camera to the user's current location
    _mapController?.moveCamera(CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)));
  }
}



Future<void> _showAlertDialog() async {
  String selectedUserId = '';
  String alertMessage = '';
  List<Map<String, dynamic>> groupUsers = [];

  try {
    // First, fetch the admin's group ID
    DocumentSnapshot adminDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();
    
    String adminGroupId = adminDoc.get('groupId') ?? '';

    // Fetch users in the same group
    QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('groupId', isEqualTo: adminGroupId)
        .where('role', isEqualTo: 'user')
        .get();

    // Convert snapshot to a list of user maps
    groupUsers = usersSnapshot.docs.map((doc) {
      var userData = doc.data() as Map<String, dynamic>;
      userData['documentId'] = doc.id;
      return userData;
    }).toList();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Send Alert to Group Members'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dropdown to select user from group members
              DropdownButton<String>(
                hint: Text('Select User'),
                value: selectedUserId.isNotEmpty ? selectedUserId : null,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedUserId = newValue ?? '';
                  });
                },
                items: groupUsers.map((user) {
                  return DropdownMenuItem<String>(
                    value: user['ID'], // Use the user's ID
                    child: Text(user['name'] ?? 'Unknown User'),
                  );
                }).toList(),
              ),
              TextField(
                onChanged: (value) {
                  alertMessage = value;
                },
                decoration: InputDecoration(hintText: 'Enter Alert Message'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (selectedUserId.isNotEmpty && alertMessage.isNotEmpty) {
                  // Send the alert
                  await _locationService.sendAlert(widget.userId, selectedUserId, alertMessage);
                  Navigator.of(context).pop();
                  
                  // Optional: Show a confirmation snackbar
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Alert sent successfully')),
                  );
                }
              },
              child: Text('Send'),
            ),
          ],
        );
      },
    );
  } catch (e) {
    debugPrint('Error fetching group users: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to fetch group members')),
    );
  }
}


void _onMapCreated(GoogleMapController controller) {
  _mapController = controller;
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      // Use widget.isAdmin instead of _isAdmin
      title: Text(widget.isAdmin ? 'Admin Map Screen' : 'User Map Screen'),
    ),
    body: _isLoading
        ? Center(child: CircularProgressIndicator())
        : Stack(
            children: [
              GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: LatLng(21.489817, 39.247499),
                  zoom: 12,
                ),
                markers: _markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
              ),
              if (widget.isAdmin)
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: FloatingActionButton(
                    onPressed: _showAlertDialog, // Function to trigger the alert
                    child: Icon(Icons.notifications),
                    tooltip: 'Send Alert',
                  ),
                ),
            ],
          ),
  );
}

}