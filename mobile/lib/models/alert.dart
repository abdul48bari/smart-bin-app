import 'package:cloud_firestore/cloud_firestore.dart';

class AlertModel {
  final String id;
  final String message;
  final String severity;      // "warning" or "error"
  final String alertType;     // "BIN_FULL", "HARDWARE_ERROR", "BATTERY_DETECTED", "HARMFUL_GAS", "MOISTURE_DETECTED"
  final String? subBin;       // which sub-bin is affected (null for HARMFUL_GAS)
  final DateTime createdAt;
  final bool isResolved;
  final DateTime? resolvedAt;

  // Extra fields for HARMFUL_GAS
  final String? gasType;      // "methane", "ammonia", "hydrogen_sulfide", etc.
  final int? gasLevel;        // PPM

  // Extra field for MOISTURE_DETECTED
  final int? moistureLevel;   // 0-100 percentage

  AlertModel({
    required this.id,
    required this.message,
    required this.severity,
    required this.alertType,
    this.subBin,
    required this.createdAt,
    this.isResolved = false,
    this.resolvedAt,
    this.gasType,
    this.gasLevel,
    this.moistureLevel,
  });

  factory AlertModel.fromFirestore(String id, Map<String, dynamic> data) {
    return AlertModel(
      id: id,
      message: data['message'] ?? 'Unknown alert',
      severity: data['severity'] ?? 'info',
      alertType: data['alertType'] ?? 'UNKNOWN',
      subBin: data['subBin'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isResolved: data['isResolved'] ?? false,
      resolvedAt: (data['resolvedAt'] as Timestamp?)?.toDate(),
      gasType: data['gasType'] as String?,
      gasLevel: data['gasLevel'] != null ? (data['gasLevel'] as num).toInt() : null,
      moistureLevel: data['moistureLevel'] != null ? (data['moistureLevel'] as num).toInt() : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'message': message,
      'severity': severity,
      'alertType': alertType,
      'subBin': subBin,
      'createdAt': Timestamp.fromDate(createdAt),
      'isResolved': isResolved,
      'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
      if (gasType != null) 'gasType': gasType,
      if (gasLevel != null) 'gasLevel': gasLevel,
      if (moistureLevel != null) 'moistureLevel': moistureLevel,
    };
  }

  /// Whether this alert type requires manual resolution
  bool get requiresManualResolution {
    return alertType == 'BATTERY_DETECTED' ||
        alertType == 'HARMFUL_GAS' ||
        alertType == 'MOISTURE_DETECTED' ||
        alertType == 'HARDWARE_ERROR';
  }

  /// Whether this is a safety alert (new types)
  bool get isSafetyAlert {
    return alertType == 'BATTERY_DETECTED' ||
        alertType == 'HARMFUL_GAS' ||
        alertType == 'MOISTURE_DETECTED';
  }
}
