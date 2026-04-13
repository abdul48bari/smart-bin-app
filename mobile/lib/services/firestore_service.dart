import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bin_sub.dart';
import '../models/alert.dart';
import '../models/time_filter.dart';
import 'dart:async';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Demo mode flag — set by AppStateProvider when demo mode is toggled
  static bool isDemoMode = false;

  // Demo piece count data per time filter
  static const Map<String, Map<String, int>> _demoPieceCounts = {
    'day':   {'plastic': 23, 'paper': 18, 'organic': 34, 'cans': 12, 'mixed': 9},
    'week':  {'plastic': 145, 'paper': 112, 'organic': 203, 'cans': 78, 'mixed': 56},
    'month': {'plastic': 589, 'paper': 443, 'organic': 821, 'cans': 312, 'mixed': 198},
  };

  // Demo sub-bin fill level data (mirrors voice_assistant_service_web.dart)
  static const Map<String, Map<String, int>> _demoSubBinFills = {
    'DIN_HALL_01': {'plastic': 45, 'paper': 30, 'organic': 80, 'cans': 60, 'mixed': 70},
    'LIB_L1_02':   {'plastic': 50, 'paper': 65, 'organic': 20, 'cans': 35, 'mixed': 40},
    'DORM_A_03':   {'plastic': 85, 'paper': 70, 'organic': 60, 'cans': 90, 'mixed': 75},
    'PARK_N_04':   {'plastic': 20, 'paper': 15, 'organic': 40, 'cans': 45, 'mixed': 30},
    'LAB_SCI_05':  {'plastic': 90, 'paper': 85, 'organic': 95, 'cans': 80, 'mixed': 88},
    'CAFE_B_06':   {'plastic': 60, 'paper': 45, 'organic': 70, 'cans': 55, 'mixed': 40},
    'GYM_FL_07':   {'plastic': 15, 'paper': 10, 'organic': 25, 'cans': 30, 'mixed': 20},
  };

  static const List<Map<String, String>> _demoBinMeta = [
    {'id': 'DIN_HALL_01', 'name': 'Dining Hall Main', 'location': 'Cafeteria'},
    {'id': 'LIB_L1_02',   'name': 'Library L1',       'location': 'Study Area'},
    {'id': 'DORM_A_03',   'name': 'Dorm Block A',      'location': 'Entrance'},
    {'id': 'PARK_N_04',   'name': 'North Park',         'location': 'Outdoor'},
    {'id': 'LAB_SCI_05',  'name': 'Science Lab',        'location': 'Corridor'},
    {'id': 'CAFE_B_06',   'name': 'Cafeteria Block B',  'location': 'Food Court'},
    {'id': 'GYM_FL_07',   'name': 'Gym Floor',          'location': 'Sports Wing'},
  ];

  // Demo full-count data per time filter (for analytics charts)
  static const Map<String, Map<String, int>> _demoFullCounts = {
    'day':   {'plastic': 3, 'paper': 2, 'organic': 5, 'cans': 1, 'mixed': 2},
    'week':  {'plastic': 18, 'paper': 14, 'organic': 27, 'cans': 9, 'mixed': 11},
    'month': {'plastic': 72, 'paper': 55, 'organic': 103, 'cans': 38, 'mixed': 44},
  };

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

  // Get UNRESOLVED SAFETY ALERTS across all bins (for home page banner)
  Stream<int> getActiveSafetyAlertsCount() {
    // We query all bins and aggregate unresolved safety alerts
    return _db.collection('bins').snapshots().asyncMap((binsSnap) async {
      int count = 0;
      for (final binDoc in binsSnap.docs) {
        final alertsSnap = await _db
            .collection('bins')
            .doc(binDoc.id)
            .collection('alerts')
            .where('isResolved', isEqualTo: false)
            .where('alertType', whereIn: [
              'BATTERY_DETECTED',
              'HARMFUL_GAS',
              'MOISTURE_DETECTED',
            ])
            .get();
        count += alertsSnap.docs.length;
      }
      return count;
    });
  }

  // Get active safety alerts for a specific bin (for bins page badges)
  Stream<List<AlertModel>> getActiveSafetyAlerts(String binId) {
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
              .where((alert) => alert.isSafetyAlert)
              .toList();
        });
  }

  // ================= MANUAL ALERT RESOLUTION =================

  /// Manually resolve a safety alert (writes directly to Firestore)
  /// Used for BATTERY_DETECTED, HARMFUL_GAS, MOISTURE_DETECTED, HARDWARE_ERROR
  Future<void> resolveAlert(String binId, String alertId) async {
    await _db
        .collection('bins')
        .doc(binId)
        .collection('alerts')
        .doc(alertId)
        .update({
      'resolved': true,
      'isResolved': true,
      'resolvedAt': Timestamp.now(),
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
    if (isDemoMode) {
      final key = filter == TimeFilter.day ? 'day' : filter == TimeFilter.week ? 'week' : 'month';
      return (() async* {
        yield Map<String, int>.from(_demoFullCounts[key]!);
        yield* Stream.periodic(const Duration(seconds: 5), (_) => Map<String, int>.from(_demoFullCounts[key]!));
      })();
    }

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
  if (isDemoMode) {
    final key = filter == TimeFilter.day ? 'day' : filter == TimeFilter.week ? 'week' : 'month';
    return (() async* {
      yield Map<String, int>.from(_demoPieceCounts[key]!);
      yield* Stream.periodic(const Duration(seconds: 5), (_) => Map<String, int>.from(_demoPieceCounts[key]!));
    })();
  }

  const List<String> allSubBins = ['plastic', 'paper', 'organic', 'cans', 'mixed'];

  if (_currentFilter != filter || _pieceCountController == null) {
    _currentFilter = filter;
    _refreshTimer?.cancel();
    _pieceCountController?.close();
    _pieceCountController = StreamController<Map<String, int>>.broadcast();

    _fetchPieceData(filter, allSubBins);

    _refreshTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _fetchPieceData(filter, allSubBins);
    });
  }

  return _pieceCountController!.stream;
}

Future<void> _fetchPieceData(TimeFilter filter, List<String> allSubBins) async {
  // Bail out if demo mode is active — avoids Firestore calls with no auth
  if (isDemoMode) return;

  final Map<String, int> totalCounts = {
    for (var subBin in allSubBins) subBin: 0,
  };

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
    final binsSnapshot = await _db.collection('bins').get();

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

  // ================= BIN MANAGEMENT =================

  /// Add a new bin with all 5 sub-bins initialised at 0%.
  /// Throws 'BIN_EXISTS' if a bin with that ID already exists.
  Future<void> addBin({
    required String binId,
    required String name,
    required String location,
    required String status,
  }) async {
    final existing = await _db.collection('bins').doc(binId).get();
    if (existing.exists) throw Exception('BIN_EXISTS');

    await _db.collection('bins').doc(binId).set({
      'name': name,
      'location': location,
      'status': status,
      'fillLevel': 0,
    });

    const subBins = ['plastic', 'paper', 'organic', 'cans', 'mixed'];
    final batch = _db.batch();
    for (final subBin in subBins) {
      final ref = _db
          .collection('bins')
          .doc(binId)
          .collection('subBins')
          .doc(subBin);
      batch.set(ref, {'currentFillPercent': 0, 'isFull': false});
    }
    await batch.commit();
  }

  /// Remove a bin and its sub-bins from Firestore
  Future<void> removeBin(String binId) async {
    const subBins = ['plastic', 'paper', 'organic', 'cans', 'mixed'];
    final batch = _db.batch();
    for (final subBin in subBins) {
      batch.delete(_db
          .collection('bins')
          .doc(binId)
          .collection('subBins')
          .doc(subBin));
    }
    batch.delete(_db.collection('bins').doc(binId));
    await batch.commit();
  }

  /// One-time fetch of all bin metadata, sorted by name (natural order).
  Future<List<Map<String, String>>> getBinsList() async {
    final snap = await _db.collection('bins').get();
    final list = snap.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'name': (data['name'] as String?) ?? doc.id,
        'location': (data['location'] as String?) ?? '',
        'status': (data['status'] as String?) ?? 'offline',
      };
    }).toList();
    list.sort((a, b) => _naturalCompare(a['name']!, b['name']!));
    return list;
  }

  /// Update editable fields on an existing bin (name, location, status).
  Future<void> updateBinDetails({
    required String binId,
    required String name,
    required String location,
    required String status,
  }) async {
    await _db.collection('bins').doc(binId).update({
      'name': name,
      'location': location,
      'status': status,
    });
  }

  // Natural sort comparator — handles "bin-001" < "bin-005" < "bin-010"
  static int _naturalCompare(String a, String b) {
    final re = RegExp(r'(\d+)|(\D+)');
    final aChunks = re.allMatches(a.toLowerCase()).map((m) => m.group(0)!).toList();
    final bChunks = re.allMatches(b.toLowerCase()).map((m) => m.group(0)!).toList();
    for (int i = 0; i < aChunks.length && i < bChunks.length; i++) {
      final aNum = int.tryParse(aChunks[i]);
      final bNum = int.tryParse(bChunks[i]);
      final cmp = (aNum != null && bNum != null)
          ? aNum.compareTo(bNum)
          : aChunks[i].compareTo(bChunks[i]);
      if (cmp != 0) return cmp;
    }
    return aChunks.length.compareTo(bChunks.length);
  }

  // ================= BIN STATUS UPDATE =================

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

  // ================= PER-BIN PIECE COUNT (for Analytics per-bin section) =================

  /// Returns piece counts for a single bin. Null means no data available yet.
  Stream<Map<String, int>?> getPerBinPieceCount(String binId, TimeFilter filter) {
    if (isDemoMode) {
      // Only the primary demo bin (DIN_HALL_01) has piece count data
      if (binId == 'DIN_HALL_01') {
        final key = filter == TimeFilter.day ? 'day' : filter == TimeFilter.week ? 'week' : 'month';
        return (() async* {
          yield Map<String, int>.from(_demoPieceCounts[key]!);
          yield* Stream.periodic(
            const Duration(seconds: 5),
            (_) => Map<String, int>.from(_demoPieceCounts[key]!),
          );
        })();
      }
      return Stream.value(null);
    }

    // Real mode: query this bin's events, return null if no pieces recorded yet
    return getPieceCountsByTimeFilter(binId, filter).map((data) {
      final total = data.values.fold(0, (a, b) => a + b);
      return total == 0 ? null : data;
    });
  }

  // ================= ALL BINS SUB-BIN FILLS (for Suggestions page) =================

  /// Returns all bins with sub-bin fill levels for the Suggestions page.
  Stream<List<Map<String, dynamic>>> getAllBinsSubBinFills() {
    if (isDemoMode) {
      final List<Map<String, dynamic>> result = _demoBinMeta.map((meta) {
        return {
          'binId': meta['id']!,
          'name': meta['name']!,
          'location': meta['location']!,
          'fills': Map<String, int>.from(_demoSubBinFills[meta['id']]!),
        };
      }).toList();
      return (() async* {
        yield result;
        yield* Stream.periodic(const Duration(seconds: 5), (_) => result);
      })();
    }

    return _db.collection('bins').snapshots().asyncMap((binsSnap) async {
      final List<Map<String, dynamic>> result = [];
      for (final binDoc in binsSnap.docs) {
        final data = binDoc.data();
        final subBinsSnap = await _db
            .collection('bins')
            .doc(binDoc.id)
            .collection('subBins')
            .get();
        final Map<String, int> fills = {};
        for (final sub in subBinsSnap.docs) {
          fills[sub.id] =
              ((sub.data()['currentFillPercent'] as num?) ?? 0).toInt();
        }
        result.add({
          'binId': binDoc.id,
          'name': (data['name'] as String?) ?? binDoc.id,
          'location': (data['location'] as String?) ?? '',
          'fills': fills,
        });
      }
      return result;
    });
  }

void dispose() {
  _refreshTimer?.cancel();
  _pieceCountController?.close();
}
}
