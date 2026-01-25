import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bin_sub.dart';
import '../models/alert.dart';
import '../models/time_filter.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ================= SUB BINS =================

  Stream<List<BinSub>> getSubBins(String binId) {
    return _db
        .collection('bins')
        .doc(binId)
        .collection('subBins')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BinSub.fromFirestore(doc.id, doc.data()))
            .toList());
  }

  // ================= ALERTS =================
  // ✅ CORRECT PATH: bins/{binId}/alerts
  // ✅ SORTED: latest first
  Stream<List<AlertModel>> getActiveAlerts(String binId) {
    return _db
        .collection('bins')
        .doc(binId)
        .collection('alerts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          print('ALERT DOCS COUNT: ${snapshot.docs.length}');
          return snapshot.docs
              .map((doc) =>
                  AlertModel.fromFirestore(doc.id, doc.data()))
              .toList();
        });
  }

  // ================= ANALYTICS =================

  Stream<Map<String, int>> getFullCountsPerSubBin(String binId) {
    const List<String> allSubBins = [
      'plastic',
      'glass',
      'organic',
      'cans',
      'mixed',
    ];

    return _db
        .collection('bins')
        .doc(binId)
        .collection('events')
        .where('eventType', isEqualTo: 'BIN_FULL')
        .snapshots()
        .map((snapshot) {
      final Map<String, int> counts = {
        for (var subBin in allSubBins) subBin: 0,
      };

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final subBin = data['subBin'];

        if (subBin != null && counts.containsKey(subBin)) {
          counts[subBin] = counts[subBin]! + 1;
        }
      }

      return counts;
    });
  }

  Stream<Map<String, int>> getFullCountsByTimeFilter(
    String binId,
    TimeFilter filter,
  ) {
    const List<String> allSubBins = [
      'plastic',
      'glass',
      'organic',
      'cans',
      'mixed',
    ];

    DateTime now = DateTime.now();
    DateTime startTime;

    switch (filter) {
      case TimeFilter.day:
        startTime = DateTime(now.year, now.month, now.day);
        break;
      case TimeFilter.week:
        startTime = now.subtract(const Duration(days: 7));
        break;
      case TimeFilter.month:
        startTime = DateTime(now.year, now.month, 1);
        break;
    }

    return _db
        .collection('bins')
        .doc(binId)
        .collection('events')
        .where('eventType', isEqualTo: 'BIN_FULL')
        .snapshots()
        .map((snapshot) {
      final Map<String, int> counts = {
        for (var subBin in allSubBins) subBin: 0,
      };

      for (final doc in snapshot.docs) {
        final data = doc.data();

        if (!data.containsKey('timestamp') ||
            data['timestamp'] is! Timestamp ||
            !data.containsKey('subBin')) {
          continue;
        }

        final DateTime eventTime =
            (data['timestamp'] as Timestamp).toDate();

        if (eventTime.isBefore(startTime)) continue;

        final String subBin = data['subBin'];

        if (counts.containsKey(subBin)) {
          counts[subBin] = counts[subBin]! + 1;
        }
      }

      return counts;
    });
  }
}
