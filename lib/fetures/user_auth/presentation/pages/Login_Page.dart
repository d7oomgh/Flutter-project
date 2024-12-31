import 'package:flutter/material.dart';
import 'package:TafweejHub/fetures/user_auth/presentation/pages/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _idController = TextEditingController();
  String? _errorMessage;
  String? _role; // Store user role

  // Initialize Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to check if user exists and get role
  Future<void> _checkUserRole(String userId) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        _role = userDoc['role']; // Fetch the user role
        print("User role: $_role");
      } else {
        setState(() {
          _errorMessage = 'User not found.';
        });
      }
    } catch (e) {
      print("Error fetching user role: $e");
    }
  }

  // Function to save user ID, last login, and location to Firestore
  Future<void> _saveUserIdToFirestore(String userId) async {
    try {
      // Get user's location (hardcoded for now; replace with actual logic if needed)
      String userLocation = "Jeddah, Saudi Arabia"; // Example location

      await _firestore.collection('users').doc(userId).set({
        'ID': userId,
        'lastLogin': FieldValue.serverTimestamp(), // Save the current login timestamp
        'location': userLocation, // Save the user's location
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); // Use merge to avoid overwriting existing fields

      print("User data (ID, lastLogin, location) saved to Firestore");
    } catch (e) {
      print("Error saving user data: $e");
    }
  }

  // Function to perform login
  void _login(BuildContext context) async {
    String enteredId = _idController.text.trim();

    // Check if user exists and get role
    await _checkUserRole(enteredId);

    if (_role != null) {
      // Save user ID, lastLogin, and location to Firestore
      await _saveUserIdToFirestore(enteredId);

      // User found, navigate to HomePage
      Navigator.of(context).pop(); // Close the dialog
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Login successful as $_role!'),
        backgroundColor: Colors.green,
      ));
      Navigator.push(
          // ignore: use_build_context_synchronously
          context, MaterialPageRoute(builder: (context) => HomePage(userId: enteredId,)));
    } else {
      // User not found or error
      setState(() {
        _errorMessage = 'Invalid Phone or user not found. Please try again.';
      });
    }
  }



  // Function to show the login dialog
  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text('Login'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _idController,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter your Phone',
                      errorText: _errorMessage, // Display error message
                    ),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    setStateDialog(() {
                      _login(context); // Call login function
                    });
                  },
                  child: Text("Login"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Login",
          style: TextStyle(
              fontSize: 27, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Color.fromARGB(255, 12, 12, 12),
      ),
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    "lib/fetures/user_auth/presentation/widgets/Background.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Button to trigger the login pop-up
          Center(
            child: ElevatedButton(
              onPressed: _showLoginDialog,
              child: Text("Show Login"),
            ),
          ),
        ],
      ),
      // Bottom navigation bar
      bottomNavigationBar: BottomAppBar(
        color: Colors.black,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.map),
              color: Colors.grey,
              onPressed: () {
                // Handle map button action
              },
            ),
            IconButton(
              icon: Icon(Icons.security),
              color: Colors.grey,
              onPressed: () {
                // Handle shield button action
              },
            ),
            IconButton(
              icon: Icon(Icons.warning),
              color: Colors.grey,
              onPressed: () {
                // Handle exclamation button action
              },
            ),
            TextButton(
              onPressed: () {
                // Handle emergency call button action
              },
              child: Text(
                'Emergency Call',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }
}
