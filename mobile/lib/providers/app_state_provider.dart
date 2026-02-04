import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/simulation_service.dart';

class AppStateProvider extends ChangeNotifier {
  bool _isDemoMode = false;
  final SimulationService _simulationService = SimulationService();

  bool get isDemoMode => _isDemoMode;

  void toggleDemoMode(bool value) {
    _isDemoMode = value;
    if (_isDemoMode) {
      _simulationService.startSimulation();
    } else {
      _simulationService.stopSimulation();
    }
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
}
