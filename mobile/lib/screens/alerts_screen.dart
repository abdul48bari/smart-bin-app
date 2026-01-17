import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/alert.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Alerts'),
      ),
      body: StreamBuilder<List<AlertModel>>(
        stream: firestoreService.getActiveAlerts('BIN_001'),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading alerts'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final alerts = snapshot.data!;

          if (alerts.isEmpty) {
            return const Center(child: Text('No active alerts'));
          }

          return ListView.builder(
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final alert = alerts[index];

              return ListTile(
                leading: const Icon(Icons.warning, color: Colors.red),
                title: Text(alert.alertType),
                subtitle: Text(alert.message),
              );
            },
          );
        },
      ),
    );
  }
}
