// ignore_for_file: prefer_const_constructors

import 'package:TafweejHub/fetures/user_auth/presentation/pages/ChatScreenAdmin.dart';
import 'package:TafweejHub/fetures/user_auth/presentation/pages/NotificationPage.dart';
import 'package:TafweejHub/fetures/user_auth/presentation/pages/RitualDetailPage.dart';
import 'package:TafweejHub/fetures/user_auth/presentation/pages/faq_screen.dart';
import 'package:TafweejHub/fetures/user_auth/presentation/pages/map_screen.dart';
import 'package:TafweejHub/fetures/user_auth/presentation/pages/profile.dart';
import 'package:TafweejHub/fetures/user_auth/support_information.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:TafweejHub/fetures/user_auth/presentation/pages/ChatScreen.dart';
import 'package:TafweejHub/fetures/user_auth/presentation/pages/plan.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  final String userId;

   HomePage({super.key, required this.userId}) {
    assert(userId.isNotEmpty, 'User ID must not be empty.');
  }

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isArabic = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }


Future<void> _handleLogout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      // Navigate to login screen and remove all previous routes
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isArabic ? 'حدث خطأ أثناء تسجيل الخروج' : 'Error occurred during logout'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


 void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isArabic ? 'تسجيل الخروج' : 'Logout'),
          content: Text(
            isArabic 
              ? 'هل أنت متأكد أنك تريد تسجيل الخروج؟' 
              : 'Are you sure you want to logout?'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(isArabic ? 'إلغاء' : 'Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleLogout(context);
              },
              child: Text(
                isArabic ? 'تسجيل الخروج' : 'Logout',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }





  Future<String?> checkUserRole(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        return userDoc['role'];
      }
      return null;
    } catch (e) {
      print("Error fetching user role: $e");
      return null;
    }
  }

  void navigateBasedOnRole(String userId, BuildContext context) async {
    String? role = await checkUserRole(userId);
    if (role == 'admin') {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => ChatScreenAdmin(userId: userId)));
    } else if (role == 'user') {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => ChatScreenUser(userId: userId)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User role not recognized.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          _buildWelcomeCard(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildHajjContent(),
                _buildUmrahContent(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }





  void navigateBasedOnRole2(String userId, BuildContext context) async {
   // Get the user role based on the userId
  String? role = await checkUserRole(userId);

  if (role == 'admin') {
    // Navigate to the admin version of the MapScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlanScreen(userId: userId),
      ),
    );
  } else if (role == 'user') {
    // Navigate to the user version of the MapScreen
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User role not Admin.")),
      );
  } 
  }



  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color.fromARGB(255, 2, 0, 10),
      title: Text(
        isArabic ? "الصفحة الرئيسية" : "Home page",
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.perm_identity, color: Colors.white),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ProfilePage(userId: widget.userId)),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chat, color: Colors.white),
          onPressed: () => navigateBasedOnRole(widget.userId, context),
        ),
        IconButton(
          icon: const Icon(Icons.notifications, color: Colors.white),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => NotificationPage(userId: widget.userId)),
          ),
        ),
         IconButton(
            icon: Icon(Icons.event_note), // Plan icon
            color: Colors.grey,
            onPressed: () {
              navigateBasedOnRole2(widget.userId, context);
            },
          ),
        IconButton(
          icon: const Icon(Icons.translate, color: Colors.white),
          onPressed: () => setState(() => isArabic = !isArabic),
        ),
         IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: () => _showLogoutDialog(context),
        ),
      ],
    );
  }



    Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }





  Widget _buildWelcomeCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color.fromARGB(255, 54, 68, 161),
            const Color.fromARGB(255, 15, 16, 16).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 2, 0, 10).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isArabic ? "TafweejHub مرحباً بكم في" : "Welcome to TafweejHub",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isArabic
                ? "دليلك الشامل للحج والعمرة"
                : "Your comprehensive guide for Hajj and Umrah",
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(25),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: const Color.fromARGB(255, 70, 105, 142),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: const Color.fromARGB(125, 117, 117, 117),
        tabs: [
          Tab(text: isArabic ? "الحج" : "Hajj"),
          Tab(text: isArabic ? "العمرة" : "Umrah"),
        ],
      ),
    );
  }

  Widget _buildRitualCard(String title, String description, IconData icon,String details) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color.fromARGB(255, 79, 85, 147).withOpacity(0.2),
          child: Icon(icon, color: const Color.fromARGB(255, 17, 0, 255)),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RitualDetailPage(
              title: title,
              details: details,
            ),
          ),
        );
          // Navigate to detailed ritual page
        },
      ),
    );
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

  Widget _buildHajjContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildRitualCard(
            isArabic ? "الإحرام" : "Ihram",
            isArabic ? "النية والملابس المخصصة" : "Sacred state and special clothing",
            Icons.accessibility_new,isArabic
              ? "يُحرم المسلمُ من المكان المحدد له شرعاً، ويمتنع عن المحظورات..."
              : "A Muslim enters into the state of Ihram at the place specified by Sharia...",
          ),
          _buildRitualCard(
            isArabic ? "الطواف" : "Tawaf",
            isArabic ? "الدوران حول الكعبة" : "Circumambulation of the Kaaba",
            Icons.rotate_right,isArabic
              ? "يُحرم المسلمُ من المكان المحدد له شرعاً، ويمتنع عن المحظورات..."
              : "A Muslim enters into the state of Ihram at the place specified by Sharia...",
          ),
          _buildRitualCard(
            isArabic ? "السعي" : "Sa'i",
            isArabic ? "المشي بين الصفا والمروة" : "Walking between Safa and Marwa",
            Icons.directions_walk,isArabic
              ? "يُحرم المسلمُ من المكان المحدد له شرعاً، ويمتنع عن المحظورات..."
              : "A Muslim enters into the state of Ihram at the place specified by Sharia...",
          ),
          _buildRitualCard(
            isArabic ? "الوقوف بعرفة" : "Wuquf at Arafat",
            isArabic ? "الركن الأعظم للحج" : "Standing at Mount Arafat",
            Icons.landscape,isArabic
              ? "يُحرم المسلمُ من المكان المحدد له شرعاً، ويمتنع عن المحظورات..."
              : "A Muslim enters into the state of Ihram at the place specified by Sharia...",
          ),
          _buildRitualCard(
            isArabic ? "المبيت بمزدلفة" : "Stay at Muzdalifah",
            isArabic ? "جمع الحصى ومبيت" : "Collecting pebbles and overnight stay",
            Icons.nightlight_round,isArabic
              ? "يُحرم المسلمُ من المكان المحدد له شرعاً، ويمتنع عن المحظورات..."
              : "A Muslim enters into the state of Ihram at the place specified by Sharia...",
          ),
          _buildRitualCard(
            isArabic ? "رمي الجمرات" : "Stoning of Jamarat",
            isArabic ? "رمي الشيطان" : "Stoning the pillars",
            Icons.radio_button_unchecked,isArabic
              ? "يُحرم المسلمُ من المكان المحدد له شرعاً، ويمتنع عن المحظورات..."
              : "A Muslim enters into the state of Ihram at the place specified by Sharia...",
          ),
        ],
      ),
    );
  }

 Widget _buildUmrahContent() {
  return SingleChildScrollView(
    child: Column(
      children: [
        const SizedBox(height: 16),
        _buildRitualCard(
          isArabic ? "الإحرام" : "Ihram",
          isArabic ? "النية والملابس المخصصة" : "Sacred state and special clothing",
          Icons.accessibility_new,
          isArabic
              ? "يُحرم المسلمُ من المكان المحدد له شرعاً، ويمتنع عن المحظورات..."
              : "A Muslim enters into the state of Ihram at the place specified by Sharia...",
        ),
        _buildRitualCard(
          isArabic ? "الطواف" : "Tawaf",
          isArabic ? "الدوران حول الكعبة" : "Circumambulation of the Kaaba",
          Icons.rotate_right,
          isArabic
              ? "يتجه إلى الحرم، ويطوف بالكعبة سبع مرات، جاعلًا الكعبة عن يساره..."
              : "He/she goes to the Haram, circumambulates the Kaaba counterclockwise...",
        ),
        _buildRitualCard(
          isArabic ? "السعي" : "Sa'i",
          isArabic ? "المشي بين الصفا والمروة" : "Walking between Safa and Marwa",
          Icons.directions_walk,
          isArabic
              ? "يتوجه إلى الصفا، ويبتدئ منها السعي نحو المروة..."
              : "He/she heads to Safa and starts Sa’i towards Marwa. Upon reaching Marwa...",
        ),
        _buildRitualCard(
          isArabic ? "الحلق أو التقصير" : "Halq or Taqsir",
          isArabic ? "حلق أو تقصير الشعر" : "Shaving or trimming of hair",
          Icons.content_cut,
          isArabic
              ? "بعد تمام السعي، يتوجه الرجل إلى محلات الحلاقة، فيحلق أو يقصر شعره..."
              : "After completing Sa’i, men proceed to have their hair shaved or trimmed...",
        ),
      ],
    ),
  );
}


  Widget _buildBottomBar(BuildContext context) {
    return BottomAppBar(
      color: const Color.fromARGB(255, 2, 0, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.map),
            color: Colors.white,
            onPressed: () => navigateBasedOnRole1(widget.userId, context),
          ),
          IconButton(
            icon: const Icon(Icons.security),
            color: Colors.white,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SupportScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.warning),
            color: Colors.white,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FaqScreen()),
            ),
          ),
          TextButton(
            onPressed: () =>  _makePhoneCall('911'),
              //Emergency call handling
            
            child: Text(
              isArabic ? "اتصال طوارئ" : "Emergency Call",
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}