import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/simulation_service.dart';
import '../services/firestore_service.dart';

class AppStateProvider extends ChangeNotifier {
  bool _isDemoMode = false;
  bool _isDemoEntry = false; // true when user entered via "Try Demo" (no auth)
  final SimulationService _simulationService = SimulationService();

  bool get isDemoMode => _isDemoMode;
  bool get isDemoEntry => _isDemoEntry;

  void toggleDemoMode(bool value) {
    _isDemoMode = value;
    FirestoreService.isDemoMode = value;
    if (_isDemoMode) {
      _simulationService.startSimulation();
    } else {
      _simulationService.stopSimulation();
    }
    notifyListeners();
  }

  /// Called from the login page "Try Demo" button — no Firebase auth needed
  void enterDemoMode() {
    _isDemoMode = true;
    _isDemoEntry = true;
    FirestoreService.isDemoMode = true;
    _simulationService.startSimulation();
    notifyListeners();
  }

  /// Called on logout when in demo entry mode — goes back to login
  void exitDemoMode() {
    _isDemoMode = false;
    _isDemoEntry = false;
    FirestoreService.isDemoMode = false;
    _simulationService.stopSimulation();
    notifyListeners();
  }

  // Unified Stream: Returns either Real Firestore stream or Simulated stream
  Stream<QuerySnapshot> get binsStream {
    if (_isDemoMode) {
      return _simulationService.binsStream;
    } else {
      return FirebaseFirestore.instance.collection('bins').snapshots();
    }
  }

  // Per-bin status stream — demo-aware
  Stream<String> binStatusStream(String binId) {
    if (_isDemoMode) {
      return _simulationService.getBinStatusStream(binId);
    } else {
      return FirebaseFirestore.instance
          .collection('bins')
          .doc(binId)
          .snapshots()
          .map((doc) => (doc.data()?['status'] as String?) ?? 'offline');
    }
  }
}
