import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart' as mobile show Barcode;
import 'package:mobile_scanner/mobile_scanner.dart' hide Barcode;

class ProfilePage extends StatefulWidget {
  final String userId;
  const ProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final MobileScannerController scannerController = MobileScannerController();
  bool isScanning = false;
  String scannedCode = '';
  String userRole = '';
  Map<String, dynamic> userData = {};
  List<Map<String, dynamic>> allUsers = [];

  @override
  void dispose() {
    scannerController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getCurrentUserData();
    getAllUsers();
  }

  Future<void> getCurrentUserData() async {
    try {
      final DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(widget.userId)
          .get();

      if (userDoc.exists) {
        setState(() {
          userData = userDoc.data() as Map<String, dynamic>;
          userRole = userData['role'] ?? '';
        });
        debugPrint('Current User Data: $userData');
      } else {
        debugPrint('No user found with ID: ${widget.userId}');
      }
    } catch (e) {
      debugPrint('Error getting current user data: $e');
    }
  }

Future<void> getAllUsers() async {
  try {
    // First, get the admin's group ID
    final DocumentSnapshot adminDoc = await _firestore
        .collection('users')
        .doc(widget.userId)
        .get();
    
    String adminGroupId = adminDoc.get('groupId') ?? '';

    // If no group ID is found, return an empty list
    if (adminGroupId.isEmpty) {
      setState(() {
        allUsers = [];
      });
      return;
    }

    // Fetch only users in the same group
    final QuerySnapshot querySnapshot = await _firestore
        .collection('users')
        .where('groupId', isEqualTo: adminGroupId)
        .get();

    setState(() {
      allUsers = querySnapshot.docs.map((doc) {
        var userData = doc.data() as Map<String, dynamic>;
        userData['documentId'] = doc.id; // Optional: include document ID
        return userData;
      }).toList();
    });
  } catch (e) {
    debugPrint('Error getting users data: $e');
    setState(() {
      allUsers = [];
    });
  }
}

  Widget _buildUserInfo() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profile Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (userData.isNotEmpty) ...[
              _buildInfoRow('ID', userData['ID']?.toString() ?? 'N/A'),
              _buildInfoRow('Name', userData['name']?.toString() ?? 'N/A'),
              _buildInfoRow('Role', userData['role']?.toString() ?? 'N/A'),
            ] else
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }

Widget _buildUserList() {
  // Only show user list for admin users
  if (userRole.toLowerCase() != 'admin') return const SizedBox.shrink();
  
  return Card(
    margin: const EdgeInsets.all(16),
    elevation: 4,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Group Members',  // Changed from 'All Users'
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (allUsers.isEmpty)
            const Center(child: Text('No group members found')),
          for (var user in allUsers)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('ID', user['ID']?.toString() ?? 'N/A'),
                  _buildInfoRow('Name', user['name']?.toString() ?? 'N/A'),
                  _buildInfoRow('Role', user['role']?.toString() ?? 'N/A'),
                  const Divider(),
                ],
              ),
            ),
        ],
      ),
    ),
  );
}

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQRGenerator() {
    final String qrData = userData['ID']?.toString() ?? '';
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Your QR Code',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (qrData.isNotEmpty) 
              QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 200.0,
                backgroundColor: Colors.white,
              ),
            const SizedBox(height: 8),
            Text(
              'ID: $qrData',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQRScanner() {
    if (userRole.toLowerCase() != 'admin') return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'QR Scanner (Admin Only)',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (!isScanning)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isScanning = true;
                  });
                },
                child: const Text('Start Scanning'),
              )
            else
              Column(
                children: [
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: MobileScanner(
                        controller: scannerController,
                        onDetect: (capture) {
                          final List<mobile.Barcode> barcodes = capture.barcodes;
                          for (final barcode in barcodes) {
                            setState(() {
                              scannedCode = barcode.rawValue ?? '';
                              isScanning = false;
                            });
                            _handleScannedCode(scannedCode);
                            break;
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isScanning = false;
                      });
                      scannerController.stop();
                    },
                    child: const Text('Stop Scanning'),
                  ),
                ],
              ),
            if (scannedCode.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Last scanned ID: $scannedCode'),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleScannedCode(String scannedId) async {
    try {
      final scannedUser = allUsers.firstWhere(
        (user) => user['ID']?.toString() == scannedId,
        orElse: () => {},
      );

      if (scannedUser.isNotEmpty) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('User Information'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('ID', scannedUser['ID']?.toString() ?? 'N/A'),
                _buildInfoRow('Name', scannedUser['name']?.toString() ?? 'N/A'),
                _buildInfoRow('Role', scannedUser['role']?.toString() ?? 'N/A'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not found')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 2,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildUserInfo(),
            _buildQRGenerator(),
            _buildQRScanner(),
            _buildUserList(),
          ],
        ),
      ),
    );
  }
}