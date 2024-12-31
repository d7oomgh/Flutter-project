import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

// Model for Schedule notifications
class ScheduleNotification {
  final String id;
  final String description;
  final DateTime dateTime;
  final DateTime modifyDate;
  final double? latitude;
  final double? longitude;

  ScheduleNotification({
    required this.id,
    required this.description,
    required this.dateTime,
    required this.modifyDate,
    this.latitude,
    this.longitude,
  });

  factory ScheduleNotification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ScheduleNotification(
      id: doc.id,
      description: data['description'] ?? '',
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      modifyDate: (data['modifyDate'] as Timestamp).toDate(),
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
    );
  }
}

// Model for Alert notifications
class AlertNotification {
  final String id;
  final String message;
  final DateTime timestamp;
  final String sentBy;
  final String userId;
  final double? latitude;
  final double? longitude;

  AlertNotification({
    required this.id,
    required this.message,
    required this.timestamp,
    required this.sentBy,
    required this.userId,
    this.latitude,
    this.longitude,
  });

  factory AlertNotification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AlertNotification(
      id: doc.id,
      message: data['message'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      sentBy: data['sentBy'] ?? '',
      userId: data['userId'] ?? '',
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
    );
  }
}

class NotificationPage extends StatelessWidget {
  final String userId;

  const NotificationPage({super.key, required this.userId});

  Future<void> _launchMap(double latitude, double longitude) async {
    final googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      throw 'Could not open the map.';
    }
  }

Future<String?> _getUserGroupId() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      return userDoc.get('groupId') as String?;
    } catch (e) {
      print('Error fetching user groupId: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: FutureBuilder<String?>(
         future: _getUserGroupId(),
        builder: (context, groupSnapshot) {
          if (groupSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!groupSnapshot.hasData) {
            return const Center(child: Text('Unable to fetch user groupId'));
          }

          final userGroupId = groupSnapshot.data;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('plans')
                .where('groupId', isEqualTo: userGroupId)
                .orderBy('dateTime', descending: true)
                .snapshots(),
            builder: (context, schedulesSnapshot) {
              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('alerts')
                    .where('userId', isEqualTo: userId)
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, alertsSnapshot) {
                  if (schedulesSnapshot.connectionState == ConnectionState.waiting ||
                      alertsSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Handle errors
                  if (schedulesSnapshot.hasError || alertsSnapshot.hasError) {
                    return Center(
                      child: Text('Error: ${schedulesSnapshot.error ?? alertsSnapshot.error}'),
                    );
                  }

                  // Process schedules
                  final schedules = schedulesSnapshot.data?.docs
                          .map((doc) => ScheduleNotification.fromFirestore(doc))
                          .toList() ??
                      [];

                  // Process alerts
                  final alerts = alertsSnapshot.data?.docs
                          .map((doc) => AlertNotification.fromFirestore(doc))
                          .toList() ??
                      [];

                  // Combine and sort notifications
                  final combinedNotifications = [
                    ...schedules.map((schedule) => _NotificationItem(
                          id: schedule.id,
                          title: schedule.description,
                          datetime: schedule.dateTime,
                          type: 'schedule',
                          latitude: schedule.latitude,
                          longitude: schedule.longitude,
                        )),
                    ...alerts.map((alert) => _NotificationItem(
                          id: alert.id,
                          title: alert.message,
                          datetime: alert.timestamp,
                          type: 'alert',
                          latitude: alert.latitude,
                          longitude: alert.longitude,
                        ))
                  ];

                  // Sort by datetime
                  combinedNotifications.sort((a, b) => b.datetime.compareTo(a.datetime));

                  if (combinedNotifications.isEmpty) {
                    return const Center(child: Text("No notifications available."));
                  }

                  return ListView.builder(
                    itemCount: combinedNotifications.length,
                    itemBuilder: (context, index) {
                      final notification = combinedNotifications[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: ListTile(
                          leading: Icon(
                            notification.type == 'alert'
                                ? Icons.notification_important
                                : Icons.event,
                            color: notification.type == 'alert'
                                ? Colors.red
                                : Colors.blue,
                          ),
                          title: Text(notification.title),
                          subtitle: Text(
                            DateFormat('yyyy-MM-dd – HH:mm').format(notification.datetime),
                          ),
                          trailing: notification.latitude != null &&
                                  notification.longitude != null
                              ? ElevatedButton.icon(
                                  onPressed: () => _launchMap(
                                    notification.latitude!,
                                    notification.longitude!,
                                  ),
                                  icon: const Icon(Icons.directions),
                                  label: const Text("Direction"),
                                )
                              : null,
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

// Helper class to combine both types of notifications
class _NotificationItem {
  final String id;
  final String title;
  final DateTime datetime;
  final String type;
  final double? latitude;
  final double? longitude;

  _NotificationItem({
    required this.id,
    required this.title,
    required this.datetime,
    required this.type,
    this.latitude,
    this.longitude,
  });
}