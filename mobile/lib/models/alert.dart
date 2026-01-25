import 'package:cloud_firestore/cloud_firestore.dart';

class AlertModel {
  final String id;
  final String binId;
  final String subBin;
  final String alertType;
  final String message;
  final bool resolved;
  final DateTime createdAt;

  AlertModel({
    required this.id,
    required this.binId,
    required this.subBin,
    required this.alertType,
    required this.message,
    required this.resolved,
    required this.createdAt,
  });

  factory AlertModel.fromFirestore(String id, Map<String, dynamic> data) {
    return AlertModel(
      id: id,
      binId: data['binId'] ?? '',
      subBin: data['subBin'] ?? '',
      alertType: data['alertType'] ?? '',
      message: data['message'] ?? '',
      resolved: data['resolved'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
