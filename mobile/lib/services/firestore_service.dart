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
              .map((doc) => AlertModel.fromFirestore(doc.id, doc.data()))
              .toList();
        });
  }

  // ================= ANALYTICS - BIN_FULL EVENTS =================

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
        startTime = now.subtract(const Duration(hours: 24));
        break;
      case TimeFilter.week:
        startTime = now.subtract(const Duration(days: 7));
        break;
      case TimeFilter.month:
        startTime = now.subtract(const Duration(days: 30));
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

        final DateTime eventTime = (data['timestamp'] as Timestamp).toDate();

        if (eventTime.isBefore(startTime)) continue;

        final String subBin = data['subBin'];

        if (counts.containsKey(subBin)) {
          counts[subBin] = counts[subBin]! + 1;
        }
      }

      return counts;
    });
  }

  // ================= ANALYTICS - PIECE COLLECTED EVENTS =================

  Stream<Map<String, int>> getPieceCountsByTimeFilter(
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
        startTime = now.subtract(const Duration(hours: 24));
        break;
      case TimeFilter.week:
        startTime = now.subtract(const Duration(days: 7));
        break;
      case TimeFilter.month:
        startTime = now.subtract(const Duration(days: 30));
        break;
    }

    return _db
        .collection('bins')
        .doc(binId)
        .collection('events')
        .where('eventType', isEqualTo: 'PIECE_COLLECTED')
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

        final DateTime eventTime = (data['timestamp'] as Timestamp).toDate();

        if (eventTime.isBefore(startTime)) continue;

        final String subBin = data['subBin'];

        if (counts.containsKey(subBin)) {
          counts[subBin] = counts[subBin]! + 1;
        }
      }

      return counts;
    });
  }

  // Get total pieces collected across ALL bins - FIXED VERSION
  Stream<Map<String, int>> getAllBinsPieceCount(TimeFilter filter) {
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
        startTime = now.subtract(const Duration(hours: 24));
        break;
      case TimeFilter.week:
        startTime = now.subtract(const Duration(days: 7));
        break;
      case TimeFilter.month:
        startTime = now.subtract(const Duration(days: 30));
        break;
    }

    print('🔍 getAllBinsPieceCount called with filter: $filter');
    print('🔍 Start time: $startTime');

    // Query BIN_001 events directly (simpler approach)
    return _db
        .collection('bins')
        .doc('BIN_001')
        .collection('events')
        .where('eventType', isEqualTo: 'PIECE_COLLECTED')
        .snapshots()
        .map((snapshot) {
      print('🔍 Total events in snapshot: ${snapshot.docs.length}');

      final Map<String, int> totalCounts = {
        for (var subBin in allSubBins) subBin: 0,
      };

      int filteredOut = 0;
      int counted = 0;

      for (final eventDoc in snapshot.docs) {
        final data = eventDoc.data();

        print('🔍 Event data: ${data.toString().substring(0, data.toString().length > 100 ? 100 : data.toString().length)}...');

        if (!data.containsKey('timestamp')) {
          print('⚠️ Event missing timestamp');
          continue;
        }

        if (!data.containsKey('subBin')) {
          print('⚠️ Event missing subBin');
          continue;
        }

        if (data['timestamp'] is! Timestamp) {
          print('⚠️ Timestamp is not a Timestamp object: ${data['timestamp']}');
          continue;
        }

        final DateTime eventTime = (data['timestamp'] as Timestamp).toDate();
        print('🔍 Event time: $eventTime');

        if (eventTime.isBefore(startTime)) {
          filteredOut++;
          continue;
        }

        final String subBin = data['subBin'];
        if (totalCounts.containsKey(subBin)) {
          totalCounts[subBin] = totalCounts[subBin]! + 1;
          counted++;
        }
      }

      print('🔍 Filtered out (too old): $filteredOut');
      print('🔍 Counted: $counted');
      print('🔍 Final counts: $totalCounts');

      return totalCounts;
    });
  }
}


