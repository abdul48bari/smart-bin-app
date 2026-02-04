import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class SimulationService {
  final Random _random = Random();
  Timer? _timer;
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
      'fillLevel': 0, // offline
    },
    {
      'id': 'LAB_SCI_05',
      'name': 'Science Lab',
      'location': 'Corridor',
      'status': 'online',
      'fillLevel': 92, // Critical
    },
  ];

  void startSimulation() {
    _timer?.cancel();
    _emitUpdate(); // Initial emit

    // Update every 3 seconds for dynamic feel
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _updateRandomBin();
      _emitUpdate();
    });
  }

  void stopSimulation() {
    _timer?.cancel();
  }

  void _updateRandomBin() {
    final index = _random.nextInt(_dummyBins.length);
    final bin = _dummyBins[index];

    if (bin['status'] != 'online') return;

    // Simulate filling up or emptying
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
    // Convert List<Map> to simulated QuerySnapshot
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
