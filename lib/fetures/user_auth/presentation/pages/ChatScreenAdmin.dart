import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';







class ChatScreenAdmin extends StatefulWidget {
  final String userId;
  const ChatScreenAdmin({Key? key, required this.userId}) : super(key: key);

  @override
  _ChatScreenAdminState createState() => _ChatScreenAdminState();
}

class _ChatScreenAdminState extends State<ChatScreenAdmin> {
  final TextEditingController _textController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? selectedUserId;
  String? selectedUserName;
  String adminGroupId = '';
  
  @override
  void initState() {
    super.initState();
    _fetchAdminData();
  }

 Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      await _uploadFile(File(pickedFile.path), 'image');
    }
  }

  //  method to pick and upload videos
  Future<void> _pickAndUploadVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);

    if (pickedFile != null) {
      await _uploadFile(File(pickedFile.path), 'video');
    }
  }

  // Method to upload file to Firebase Storage
  Future<void> _uploadFile(File file, String fileType) async {
    if (selectedUserId == null) return;

    try {
      // Create a reference to the location you want to store the file
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('chat_files')
          .child('${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}');

      // Upload the file
      final uploadTask = await storageRef.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      // Send a message with the file URL
      final chatId = '${selectedUserId}_${widget.userId}';
      await _firestore.collection('chats').doc(chatId).collection('messages').add({
        'senderId': widget.userId,
        'receiverId': selectedUserId,
        'fileUrl': downloadUrl,
        'fileType': fileType,
        'timestamp': FieldValue.serverTimestamp(),
        'senderName': 'User',
      });
    } catch (e) {
      debugPrint('Error uploading file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload $fileType')),
      );
    }
  }



  Future<void> _fetchAdminData() async {
    try {
      final adminDoc = await _firestore.collection('users').doc(widget.userId).get();
      if (adminDoc.exists) {
        setState(() {
          adminGroupId = adminDoc.data()?['groupId'] ?? '';
        });
      }
    } catch (e) {
      debugPrint('Error fetching admin data: $e');
    }
  }

  Future<void> _selectUser() async {
    try {
      final usersSnapshot = await _firestore
          .collection('users')
          .where('groupId', isEqualTo: adminGroupId)
          .where('role', isEqualTo: 'user')
          .get();

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Select User'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: usersSnapshot.docs.length,
              itemBuilder: (context, index) {
                final userData = usersSnapshot.docs[index].data();
                return ListTile(
                  title: Text(userData['name'] ?? 'Unknown'),
                  subtitle: Text('ID: ${userData['ID']}'),
                  onTap: () {
                    setState(() {
                      selectedUserId = userData['ID'];
                      selectedUserName = userData['name'];
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error loading users: $e');
    }
  }

  Stream<QuerySnapshot> _getMessages() {
    if (selectedUserId == null) return const Stream.empty();
    
    return _firestore
        .collection('chats')
        .doc('${widget.userId}_$selectedUserId')
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> _handleSubmitted(String text) async {
    if (text.isEmpty || selectedUserId == null) return;

    _textController.clear();
    final chatId = '${widget.userId}_$selectedUserId';
    
    try {
      await _firestore.collection('chats').doc(chatId).collection('messages').add({
        'senderId': widget.userId,
        'receiverId': selectedUserId,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
        'senderName': 'Admin',
      });
    } catch (e) {
      debugPrint('Error sending message: $e');
    }
  }

 
Widget _buildMessage(Map<String, dynamic> message) {
  final isSentByMe = message['senderId'] == widget.userId;
  
  // Convert Firestore timestamp to DateTime
  DateTime? timestamp;
  if (message['timestamp'] != null) {
    timestamp = (message['timestamp'] as Timestamp).toDate();
  }

  // Format the timestamp
  String formattedTime = timestamp != null 
    ? _formatTimestamp(timestamp)
    : 'Just now';

    // Check if message contains a file
    if (message['fileUrl'] != null) {
      return _buildFileMessage(message, isSentByMe);
    }


  return Align(
    alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
    child: Container(
      margin: EdgeInsets.only(
        left: isSentByMe ? 50 : 10,
        right: isSentByMe ? 10 : 50,
        top: 5,
        bottom: 5,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: isSentByMe ? Colors.blue[700] : Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                message['senderName'] ?? 'Unknown',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSentByMe ? Colors.white : Colors.black,
                ),
              ),
              Text(
                formattedTime,
                style: TextStyle(
                  fontSize: 10,
                  color: isSentByMe ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            message['text'] ?? '',
            style: TextStyle(
              color: isSentByMe ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    ),
  );
}



 // method to build file message widget WITH FILES
  Widget _buildFileMessage(Map<String, dynamic> message, bool isSentByMe) {
    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          left: isSentByMe ? 50 : 10,
          right: isSentByMe ? 10 : 50,
          top: 5,
          bottom: 5,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: isSentByMe ? Colors.blue[700] : Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  message['senderName'] ?? 'Unknown',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSentByMe ? Colors.white : Colors.black,
                  ),
                ),
                Text(
                  _formatTimestamp(
                    (message['timestamp'] as Timestamp).toDate()
                  ),
                  style: TextStyle(
                    fontSize: 10,
                    color: isSentByMe ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            // Display file type icon or preview
            _buildFilePreview(message),
          ],
        ),
      ),
    );
  }

  Widget _buildFilePreview(Map<String, dynamic> message) {
    final fileType = message['fileType'];
    final fileUrl = message['fileUrl'];

    if (fileType == 'image') {
      return GestureDetector(
        onTap: () {
          // Implement full screen image view
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(),
                body: Center(
                  child: Image.network(fileUrl),
                ),
              ),
            ),
          );
        },
        child: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              image: NetworkImage(fileUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    } else if (fileType == 'video') {
      return GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Video playback coming soon')),
          );
        },
        child: Container(
          width: 200,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Icon(
              Icons.play_circle_fill,
              size: 50,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    return SizedBox.shrink();
  }





// Add this helper method to format timestamps
String _formatTimestamp(DateTime timestamp) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = DateTime(now.year, now.month, now.day - 1);
  final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

  if (messageDate == today) {
    // Today: show time
    return DateFormat('HH:mm').format(timestamp);
  } else if (messageDate == yesterday) {
    // Yesterday: show 'Yesterday'
    return 'Yesterday ${DateFormat('HH:mm').format(timestamp)}';
  } else if (now.difference(timestamp).inDays < 7) {
    // Within a week: show day and time
    return DateFormat('EEE HH:mm').format(timestamp);
  } else {
    // Older: show full date
    return DateFormat('dd/MM/yy HH:mm').format(timestamp);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(selectedUserName ?? 'Select User'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: _selectUser,
          ),
        ],
      ),
      body: Column(
        children: [
          if (selectedUserId == null)
            const Expanded(
              child: Center(
                child: Text('Select a user to start chatting'),
              ),
            )
          else
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _getMessages(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return ListView.builder(
                    reverse: true,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      return _buildMessage(
                        snapshot.data!.docs[index].data() as Map<String, dynamic>
                      );
                    },
                  );
                },
              ),
            ),
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.video_library),
                    onPressed: _pickAndUploadVideo,
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () => _handleSubmitted(_textController.text),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}