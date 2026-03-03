import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/alert.dart';

class SimulationService {
  final Random _random = Random();
  Timer? _timer;
  Timer? _safetyAlertTimer;
  final _controller = StreamController<QuerySnapshot>.broadcast();

  // Simulated Bin Data
  final List<Map<String, dynamic>> _dummyBins = [
    {
      'id': 'DIN_HALL_01',
      'name': 'Dining Hall Main',
      'location': 'Cafeteria',
      'status': 'online',
      'fillLevel': 45,
    },
    {
      'id': 'LIB_L1_02',
      'name': 'Library L1',
      'location': 'Study Area',
      'status': 'online',
      'fillLevel': 78,
    },
    {
      'id': 'DORM_A_03',
      'name': 'Dorm Block A',
      'location': 'Entrance',
      'status': 'maintenance',
      'fillLevel': 12,
    },
    {
      'id': 'PARK_N_04',
      'name': 'North Park',
      'location': 'Outdoor',
      'status': 'offline',
      'fillLevel': 0,
    },
    {
      'id': 'LAB_SCI_05',
      'name': 'Science Lab',
      'location': 'Corridor',
      'status': 'online',
      'fillLevel': 92,
    },
  ];

  // Simulated safety alerts (managed in-memory for demo mode)
  final List<AlertModel> _simulatedSafetyAlerts = [];
  int _nextAlertId = 1;

  void startSimulation() {
    _timer?.cancel();
    _safetyAlertTimer?.cancel();
    _emitUpdate();

    // Update fill levels every 3 seconds
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _updateRandomBin();
      _emitUpdate();
    });

    // Randomly trigger a new safety alert every 30–60 seconds
    _scheduleSafetyAlertSimulation();
  }

  void _scheduleSafetyAlertSimulation() {
    final delaySeconds = 30 + _random.nextInt(31); // 30–60s
    _safetyAlertTimer = Timer(Duration(seconds: delaySeconds), () {
      if (!_controller.isClosed) {
        _triggerRandomSafetyAlert();
        _scheduleSafetyAlertSimulation(); // reschedule
      }
    });
  }

  void _triggerRandomSafetyAlert() {
    final subBins = ['plastic', 'paper', 'organic', 'cans', 'mixed'];
    const gasTypes = ['methane', 'ammonia', 'hydrogen_sulfide', 'voc', 'co2'];

    // Pick an online bin
    final onlineBins = _dummyBins
        .where((b) => b['status'] == 'online')
        .toList();
    if (onlineBins.isEmpty) return;

    final bin = onlineBins[_random.nextInt(onlineBins.length)];
    final binId = bin['id'] as String;
    final alertIndex = _random.nextInt(3); // 0=battery, 1=gas, 2=moisture

    AlertModel alert;

    switch (alertIndex) {
      case 0: // BATTERY_DETECTED
        final subBin = subBins[_random.nextInt(subBins.length)];
        alert = AlertModel(
          id: 'sim_${_nextAlertId++}',
          alertType: 'BATTERY_DETECTED',
          message: 'Battery detected in $subBin bin — remove immediately',
          severity: 'error',
          subBin: subBin,
          createdAt: DateTime.now(),
          isResolved: false,
        );
        break;
      case 1: // HARMFUL_GAS
        final gasType = gasTypes[_random.nextInt(gasTypes.length)];
        final gasLevel = 500 + _random.nextInt(1001); // 500–1500 PPM
        final severity = gasLevel >= 1000 ? 'error' : 'warning';
        alert = AlertModel(
          id: 'sim_${_nextAlertId++}',
          alertType: 'HARMFUL_GAS',
          message:
              'Harmful gas ($gasType) detected: $gasLevel PPM — investigate immediately',
          severity: severity,
          subBin: null,
          createdAt: DateTime.now(),
          isResolved: false,
          gasType: gasType,
          gasLevel: gasLevel,
        );
        break;
      default: // MOISTURE_DETECTED
        final subBin = subBins[_random.nextInt(subBins.length)];
        final moistureLevel = 70 + _random.nextInt(26); // 70–95
        final severity = moistureLevel >= 90 ? 'error' : 'warning';
        alert = AlertModel(
          id: 'sim_${_nextAlertId++}',
          alertType: 'MOISTURE_DETECTED',
          message:
              'High moisture in $subBin bin: $moistureLevel% — check for liquid spillage',
          severity: severity,
          subBin: subBin,
          createdAt: DateTime.now(),
          isResolved: false,
          moistureLevel: moistureLevel,
        );
        break;
    }

    _simulatedSafetyAlerts.add(alert);
  }

  /// Expose simulated safety alerts stream for demo mode
  Stream<List<AlertModel>> getSafetyAlertsStream(String binId) {
    return Stream.periodic(const Duration(seconds: 3), (_) {
      return _simulatedSafetyAlerts.where((a) => !a.isResolved).toList();
    });
  }

  /// Manually resolve a simulated safety alert (demo mode)
  void resolveSafetyAlert(String alertId) {
    final index = _simulatedSafetyAlerts.indexWhere((a) => a.id == alertId);
    if (index != -1) {
      final old = _simulatedSafetyAlerts[index];
      _simulatedSafetyAlerts[index] = AlertModel(
        id: old.id,
        alertType: old.alertType,
        message: old.message,
        severity: old.severity,
        subBin: old.subBin,
        createdAt: old.createdAt,
        isResolved: true,
        resolvedAt: DateTime.now(),
        gasType: old.gasType,
        gasLevel: old.gasLevel,
        moistureLevel: old.moistureLevel,
      );
    }
  }

  void stopSimulation() {
    _timer?.cancel();
    _safetyAlertTimer?.cancel();
  }

  void _updateRandomBin() {
    final index = _random.nextInt(_dummyBins.length);
    final bin = _dummyBins[index];

    if (bin['status'] != 'online') return;

    int currentFill = bin['fillLevel'];
    int change = _random.nextInt(10) - 3; // -3 to +6 (mostly filling)

    int newFill = (currentFill + change).clamp(0, 100);

    // Random "emptying" event
    if (newFill > 95 && _random.nextBool()) {
      newFill = 0;
    }

    _dummyBins[index]['fillLevel'] = newFill;
  }

  void _emitUpdate() {
    final docs = _dummyBins.map((data) {
      return _SimulatedDocumentSnapshot(data['id'], data);
    }).toList();

    _controller.add(_SimulatedQuerySnapshot(docs));
  }

  Stream<QuerySnapshot> get binsStream => _controller.stream;
}

// Mock Classes to satisfy Firestore Stream types
class _SimulatedQuerySnapshot implements QuerySnapshot {
  @override
  final List<QueryDocumentSnapshot> docs;

  _SimulatedQuerySnapshot(this.docs);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _SimulatedDocumentSnapshot implements QueryDocumentSnapshot {
  @override
  final String id;
  final Map<String, dynamic> _data;

  _SimulatedDocumentSnapshot(this.id, this._data);

  @override
  Map<String, dynamic> data() => _data;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  dynamic get(Object field) => _data[field.toString()];

  @override
  operator [](Object field) => _data[field.toString()];
}
