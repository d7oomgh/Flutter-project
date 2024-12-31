import 'package:flutter/material.dart';
import 'package:TafweejHub/fetures/user_auth/presentation/pages/LocationService.dart';

class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final LocationService _locationService = LocationService();
  final String userId = 'some_user_id'; // Add logic to retrieve current user ID

  @override
  void initState() {
    super.initState();
    _updateUserLocation();
  }

  Future<void> _updateUserLocation() async {
    await _locationService.updateUserLocation(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("User Profile")),
      body: Center(
        child: Text("User Profile Data"),
      ),
    );
  }
}
