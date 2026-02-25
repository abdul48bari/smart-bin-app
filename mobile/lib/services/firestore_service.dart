import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bin_sub.dart';
import '../models/alert.dart';
import '../models/time_filter.dart';
import 'dart:async';

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

  // Get ALL alerts (for bins page - shows history)
  Stream<List<AlertModel>> getActiveAlerts(String binId) {
    return _db
        .collection('bins')
        .doc(binId)
        .collection('alerts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => AlertModel.fromFirestore(doc.id, doc.data()))
              .toList();
        });
  }

  // Get ONLY UNRESOLVED alerts (for home page)
  Stream<List<AlertModel>> getUnresolvedAlerts(String binId) {
    return _db
        .collection('bins')
        .doc(binId)
        .collection('alerts')
        .where('isResolved', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => AlertModel.fromFirestore(doc.id, doc.data()))
              .toList();
        });
  }

  // ================= ANALYTICS - BIN_FULL EVENTS =================

  Stream<Map<String, int>> getFullCountsPerSubBin(String binId) {
    const List<String> allSubBins = [
      'plastic',
      'paper',
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
      'paper',
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
      'paper',
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

// INSTANT FILTER CHANGES + Real-time updates every 2 seconds

StreamController<Map<String, int>>? _pieceCountController;
TimeFilter? _currentFilter;
Timer? _refreshTimer;

Stream<Map<String, int>> getAllBinsPieceCount(TimeFilter filter) {
  const List<String> allSubBins = ['plastic', 'paper', 'organic', 'cans', 'mixed'];

  // If filter changed or first call, reset everything
  if (_currentFilter != filter || _pieceCountController == null) {
    _currentFilter = filter;
    _refreshTimer?.cancel();
    _pieceCountController?.close();
    _pieceCountController = StreamController<Map<String, int>>.broadcast();

    // Fetch data immediately on filter change
    _fetchPieceData(filter, allSubBins);

    // Then refresh every 2 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _fetchPieceData(filter, allSubBins);
    });
  }

  return _pieceCountController!.stream;
}

Future<void> _fetchPieceData(TimeFilter filter, List<String> allSubBins) async {
  final Map<String, int> totalCounts = {
    for (var subBin in allSubBins) subBin: 0,
  };

  // Recalculate time filter
  final DateTime now = DateTime.now();
  final DateTime startTime;

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

  try {
    // Get all bins
    final binsSnapshot = await _db.collection('bins').get();

    // Query each bin's events
    for (var binDoc in binsSnapshot.docs) {
      final binId = binDoc.id;
      
      final eventsSnapshot = await _db
          .collection('bins')
          .doc(binId)
          .collection('events')
          .where('eventType', isEqualTo: 'PIECE_COLLECTED')
          .get();

      for (var eventDoc in eventsSnapshot.docs) {
        final data = eventDoc.data();
        
        if (!data.containsKey('timestamp') ||
            data['timestamp'] is! Timestamp ||
            !data.containsKey('subBin')) continue;

        final DateTime eventTime = (data['timestamp'] as Timestamp).toDate();
        if (eventTime.isBefore(startTime)) continue;

        final String subBin = data['subBin'];
        if (totalCounts.containsKey(subBin)) {
          totalCounts[subBin] = totalCounts[subBin]! + 1;
        }
      }
    }

    // Emit the data
    if (_pieceCountController != null && !_pieceCountController!.isClosed) {
      _pieceCountController!.add(totalCounts);
    }
  } catch (e) {
    print('Error fetching piece data: $e');
  }
}

Stream<List<AlertModel>> getRecentActiveAlerts(String binId) {
  final DateTime yesterday = DateTime.now().subtract(const Duration(hours: 24));
  
  return _db
      .collection('bins')
      .doc(binId)
      .collection('alerts')
      .where('createdAt', isGreaterThan: Timestamp.fromDate(yesterday))
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs
            .map((doc) => AlertModel.fromFirestore(doc.id, doc.data()))
            .where((alert) => !alert.isResolved)
            .toList();
      });
}

  // ================= BIN STATUS UPDATE =================
  
  // REPLACE the updateBinStatus function in firestore_service.dart with this:

/// Update bin status (online, offline, maintenance)
Future<void> updateBinStatus(String binId, String newStatus) async {
  try {
    print('🔄 Updating $binId to $newStatus...');
    
    await _db.collection('bins').doc(binId).update({
      'status': newStatus,
    });
    
    print('✅ Status updated successfully!');
  } catch (e) {
    print('❌ Error updating status: $e');
    throw Exception('Failed to update bin status: $e');
  }
}

// Add this method to clean up when service is disposed (optional but good practice)
void dispose() {
  _refreshTimer?.cancel();
  _pieceCountController?.close();
}
}