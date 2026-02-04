import 'package:flutter/material.dart';
import '../models/alert.dart';
import '../services/firestore_service.dart';
import '../utils/app_colors.dart';

class AlertsScreen extends StatelessWidget {
  final String binId;

  const AlertsScreen({
    super.key,
    required this.binId,
  });

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();
    final accent = AppColors.accent(context);

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: Text(
          'Alerts - $binId',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary(context),
          ),
        ),
        backgroundColor: AppColors.surface(context),
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary(context)),
      ),
      body: StreamBuilder<List<AlertModel>>(
        stream: firestoreService.getActiveAlerts(binId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: accent,
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 80,
                    color: Colors.green.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No alerts',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'All systems operating normally',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary(context).withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            );
          }

          final alerts = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              return _AlertCard(
                alert: alerts[index],
                binId: binId,
              );
            },
          );
        },
      ),
    );
  }
}

// ALERT CARD WIDGET - CLEAN VERSION
class _AlertCard extends StatefulWidget {
  final AlertModel alert;
  final String binId;

  const _AlertCard({
    required this.alert,
    required this.binId,
  });

  @override
  State<_AlertCard> createState() => _AlertCardState();
}

class _AlertCardState extends State<_AlertCard> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Simple background color - no gradients
    final backgroundColor = widget.alert.isResolved
        ? (isDark ? Colors.green.withOpacity(0.15) : Colors.green.withOpacity(0.1))
        : AppColors.surface(context);
    
    return GestureDetector(
      onTap: () {
        setState(() => expanded = !expanded);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER ROW
            Row(
              children: [
                Icon(
                  widget.alert.isResolved 
                      ? Icons.check_circle_rounded
                      : Icons.warning_amber_rounded,
                  color: widget.alert.isResolved 
                      ? Colors.green
                      : Colors.redAccent,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.alert.message,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: widget.alert.isResolved 
                          ? AppColors.textSecondary(context)
                          : AppColors.textPrimary(context),
                    ),
                  ),
                ),
                Icon(
                  expanded
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                  color: AppColors.textSecondary(context),
                ),
              ],
            ),

            // EXPANDED DETAILS
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 250),
              crossFadeState: expanded
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _detail("Bin", widget.binId),
                    _detail("Severity", widget.alert.severity),
                    _detail("Time", _format(widget.alert.createdAt)),
                    _detail("Status", widget.alert.isResolved ? "Resolved ✓" : "Active ⚠️"),
                  ],
                ),
              ),
              secondChild: const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        "$label: $value",
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary(context),
        ),
      ),
    );
  }

  String _format(DateTime dt) {
    return "${dt.day.toString().padLeft(2, '0')}/"
        "${dt.month.toString().padLeft(2, '0')}/"
        "${dt.year}  "
        "${dt.hour.toString().padLeft(2, '0')}:"
        "${dt.minute.toString().padLeft(2, '0')}";
  }
}