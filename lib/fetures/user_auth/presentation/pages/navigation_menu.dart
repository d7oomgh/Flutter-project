import 'package:TafweejHub/fetures/user_auth/presentation/pages/faq_screen.dart';
import 'package:TafweejHub/fetures/user_auth/presentation/pages/settings_screen.dart';
import 'package:TafweejHub/fetures/user_auth/support_information.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:TafweejHub/fetures/user_auth/presentation/pages/map_screen.dart';


class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});
  
  String? get userId => null;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          ListTile(
            title: const Text('Map'),
            onTap: () {
              navigateBasedOnRole1(userId!, context);
            },
          ),
          ListTile(
            title: const Text('Support'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SupportScreen()),
              );
            },
          ),
          ListTile(
            title: const Text('FAQ'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FaqScreen()),
              );
            },
          ),
          ListTile(
            title: const Text('Settings'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

   Future<String?> checkUserRole(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        return userDoc['role']; // returns 'admin' or 'user'
      } else {
        print("User not found");
        return null;
      }
    } catch (e) {
      print("Error fetching user role: $e");
      return null;
    }
  }

void navigateBasedOnRole1(String userId, BuildContext context) async {
  // Get the user role based on the userId
  String? role = await checkUserRole(userId);

  if (role == 'admin') {
    // Navigate to the admin version of the MapScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapScreen(isAdmin: true, userId: userId),
      ),
    );
  } else if (role == 'user') {
    // Navigate to the user version of the MapScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapScreen(isAdmin: false, userId: userId),
      ),
    );
  } 
}
}