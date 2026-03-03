import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore_service.dart';
import '../models/time_filter.dart';

class VoiceAssistantService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  final FirestoreService _firestoreService = FirestoreService();

  bool _isInitialized = false;
  bool _isListening = false;

  String _lastRecognizedText = '';
  String _lastResponse = '';

  bool get isListening => _isListening;
  String get lastRecognizedText => _lastRecognizedText;
  String get lastResponse => _lastResponse;

  // Initialize speech services
  Future<Map<String, dynamic>> initialize() async {
    if (_isInitialized) return {'success': true, 'message': 'Already initialized'};

    try {
      // On mobile, handle permissions
      if (!kIsWeb) {
        // Check current permission status
        var status = await Permission.microphone.status;
        print('📱 Current microphone permission status: $status');

        // If denied permanently, tell user to go to settings
        if (status.isPermanentlyDenied) {
          return {
            'success': false,
            'message': 'Microphone permission permanently denied. Please enable it in Settings.',
            'openSettings': true,
          };
        }

        // Request microphone permission if not granted
        if (!status.isGranted) {
          print('🎤 Requesting microphone permission...');
          status = await Permission.microphone.request();
          print('📱 Permission request result: $status');
        }

        if (!status.isGranted) {
          return {
            'success': false,
            'message': 'Microphone permission is required for voice commands.',
            'openSettings': false,
          };
        }

        print('✅ Microphone permission granted');
      } else {
        print('🌐 Running on web - browser will request microphone permission');
      }

      // Initialize speech to text
      print('🎙️ Initializing speech recognition...');
      _isInitialized = await _speech.initialize(
        onError: (error) => print('❌ Speech error: $error'),
        onStatus: (status) => print('📊 Speech status: $status'),
      );

      if (!_isInitialized) {
        return {
          'success': false,
          'message': 'Failed to initialize speech recognition. Please try again.',
          'openSettings': false,
        };
      }

      print('✅ Speech recognition initialized');

      // Initialize TTS
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);

      print('✅ Voice assistant fully initialized');

      return {'success': true, 'message': 'Voice assistant ready'};
    } catch (e) {
      print('❌ Error initializing voice assistant: $e');
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
        'openSettings': false,
      };
    }
  }

  // Start listening
  Future<void> startListening(Function(String, bool) onResult) async {
    if (!_isInitialized) {
      final result = await initialize();
      if (!result['success']) return;
    }

    if (_isListening) return;

    _isListening = true;
    _lastRecognizedText = '';

    await _speech.listen(
      onResult: (result) {
        _lastRecognizedText = result.recognizedWords;
        // Call callback with both interim and final results
        onResult(_lastRecognizedText, result.finalResult);
      },
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
    );
  }

  // Stop listening
  Future<void> stopListening() async {
    if (!_isListening) return;

    _isListening = false;
    await _speech.stop();
  }

  // Speak response
  Future<void> speak(String text) async {
    _lastResponse = text;
    await _tts.speak(text);
  }

  // Stop speaking
  Future<void> stopSpeaking() async {
    await _tts.stop();
  }

  // Process voice command
  Future<String> processCommand(String command) async {
    // First normalize the text to correct common recognition errors
    final normalizedCommand = _normalizeText(command);
    final lowerCommand = normalizedCommand.toLowerCase().trim();

    try {
      // STATUS COMMANDS
      if (_containsAny(lowerCommand, ['status of all bins', 'bin status', 'show status'])) {
        return await _getSystemStatus();
      }

      if (_containsAny(lowerCommand, ['how many bins online', 'bins online', 'online bins'])) {
        return await _getOnlineBinsCount();
      }

      if (_containsAny(lowerCommand, ['how many bins offline', 'bins offline', 'offline bins'])) {
        return await _getOfflineBinsCount();
      }

      if (_containsAny(lowerCommand, ['system health', 'health status'])) {
        return await _getSystemHealth();
      }

      // FILL LEVEL COMMANDS
      if (_containsAny(lowerCommand, ['fill level', 'how full'])) {
        return await _getFillLevel(lowerCommand);
      }

      if (_containsAny(lowerCommand, ['which bin is most full', 'most full', 'fullest bin'])) {
        return await _getMostFullBin();
      }

      if (_containsAny(lowerCommand, ['show me all fill levels', 'all fill levels', 'all levels'])) {
        return await _getAllFillLevels();
      }

      // SAFETY ALERT COMMANDS
      if (_containsAny(lowerCommand, ['safety alert', 'safety warning', 'dangerous'])) {
        return await _getSafetyAlerts(null);
      }

      if (_containsAny(lowerCommand, ['battery alert', 'battery detected', 'battery warning'])) {
        return await _getSafetyAlerts('BATTERY_DETECTED');
      }

      if (_containsAny(lowerCommand, ['gas alert', 'gas detected', 'harmful gas', 'gas warning'])) {
        return await _getSafetyAlerts('HARMFUL_GAS');
      }

      if (_containsAny(lowerCommand, ['moisture alert', 'moisture detected', 'moisture warning', 'water detected'])) {
        return await _getSafetyAlerts('MOISTURE_DETECTED');
      }

      // GENERAL ALERT COMMANDS
      if (_containsAny(lowerCommand, ['active alerts', 'any alerts', 'show alerts'])) {
        return await _getActiveAlerts();
      }

      if (_containsAny(lowerCommand, ['how many alerts', 'alert count'])) {
        return await _getAlertCount();
      }

      // ANALYTICS COMMANDS
      if (_containsAny(lowerCommand, ['collected today', 'items today'])) {
        return await _getItemsCollected(TimeFilter.day);
      }

      if (_containsAny(lowerCommand, ['collected this week', 'items this week', 'weekly collection'])) {
        return await _getItemsCollected(TimeFilter.week);
      }

      if (_containsAny(lowerCommand, ['collected this month', 'items this month', 'monthly collection'])) {
        return await _getItemsCollected(TimeFilter.month);
      }

      if (_containsAny(lowerCommand, ['show statistics', 'statistics', 'stats'])) {
        return await _getStatistics();
      }

      if (_containsAny(lowerCommand, ['most collected', 'most common', 'top waste'])) {
        return await _getMostCollectedType();
      }

      // If no command matched
      return "I didn't understand that command. Try asking about bin status, fill levels, alerts, safety warnings, or statistics.";
    } catch (e) {
      print('Error processing command: $e');
      return "Sorry, I encountered an error processing your request.";
    }
  }

  // Helper to check if command contains any of the keywords
  bool _containsAny(String text, List<String> keywords) {
    return keywords.any((keyword) => text.contains(keyword));
  }

  // Word-form numbers to digits
  static const Map<String, String> _wordNumbers = {
    'one': '1', 'two': '2', 'three': '3', 'four': '4', 'five': '5',
    'six': '6', 'seven': '7', 'eight': '8', 'nine': '9', 'ten': '10',
    'first': '1', 'second': '2', 'third': '3',
  };

  // Extract bin number from command (e.g., "bin 2", "bin two", "#3")
  String _extractBinNumber(String command) {
    // First convert word-form numbers near "bin" to digits
    String processed = command;
    _wordNumbers.forEach((word, digit) {
      processed = processed.replaceAllMapped(
        RegExp('bin\\s+$word\\b', caseSensitive: false),
        (m) => 'bin $digit',
      );
      processed = processed.replaceAllMapped(
        RegExp('bin\\s+number\\s+$word\\b', caseSensitive: false),
        (m) => 'bin number $digit',
      );
    });

    // Look for patterns like "bin 1", "bin number 2", "#3", "bin_001"
    final patterns = [
      RegExp(r'bin\s+number\s+(\d+)', caseSensitive: false),
      RegExp(r'bin\s+#?(\d+)', caseSensitive: false),
      RegExp(r'#(\d+)'),
      RegExp(r'bin_(\d+)', caseSensitive: false),
      RegExp(r'number\s+(\d+)', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(processed);
      if (match != null) {
        final num = match.group(1)!;
        return 'BIN_${num.padLeft(3, '0')}';
      }
    }
    return 'BIN_001'; // Default to BIN_001 when no bin specified
  }

  // Normalize common speech recognition errors
  String _normalizeText(String text) {
    String normalized = text.toLowerCase();

    // Common misrecognitions - map wrong words to correct ones
    final corrections = {
      // Bins/Bin variations
      r'\bbeans?\b': 'bins',
      r'\bben\b': 'bin',
      r'\bpin\b': 'bin',
      r'\bbeen\b': 'bin',
      r'\bbing?\b': 'bin',
      r'\bbins?\b': 'bins',

      // Cans variations
      r'\bchance\b': 'cans',
      r'\bkenz\b': 'cans',
      r'\bkans\b': 'cans',

      // Status variations
      r'\bstadiums?\b': 'status',
      r'\bstattus\b': 'status',

      // Fill level variations
      r'\bphil\b': 'fill',
      r'\bfeel\b': 'fill',
      r'\bfield\b': 'fill',

      // Alert variations
      r'\balarms?\b': 'alert',
      r'\balerts?\b': 'alert',

      // Waste types
      r'\bplastik\b': 'plastic',
      r'\bplastick\b': 'plastic',
      r'\bpapper\b': 'paper',
      r'\borganic\b': 'organic',
      r'\borgenik\b': 'organic',

      // Safety alert terms
      r'\bbatter\b': 'battery',
      r'\bbattery\b': 'battery',
      r'\bgas\b': 'gas',
      r'\bgass\b': 'gas',
      r'\bmoisture\b': 'moisture',
      r'\bmoister\b': 'moisture',
      r'\bsaftey\b': 'safety',
      r'\bsafty\b': 'safety',

      // Numbers (only when clearly not valid English)
      r'\bwon\b': 'one',
      r'\btoo\b': 'two',
      r'\btree\b': 'three',
    };

    // Apply corrections
    corrections.forEach((pattern, replacement) {
      normalized = normalized.replaceAll(RegExp(pattern, caseSensitive: false), replacement);
    });

    print('🔧 Normalized: "$text" → "$normalized"');
    return normalized;
  }

  // ===================== COMMAND IMPLEMENTATIONS =====================

  Future<String> _getSystemStatus() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('bins').get();
      final bins = snapshot.docs;

      if (bins.isEmpty) {
        return "No bins are configured in the system.";
      }

      int online = 0, offline = 0, maintenance = 0;

      for (final bin in bins) {
        final status = bin.data()['status'] ?? 'offline';
        if (status == 'online') online++;
        else if (status == 'maintenance') maintenance++;
        else offline++;
      }

      return "System status: ${bins.length} total bins. $online online, $offline offline, $maintenance in maintenance.";
    } catch (e) {
      return "Unable to fetch bin status.";
    }
  }

  Future<String> _getOnlineBinsCount() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('bins').get();
      final onlineCount = snapshot.docs.where((doc) => doc.data()['status'] == 'online').length;
      return "$onlineCount bins are currently online.";
    } catch (e) {
      return "Unable to fetch online bins count.";
    }
  }

  Future<String> _getOfflineBinsCount() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('bins').get();
      final offlineCount = snapshot.docs.where((doc) => doc.data()['status'] == 'offline').length;
      return "$offlineCount bins are currently offline.";
    } catch (e) {
      return "Unable to fetch offline bins count.";
    }
  }

  Future<String> _getSystemHealth() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('bins').get();
      final bins = snapshot.docs;

      if (bins.isEmpty) return "No bins configured.";

      int online = bins.where((doc) => doc.data()['status'] == 'online').length;
      int offline = bins.where((doc) => doc.data()['status'] == 'offline').length;
      int maintenance = bins.where((doc) => doc.data()['status'] == 'maintenance').length;

      double healthPercent = (online / bins.length * 100).round().toDouble();

      return "System health is ${healthPercent.toInt()}%. $online bins online, $offline offline, $maintenance in maintenance.";
    } catch (e) {
      return "Unable to calculate system health.";
    }
  }

  Future<String> _getFillLevel(String command) async {
    try {
      // Extract bin type from command
      String? binType;
      if (command.contains('plastic')) binType = 'plastic';
      else if (command.contains('paper')) binType = 'paper';
      else if (command.contains('organic')) binType = 'organic';
      else if (command.contains('cans')) binType = 'cans';
      else if (command.contains('mixed')) binType = 'mixed';

      if (binType == null) {
        return "Please specify which bin type: plastic, paper, organic, cans, or mixed.";
      }

      final binNumber = _extractBinNumber(command);

      final subBinDoc = await FirebaseFirestore.instance
          .collection('bins')
          .doc(binNumber)
          .collection('subBins')
          .doc(binType)
          .get();

      if (!subBinDoc.exists) {
        return "No data available for the $binType bin in $binNumber.";
      }

      final fillPercent = subBinDoc.data()?['currentFillPercent'] ?? 0;
      return "The $binType bin in $binNumber is at $fillPercent percent capacity.";
    } catch (e) {
      return "Unable to fetch fill level.";
    }
  }

  Future<String> _getMostFullBin() async {
    try {
      // Check all bins and all sub-bins
      final binsSnapshot = await FirebaseFirestore.instance.collection('bins').get();

      int maxFill = 0;
      String mostFullBinType = 'none';
      String mostFullBinNumber = 'none';

      for (final bin in binsSnapshot.docs) {
        final subBinsSnapshot = await FirebaseFirestore.instance
            .collection('bins')
            .doc(bin.id)
            .collection('subBins')
            .get();

        for (final subBin in subBinsSnapshot.docs) {
          final fillPercent = subBin.data()['currentFillPercent'] ?? 0;
          if (fillPercent > maxFill) {
            maxFill = fillPercent;
            mostFullBinType = subBin.id;
            mostFullBinNumber = bin.id;
          }
        }
      }

      if (maxFill == 0) return "All bins are empty.";

      return "The $mostFullBinType bin in $mostFullBinNumber is the most full at $maxFill percent capacity.";
    } catch (e) {
      return "Unable to determine most full bin.";
    }
  }

  Future<String> _getAllFillLevels() async {
    try {
      final binsSnapshot = await FirebaseFirestore.instance.collection('bins').get();

      if (binsSnapshot.docs.isEmpty) return "No bins configured.";

      final levels = <String>[];

      for (final bin in binsSnapshot.docs) {
        final subBinsSnapshot = await FirebaseFirestore.instance
            .collection('bins')
            .doc(bin.id)
            .collection('subBins')
            .get();

        if (subBinsSnapshot.docs.isNotEmpty) {
          for (final subBin in subBinsSnapshot.docs) {
            final fillPercent = subBin.data()['currentFillPercent'] ?? 0;
            levels.add("${bin.id} ${subBin.id}: $fillPercent percent");
          }
        }
      }

      if (levels.isEmpty) return "No fill level data available.";

      return "Current fill levels: ${levels.join(', ')}.";
    } catch (e) {
      return "Unable to fetch fill levels.";
    }
  }

  Future<String> _getActiveAlerts() async {
    try {
      final binsSnapshot = await FirebaseFirestore.instance.collection('bins').get();

      int totalAlerts = 0;
      final alertsByBin = <String, int>{};

      for (final bin in binsSnapshot.docs) {
        final alertsSnapshot = await FirebaseFirestore.instance
            .collection('bins')
            .doc(bin.id)
            .collection('alerts')
            .where('isResolved', isEqualTo: false)
            .get();

        if (alertsSnapshot.docs.isNotEmpty) {
          alertsByBin[bin.id] = alertsSnapshot.docs.length;
          totalAlerts += alertsSnapshot.docs.length;
        }
      }

      if (totalAlerts == 0) {
        return "There are no active alerts. All systems normal.";
      }

      final binDetails = alertsByBin.entries
          .map((e) => "${e.key}: ${e.value} alerts")
          .join(', ');

      return "There are $totalAlerts active alerts across ${alertsByBin.length} bins. $binDetails.";
    } catch (e) {
      return "Unable to fetch alerts.";
    }
  }

  Future<String> _getAlertCount() async {
    try {
      final binsSnapshot = await FirebaseFirestore.instance.collection('bins').get();

      int totalCount = 0;

      for (final bin in binsSnapshot.docs) {
        final alertsSnapshot = await FirebaseFirestore.instance
            .collection('bins')
            .doc(bin.id)
            .collection('alerts')
            .where('isResolved', isEqualTo: false)
            .get();

        totalCount += alertsSnapshot.docs.length;
      }

      if (totalCount == 0) return "There are no active alerts.";
      else if (totalCount == 1) return "There is 1 active alert.";
      else return "There are $totalCount active alerts across all bins.";
    } catch (e) {
      return "Unable to count alerts.";
    }
  }

  Future<String> _getSafetyAlerts(String? alertType) async {
    try {
      final binsSnapshot = await FirebaseFirestore.instance.collection('bins').get();

      final safetyTypes = {'BATTERY_DETECTED', 'HARMFUL_GAS', 'MOISTURE_DETECTED'};
      final targetType = alertType;

      int totalCount = 0;
      final details = <String>[];

      for (final bin in binsSnapshot.docs) {
        final alertsSnapshot = await FirebaseFirestore.instance
            .collection('bins')
            .doc(bin.id)
            .collection('alerts')
            .where('isResolved', isEqualTo: false)
            .get();

        for (final alert in alertsSnapshot.docs) {
          final data = alert.data();
          final type = data['alertType'] as String? ?? '';
          if (targetType != null ? type == targetType : safetyTypes.contains(type)) {
            final label = type == 'BATTERY_DETECTED' ? 'battery'
                : type == 'HARMFUL_GAS' ? 'harmful gas'
                : 'moisture';
            details.add("${bin.id}: $label");
            totalCount++;
          }
        }
      }

      if (totalCount == 0) {
        if (targetType == 'BATTERY_DETECTED') return "No active battery alerts.";
        if (targetType == 'HARMFUL_GAS') return "No active harmful gas alerts.";
        if (targetType == 'MOISTURE_DETECTED') return "No active moisture alerts.";
        return "No active safety alerts. All clear.";
      }

      final typeLabel = targetType == 'BATTERY_DETECTED' ? 'battery'
          : targetType == 'HARMFUL_GAS' ? 'harmful gas'
          : targetType == 'MOISTURE_DETECTED' ? 'moisture'
          : 'safety';

      return "There are $totalCount active $typeLabel alerts. ${details.join(', ')}.";
    } catch (e) {
      return "Unable to fetch safety alerts.";
    }
  }

  Future<String> _getItemsCollected(TimeFilter filter) async {
    try {
      final data = await _firestoreService.getAllBinsPieceCount(filter).first;
      final total = data.values.fold(0, (sum, count) => sum + count);

      final timeLabel = filter == TimeFilter.day ? 'today' :
                       filter == TimeFilter.week ? 'this week' : 'this month';

      if (total == 0) {
        return "No items collected $timeLabel.";
      }

      final breakdown = data.entries
          .where((e) => e.value > 0)
          .map((e) => "${e.key}: ${e.value}")
          .join(', ');

      return "$timeLabel, $total items collected. $breakdown.";
    } catch (e) {
      return "Unable to fetch collection statistics.";
    }
  }

  Future<String> _getStatistics() async {
    try {
      final data = await _firestoreService.getAllBinsPieceCount(TimeFilter.week).first;
      final total = data.values.fold(0, (sum, count) => sum + count);

      if (total == 0) {
        return "No statistics available for this week.";
      }

      final sorted = data.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      final top3 = sorted.take(3).map((e) => "${e.key}: ${e.value}").join(', ');

      return "This week: $total total items. Top categories: $top3.";
    } catch (e) {
      return "Unable to fetch statistics.";
    }
  }

  Future<String> _getMostCollectedType() async {
    try {
      final data = await _firestoreService.getAllBinsPieceCount(TimeFilter.week).first;

      if (data.isEmpty || data.values.every((v) => v == 0)) {
        return "No collection data available.";
      }

      final maxEntry = data.entries.reduce((a, b) => a.value > b.value ? a : b);

      return "The most collected waste type this week is ${maxEntry.key} with ${maxEntry.value} items.";
    } catch (e) {
      return "Unable to determine most collected type.";
    }
  }

  // Dispose resources
  void dispose() {
    _speech.stop();
    _tts.stop();
  }
}
