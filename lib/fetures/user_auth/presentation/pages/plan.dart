import 'package:TafweejHub/main.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:TafweejHub/fetures/user_auth/presentation/pages/ChatScreenAdmin.dart';
import 'package:TafweejHub/fetures/user_auth/presentation/pages/NotificationPage.dart';
import 'package:TafweejHub/fetures/user_auth/presentation/pages/profile.dart';
import 'package:TafweejHub/fetures/user_auth/presentation/pages/ChatScreen.dart';
import 'package:TafweejHub/fetures/user_auth/presentation/pages/map_screen.dart';
import 'package:TafweejHub/fetures/user_auth/support_information.dart';
import 'package:TafweejHub/fetures/user_auth/presentation/pages/faq_screen.dart';

class Plan {
 final String id;
  final String description;
  final DateTime dateTime;
  final DateTime modifyDate;
  final String createdBy;
  final String? groupId;

  Plan({
     required this.id,
    required this.description,
    required this.dateTime,
    required this.modifyDate,
    required this.createdBy,
    this.groupId,
  });

  factory Plan.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Plan(
      id: doc.id,
      description: data['description'] ?? '',
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      modifyDate: (data['modifyDate'] as Timestamp).toDate(),
      createdBy: data['createdBy'] ?? '',
       groupId: data['groupId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'dateTime': Timestamp.fromDate(dateTime),
      'modifyDate': Timestamp.fromDate(modifyDate),
      'createdBy': createdBy,
       'groupId': groupId,
    };
  }
}

class PlanScreen extends StatefulWidget {
  final String userId;

  const PlanScreen({super.key, required this.userId});

  @override
  _PlanScreenState createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteTextColor: Colors.blue,
              dayPeriodTextColor: Colors.blue,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _addPlan() async {
    if (_descriptionController.text.isEmpty || _selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {

       DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();
    
    String? userGroupId = userDoc.get('groupId');

      final DateTime newPlanDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

 // Check for conflicting plans across all groups
    QuerySnapshot conflictingPlans = await FirebaseFirestore.instance
        .collection('plans')
        .where('dateTime', isEqualTo: Timestamp.fromDate(newPlanDateTime))
        .get();

    // If there are conflicting plans, show a confirmation dialog
    if (conflictingPlans.docs.isNotEmpty) {
      bool? confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Plan Conflict Detected'),
          content: Text('There is already a plan at ${_selectedTime!.format(context)} on ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}. Do you want to proceed?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Proceed'),
            ),
          ],
        ),
      );

      // If user cancels, stop the plan creation
      if (confirmed != true) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
    }
 

      final plan = Plan(
        id: '',
        description: _descriptionController.text,
        dateTime: newPlanDateTime,
        modifyDate: DateTime.now(),
        createdBy: widget.userId,
         groupId: userGroupId,
      );

      // Add to Firestore
      await FirebaseFirestore.instance.collection('plans').add(plan.toMap());

      // Clear form
      _descriptionController.clear();
      setState(() {
        _selectedDate = null;
        _selectedTime = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Plan added successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding plan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildPlanList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('plans')
          .orderBy('dateTime', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final plans = snapshot.data?.docs
            .map((doc) => Plan.fromFirestore(doc))
            .toList() ?? [];

        if (plans.isEmpty) {
          return const Center(
            child: Text(
              "No plans added yet.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          itemCount: plans.length,
          itemBuilder: (context, index) {
            final plan = plans[index];
            final bool isPastEvent = plan.dateTime.isBefore(DateTime.now());

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                leading: Icon(
                  Icons.event,
                  color: isPastEvent ? Colors.grey : Colors.blue,
                ),
                title: Text(
                  plan.description,
                  style: TextStyle(
                    decoration: isPastEvent ? TextDecoration.lineThrough : null,
                    color: isPastEvent ? Colors.grey : Colors.black,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Planned for: ${DateFormat('yyyy-MM-dd – HH:mm').format(plan.dateTime)}",
                      style: TextStyle(
                        color: isPastEvent ? Colors.grey : Colors.black54,
                      ),
                    ),
                    Text(
                      "Modified: ${DateFormat('yyyy-MM-dd – HH:mm').format(plan.modifyDate)}",
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                trailing: PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                  onSelected: (value) async {
                    if (value == 'delete') {
                      // Add delete confirmation dialog
                      final delete = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Plan'),
                          content: const Text('Are you sure you want to delete this plan?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );

                      if (delete == true) {
                        await FirebaseFirestore.instance
                            .collection('plans')
                            .doc(plan.id)
                            .delete();
                      }
                    }
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }


  static Future<String?> checkUserRole(String userId) async {
    try {
      if (userId.isEmpty) {
        print("Error: userId is empty");
        return null;
      }

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        return userDoc.get('role') as String?; // returns 'admin' or 'user'
      } else {
        print("User not found: $userId");
        return null;
      }
    } catch (e) {
      print("Error fetching user role: $e");
      return null;
    }
  }

  static void navigateBasedOnRole(String userId, BuildContext context) async {
    try {
      if (userId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User ID is missing')),
        );
        return;
      }

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      String? role = await checkUserRole(userId);
      
      // Hide loading indicator
      Navigator.pop(context);

      if (!context.mounted) return;

      switch (role) {
        case 'admin':
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreenAdmin(userId: userId),
            ),
          );
          break;
        
        case 'user':
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreenUser(userId: userId),
            ),
          );
          break;
        
        default:
          // If role is null or unknown, show an error message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unable to determine user role. Please try again later.'),
              duration: Duration(seconds: 3),
            ),
          );
      }
    } catch (e) {
      if (!context.mounted) return;
      
      // Hide loading indicator if it's still showing
      Navigator.of(context, rootNavigator: true).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  static void navigateBasedOnRole1(String userId, BuildContext context) async {
    try {
      if (userId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User ID is missing')),
        );
        return;
      }

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      String? role = await checkUserRole(userId);
      
      // Hide loading indicator
      Navigator.pop(context);

      if (!context.mounted) return;

      if (role == 'admin') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MapScreen(isAdmin: true, userId: userId),
          ),
        );
      } else if (role == 'user') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MapScreen(isAdmin: false, userId: userId),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to determine user role. Please try again later.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      
      // Hide loading indicator if it's still showing
      Navigator.of(context, rootNavigator: true).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Plan Timeline"),
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.perm_identity),
            color: Colors.grey,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage(userId: widget.userId)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chat),
            color: Colors.grey,
            onPressed: () => navigateBasedOnRole(widget.userId, context),
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            color: Colors.grey,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NotificationPage(userId: widget.userId)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.translate),
            color: Colors.grey,
            onPressed: () {
              // Implement translation logic
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _selectDate(context),
                        icon: const Icon(Icons.calendar_today),
                        label: Text(
                          _selectedDate == null
                              ? 'Choose Date'
                              : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _selectTime(context),
                        icon: const Icon(Icons.access_time),
                        label: Text(
                          _selectedTime == null
                              ? 'Choose Time'
                              : _selectedTime!.format(context),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _addPlan,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Add Plan'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _buildPlanList()),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.black,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.map),
              color: Colors.grey,
              onPressed: () => navigateBasedOnRole1(widget.userId, context),
            ),
            IconButton(
              icon: const Icon(Icons.security),
              color: Colors.grey,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SupportScreen()),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.warning),
              color: Colors.grey,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FaqScreen()),
              ),
            ),
            TextButton(
              onPressed: () {
                // Implement emergency call logic
              },
              child: const Text(
                'Emergency Call',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}