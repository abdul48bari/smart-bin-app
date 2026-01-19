import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/time_filter.dart';
import 'analytics_bar.dart';

class BinAnalyticsSection extends StatefulWidget {
  final String binId;

  const BinAnalyticsSection({super.key, required this.binId});

  @override
  State<BinAnalyticsSection> createState() => _BinAnalyticsSectionState();
}

class _BinAnalyticsSectionState extends State<BinAnalyticsSection> {
  TimeFilter _selectedFilter = TimeFilter.week;

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 FILTER PILLS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: TimeFilter.values.map((filter) {
              final bool isSelected = _selectedFilter == filter;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedFilter = filter;
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.green : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    filter.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // 🔹 BAR CHART
          StreamBuilder<Map<String, int>>(
            stream: firestoreService.getFullCountsByTimeFilter(
              widget.binId,
              _selectedFilter,
            ),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text(
                  'Error loading analytics',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                );
              }

              if (!snapshot.hasData) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final Map<String, int> data = snapshot.data!;

              final int maxValue = data.values.isEmpty
                  ? 0
                  : data.values.reduce((a, b) => a > b ? a : b);

              return Column(
                children: data.entries.map((entry) {
                  return AnalyticsBar(
                    label: entry.key,
                    value: entry.value,
                    maxValue: maxValue,
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
