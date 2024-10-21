import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return NotificationModel(
      id: id,
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'timestamp': timestamp,
    };
  }
}
