import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/bin_sub.dart';
import '../widgets/bin_overview_card.dart';
import '../widgets/bin_analytics_section.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      body: Container(
        color: const Color(0xFFF3F7F4),
        child: StreamBuilder<List<BinSub>>(
          stream: firestoreService.getSubBins('BIN_001'),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Error loading data'));
            }

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final bins = snapshot.data!;

            return SingleChildScrollView(
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
  'Smart Bin',
  style: Theme.of(context).textTheme.headlineLarge,
),
const SizedBox(height: 4),
Text(
  'Live waste monitoring',
  style: Theme.of(context).textTheme.bodyMedium,
),

      const SizedBox(height: 20),
      BinOverviewCard(
  binName: 'Bin 1',
  subBins: bins,
),

const SizedBox(height: 24),

Text(
  'Analytics',
  style: Theme.of(context)
      .textTheme
      .headlineMedium
      ?.copyWith(fontWeight: FontWeight.w700),
),


const SizedBox(height: 12),

BinAnalyticsSection(binId: 'BIN_001'),

    ],
  ),
);

          },
        ),
      ),
    );
  }
}
