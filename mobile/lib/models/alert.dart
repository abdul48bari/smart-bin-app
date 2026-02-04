import 'package:cloud_firestore/cloud_firestore.dart';

class AlertModel {
  final String id;
  final String message;
  final String severity;
  final DateTime createdAt;
  final bool isResolved;  // ← NEW FIELD

  AlertModel({
    required this.id,
    required this.message,
    required this.severity,
    required this.createdAt,
    this.isResolved = false,  // ← DEFAULT FALSE
  });

  factory AlertModel.fromFirestore(String id, Map<String, dynamic> data) {
    return AlertModel(
      id: id,
      message: data['message'] ?? 'Unknown alert',
      severity: data['severity'] ?? 'info',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isResolved: data['isResolved'] ?? false,  // ← READ FROM FIRESTORE
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'message': message,
      'severity': severity,
      'createdAt': Timestamp.fromDate(createdAt),
      'isResolved': isResolved,  // ← SAVE TO FIRESTORE
    };
  }
}
