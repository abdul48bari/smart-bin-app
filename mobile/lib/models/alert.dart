class AlertModel {
  final String id;
  final String alertType;
  final String message;
  final bool resolved;

  AlertModel({
    required this.id,
    required this.alertType,
    required this.message,
    required this.resolved,
  });

  factory AlertModel.fromFirestore(String id, Map<String, dynamic> data) {
    return AlertModel(
      id: id,
      alertType: data['alertType'] ?? '',
      message: data['message'] ?? '',
      resolved: data['resolved'] ?? false,
    );
  }
}
