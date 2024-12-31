// ignore: depend_on_referenced_packages

import 'package:TafweejHub/fetures/user_auth/presentation/pages/map_screen.dart';
import 'package:TafweejHub/fetures/user_auth/user_profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:TafweejHub/fetures/app/splash_screen/splash_screen.dart';
import 'package:TafweejHub/fetures/user_auth/presentation/pages/Login_Page.dart';
import 'package:TafweejHub/fetures/user_auth/presentation/pages/bar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:TafweejHub/fetures/user_auth/auth.dart';
import 'package:TafweejHub/fetures/user_auth/database.dart';
import 'package:TafweejHub/fetures/user_auth/security_rules.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
 await Firebase.initializeApp();


 runApp(MyApp());
}



class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      title: 'Login Page',
      home: Splash_screen(
        child: LoginPage(),
      ),routes: {
        '/user-profile': (context) => UserProfileScreen(),
        
      },
    );
  }

  
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

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Navigator.pushNamed(context, '/user-profile');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Splash Screen'),
      ),
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});




  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      drawer: Bar(),
      appBar: AppBar());
      
  }}