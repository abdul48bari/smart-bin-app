import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/bin_sub.dart';
import 'alerts_screen.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        actions: [
  IconButton(
    icon: const Icon(Icons.warning),
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const AlertsScreen(),
        ),
      );
    },
  )
],

        




        title: const Text('Smart Bin Status'),
      ),
      body: StreamBuilder<List<BinSub>>(
        stream: firestoreService.getSubBins('BIN_001'),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading data'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final bins = snapshot.data!;

          return ListView.builder(
            itemCount: bins.length,
            itemBuilder: (context, index) {
              final bin = bins[index];

              return ListTile(
                leading: Icon(
                  Icons.delete,
                  color: bin.isFull ? Colors.red : Colors.green,
                ),
                title: Text(bin.name.toUpperCase()),
                subtitle: Text(
                  'Fill level: ${bin.currentFillPercent}%',
                ),
                trailing: bin.isFull
                    ? const Text(
                        'FULL',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : const Text('OK'),
              );
            },
          );
        },
      ),
    );
  }
}
