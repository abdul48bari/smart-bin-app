import 'dart:html' as html;
import 'dart:js' as js;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore_service.dart';
import '../models/time_filter.dart';

// Web implementation uses the same class name for conditional export
class VoiceAssistantService {
  final FirestoreService _firestoreService = FirestoreService();

  bool _isListening = false;
  String _lastRecognizedText = '';
  String _lastResponse = '';
  DateTime? _listenStartTime;

  html.SpeechRecognition? _recognition;
  html.SpeechSynthesis? _synthesis;

  bool get isListening => _isListening;
  String get lastRecognizedText => _lastRecognizedText;
  String get lastResponse => _lastResponse;

  // ---------------------------------------------------------------------------
  // Demo data
  // ---------------------------------------------------------------------------

  static const List<Map<String, dynamic>> _demoBins = [
    {'id': 'DIN_HALL_01', 'name': 'Dining Hall',  'fill': 62},
    {'id': 'LIB_L1_02',   'name': 'Library',       'fill': 45},
    {'id': 'DORM_A_03',   'name': 'Dorm Block A',  'fill': 78},
    {'id': 'PARK_N_04',   'name': 'North Park',    'fill': 33},
    {'id': 'LAB_SCI_05',  'name': 'Science Lab',   'fill': 88},
    {'id': 'CAFE_B_06',   'name': 'Cafeteria B',   'fill': 54},
    {'id': 'GYM_FL_07',   'name': 'Gym',           'fill': 21},
  ];

  // ---------------------------------------------------------------------------
  // Initialization
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> initialize() async {
    try {
      if (!_isSpeechRecognitionSupported()) {
        return {
          'success': false,
          'message':
              'Speech recognition is not supported in this browser. Please use Chrome or Edge.',
          'openSettings': false,
        };
      }

      _synthesis = html.window.speechSynthesis;
      return {'success': true, 'message': 'Voice assistant ready'};
    } catch (e) {
      return {
        'success': false,
        'message':
            'Failed to initialize speech recognition. Please use Chrome or Edge browser.',
        'openSettings': false,
      };
    }
  }

  bool _isSpeechRecognitionSupported() {
    try {
      return js.context.hasProperty('SpeechRecognition') ||
          js.context.hasProperty('webkitSpeechRecognition');
    } catch (e) {
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Listening
  // ---------------------------------------------------------------------------

  Future<void> startListening(Function(String, bool) onResult) async {
    if (_isListening) return;

    if (!_isSpeechRecognitionSupported()) {
      onResult('__NOT_SUPPORTED__', true);
      return;
    }

    _isListening = true;
    _lastRecognizedText = '';
    _listenStartTime = DateTime.now();

    // Create a fresh instance every time for clean state
    _recognition = html.SpeechRecognition();
    _recognition!.continuous = false;
    _recognition!.interimResults = true;
    _recognition!.lang = 'en-US';
    _recognition!.maxAlternatives = 3;

    String partialText = '';

    _recognition!.onResult.listen((html.SpeechRecognitionEvent event) {
      final results = event.results;
      if (results == null || results.isEmpty) return;

      final result = results.last;

      // Pick best transcript by iterating all alternatives
      String bestTranscript = '';
      for (int i = 0; i < _recognition!.maxAlternatives!; i++) {
        final alt = result.item(i);
        if (alt != null && (alt.transcript ?? '').isNotEmpty) {
          bestTranscript = alt.transcript!;
          break;
        }
      }

      if (bestTranscript.isEmpty) return;

      final isFinal = result.isFinal == true;
      partialText = bestTranscript;
      _lastRecognizedText = bestTranscript;

      onResult(bestTranscript, isFinal);

      if (isFinal && bestTranscript.isNotEmpty) {
        _recognition!.stop();
        _isListening = false;
      }
    });

    _recognition!.onError.listen((html.Event event) {
      _isListening = false;

      // Use dynamic cast to extract the .error string
      String errorType = '';
      try {
        final dynamic dynEvent = event;
        errorType = (dynEvent.error as String?) ?? '';
      } catch (_) {}

      if (errorType == 'not-allowed') {
        onResult('__MIC_BLOCKED__', true);
      } else if (errorType == 'no-speech') {
        onResult('__NO_SPEECH__', true);
      } else {
        // For other errors, surface partial text if we have it
        if (partialText.isNotEmpty) {
          onResult(partialText, true);
        } else {
          onResult('__NO_SPEECH__', true);
        }
      }
    });

    _recognition!.onEnd.listen((html.Event event) {
      if (!_isListening) return; // already handled via onResult or onError

      _isListening = false;

      final elapsed = _listenStartTime != null
          ? DateTime.now().difference(_listenStartTime!).inMilliseconds
          : 9999;

      if (elapsed < 800 && partialText.isEmpty) {
        // Ended almost immediately with no audio — likely mic blocked
        onResult('__MIC_BLOCKED__', true);
      } else if (partialText.isNotEmpty) {
        onResult(partialText, true);
      } else {
        onResult('__NO_SPEECH__', true);
      }
    });

    try {
      _recognition!.start();
    } catch (e) {
      _isListening = false;
      onResult('__MIC_BLOCKED__', true);
    }
  }

  Future<void> stopListening() async {
    if (!_isListening || _recognition == null) return;
    try {
      _recognition!.stop();
    } catch (_) {}
    _isListening = false;
  }

  // ---------------------------------------------------------------------------
  // Speech synthesis
  // ---------------------------------------------------------------------------

  Future<void> speak(String text) async {
    if (_synthesis == null) {
      _synthesis = html.window.speechSynthesis;
    }
    try {
      _lastResponse = text;
      _synthesis!.cancel();
      final utterance = html.SpeechSynthesisUtterance(text);
      utterance.lang = 'en-US';
      utterance.rate = 0.9;
      utterance.pitch = 1.0;
      utterance.volume = 1.0;
      _synthesis!.speak(utterance);
    } catch (e) {
      // Silently ignore TTS errors — the UI already shows the text
    }
  }

  Future<void> stopSpeaking() async {
    try {
      _synthesis?.cancel();
    } catch (_) {}
  }

  // ---------------------------------------------------------------------------
  // Command processing
  // ---------------------------------------------------------------------------

  Future<String> processCommand(String command) async {
    if (command.startsWith('__')) return '';

    final normalized = _normalizeText(command);
    final cmd = normalized.toLowerCase().trim();

    try {
      // Detect which bins the user is asking about
      final binTarget = _resolveBinTarget(cmd);

      // Intent detection in priority order
      if (_hasIntent(cmd, ['most full', 'fullest', 'which bin is full', 'which bin full'])) {
        return await _getMostFullBin(binTarget);
      }

      if (_fillIntent(cmd) && binTarget == 'all') {
        return await _getAllFillLevels();
      }

      if (_fillIntent(cmd)) {
        return await _getFillLevelForTarget(cmd, binTarget);
      }

      if (_hasIntent(cmd, ['health', 'system health', 'overall health', 'health score'])) {
        return await _getSystemHealth();
      }

      if (_statusIntent(cmd)) {
        return await _getSystemStatus();
      }

      if (_safetyIntent(cmd)) {
        return await _getSafetyAlerts(_detectSafetyType(cmd));
      }

      if (_alertIntent(cmd)) {
        return await _getActiveAlerts();
      }

      if (_analyticsIntent(cmd)) {
        return await _getAnalytics(cmd);
      }

      return "I didn't understand that. Try asking: "
          "\"What's the fill level of all bins?\", "
          "\"Which bin is most full?\", "
          "\"Are there any safety alerts?\", "
          "\"How many items collected this week?\", or "
          "\"What's the system health?\"";
    } catch (e) {
      return "Sorry, I encountered an error processing your request.";
    }
  }

  // ---------------------------------------------------------------------------
  // Intent helpers
  // ---------------------------------------------------------------------------

  bool _fillIntent(String cmd) {
    return _hasIntent(cmd, [
      'fill', 'capacity', 'how full', 'percent', 'fullest', 'most full', 'level',
    ]);
  }

  bool _statusIntent(String cmd) {
    return _hasIntent(cmd, [
      'status', 'online', 'offline', 'working', 'operational', 'active',
      'how many bins', 'number of bins',
    ]);
  }

  bool _safetyIntent(String cmd) {
    return _hasIntent(cmd, [
      'safety', 'battery', 'harmful gas', 'gas alert', 'moisture', 'hazard',
      'toxic', 'dangerous',
    ]);
  }

  bool _alertIntent(String cmd) {
    return _hasIntent(cmd, [
      'alert', 'alarm', 'warning', 'issue', 'problem',
    ]);
  }

  bool _analyticsIntent(String cmd) {
    return _hasIntent(cmd, [
      'collected', 'collection', 'piece', 'item', 'recycle', 'stat',
      'today', 'week', 'month', 'most common', 'top waste',
    ]);
  }

  bool _hasIntent(String cmd, List<String> keywords) {
    return keywords.any((kw) => cmd.contains(kw));
  }

  String? _detectSafetyType(String cmd) {
    if (cmd.contains('battery')) return 'BATTERY_DETECTED';
    if (cmd.contains('gas')) return 'HARMFUL_GAS';
    if (cmd.contains('moisture') || cmd.contains('water')) return 'MOISTURE_DETECTED';
    return null;
  }

  TimeFilter _detectTimeFilter(String cmd) {
    if (cmd.contains('today') || cmd.contains(' day')) return TimeFilter.day;
    if (cmd.contains('month')) return TimeFilter.month;
    return TimeFilter.week;
  }

  // ---------------------------------------------------------------------------
  // Bin target resolution
  // ---------------------------------------------------------------------------

  /// Returns a bin ID string, 'all', or a position index as '1'/'2'/...
  String _resolveBinTarget(String cmd) {
    // Aggregate keywords
    if (_hasIntent(cmd, ['all', 'every', 'each'])) return 'all';

    // Location name keywords
    const locationMap = {
      'dining': 'DIN_HALL_01',
      'library': 'LIB_L1_02',
      'dorm': 'DORM_A_03',
      'park': 'PARK_N_04',
      'science lab': 'LAB_SCI_05',
      'lab': 'LAB_SCI_05',
      'cafe': 'CAFE_B_06',
      'cafeteria': 'CAFE_B_06',
      'gym': 'GYM_FL_07',
    };
    for (final entry in locationMap.entries) {
      if (cmd.contains(entry.key)) return entry.value;
    }

    // Word numbers: "bin one", "second bin"
    const wordPos = {
      'first': '1', 'one': '1',
      'second': '2', 'two': '2',
      'third': '3', 'three': '3',
      'fourth': '4', 'four': '4',
      'fifth': '5', 'five': '5',
      'sixth': '6', 'six': '6',
      'seventh': '7', 'seven': '7',
    };
    for (final entry in wordPos.entries) {
      final patterns = [
        RegExp('bin\\s+${entry.key}\\b'),
        RegExp('${entry.key}\\s+bin\\b'),
        RegExp('bin\\s+number\\s+${entry.key}\\b'),
      ];
      if (patterns.any((p) => p.hasMatch(cmd))) return entry.value;
    }

    // Numeric: "bin 1", "bin number 3", "#2"
    final numPatterns = [
      RegExp(r'bin\s+number\s+(\d+)', caseSensitive: false),
      RegExp(r'bin\s+#?(\d+)', caseSensitive: false),
      RegExp(r'#(\d+)'),
      RegExp(r'number\s+(\d+)', caseSensitive: false),
    ];
    for (final p in numPatterns) {
      final m = p.firstMatch(cmd);
      if (m != null) return m.group(1)!;
    }

    // Default: all bins
    return 'all';
  }

  // ---------------------------------------------------------------------------
  // Bin fetching
  // ---------------------------------------------------------------------------

  Future<List<Map<String, dynamic>>> _fetchBins() async {
    if (FirestoreService.isDemoMode) {
      return List<Map<String, dynamic>>.from(_demoBins);
    }

    final snapshot = await FirebaseFirestore.instance.collection('bins').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'name': data['name'] ?? data['location'] ?? doc.id,
        'status': data['status'] ?? 'offline',
        'fillLevel': data['fillLevel'],
        ...data,
      };
    }).toList();
  }

  Future<int> _fetchBinFillLevel(String binId) async {
    if (FirestoreService.isDemoMode) {
      final match = _demoBins.firstWhere(
        (b) => b['id'] == binId,
        orElse: () => {'fill': 0},
      );
      return (match['fill'] as num?)?.toInt() ?? 0;
    }

    // Try subBins collection first
    final subBinsSnap = await FirebaseFirestore.instance
        .collection('bins')
        .doc(binId)
        .collection('subBins')
        .get();

    if (subBinsSnap.docs.isNotEmpty) {
      int total = 0;
      for (final doc in subBinsSnap.docs) {
        final val = doc.data()['currentFillPercent'];
        if (val != null) total += (val as num).toInt();
      }
      return (total / subBinsSnap.docs.length).round();
    }

    // Fall back to fillLevel on the bin doc
    final binDoc = await FirebaseFirestore.instance.collection('bins').doc(binId).get();
    final fillLevel = binDoc.data()?['fillLevel'];
    return fillLevel != null ? (fillLevel as num).toInt() : 0;
  }

  // ---------------------------------------------------------------------------
  // Response generators
  // ---------------------------------------------------------------------------

  Future<String> _getSystemStatus() async {
    final bins = await _fetchBins();
    if (bins.isEmpty) return "No bins are configured in the system.";

    if (FirestoreService.isDemoMode) {
      return "System status: ${bins.length} bins total — all online and operating normally.";
    }

    int online = 0, offline = 0, maintenance = 0;
    for (final bin in bins) {
      final s = (bin['status'] as String?) ?? 'offline';
      if (s == 'online') online++;
      else if (s == 'maintenance') maintenance++;
      else offline++;
    }

    final parts = <String>[];
    if (online > 0) parts.add('$online online');
    if (offline > 0) parts.add('$offline offline');
    if (maintenance > 0) parts.add('$maintenance in maintenance');

    return "System status: ${bins.length} total bins — ${parts.join(', ')}.";
  }

  Future<String> _getSystemHealth() async {
    final bins = await _fetchBins();
    if (bins.isEmpty) return "No bins are configured.";

    if (FirestoreService.isDemoMode) {
      final avgFill = _demoBins
          .map((b) => b['fill'] as int)
          .reduce((a, b) => a + b) ~/
          _demoBins.length;
      final healthScore = (100 - avgFill).clamp(0, 100);
      return "System health score is $healthScore out of 100. "
          "${_demoBins.length} bins active with an average fill level of $avgFill%.";
    }

    int online = 0, offline = 0, maintenance = 0;
    for (final bin in bins) {
      final s = (bin['status'] as String?) ?? 'offline';
      if (s == 'online') online++;
      else if (s == 'maintenance') maintenance++;
      else offline++;
    }

    final healthScore = (online / bins.length * 100).round();
    String healthLabel;
    if (healthScore >= 90) healthLabel = 'Excellent';
    else if (healthScore >= 70) healthLabel = 'Good';
    else if (healthScore >= 50) healthLabel = 'Fair';
    else healthLabel = 'Poor';

    return "System health is $healthScore% ($healthLabel). "
        "$online bins online, $offline offline, $maintenance in maintenance.";
  }

  Future<String> _getFillLevelForTarget(String cmd, String target) async {
    final bins = await _fetchBins();
    if (bins.isEmpty) return "No bins are configured.";

    // Resolve position index or bin ID
    Map<String, dynamic>? targetBin;

    if (RegExp(r'^\d+$').hasMatch(target)) {
      // Position-based (1-indexed)
      final idx = int.parse(target) - 1;
      if (idx >= 0 && idx < bins.length) {
        targetBin = bins[idx];
      }
    } else {
      // Direct bin ID
      try {
        targetBin = bins.firstWhere((b) => b['id'] == target);
      } catch (_) {}
    }

    if (targetBin == null) {
      return "I couldn't find that bin. Try asking about all bins or a specific bin by name.";
    }

    final fillLevel = await _fetchBinFillLevel(targetBin['id'] as String);
    final name = targetBin['name'] as String? ?? targetBin['id'] as String;
    return "The $name bin is currently at $fillLevel% capacity.";
  }

  Future<String> _getAllFillLevels() async {
    final bins = await _fetchBins();
    if (bins.isEmpty) return "No bins are configured.";

    if (FirestoreService.isDemoMode) {
      final levels = _demoBins
          .map((b) => "${b['name']}: ${b['fill']}%")
          .join(', ');
      return "Current fill levels — $levels.";
    }

    final results = <String>[];
    for (final bin in bins) {
      final fill = await _fetchBinFillLevel(bin['id'] as String);
      final name = (bin['name'] as String?) ?? bin['id'] as String;
      results.add("$name: $fill%");
    }

    if (results.isEmpty) return "No fill level data available.";
    return "Current fill levels — ${results.join(', ')}.";
  }

  Future<String> _getMostFullBin(String binTarget) async {
    final bins = await _fetchBins();
    if (bins.isEmpty) return "No bins are configured.";

    if (FirestoreService.isDemoMode) {
      final sorted = List<Map<String, dynamic>>.from(_demoBins)
        ..sort((a, b) => (b['fill'] as int).compareTo(a['fill'] as int));
      final top = sorted.first;
      return "The most full bin is ${top['name']} at ${top['fill']}% capacity.";
    }

    int maxFill = -1;
    String maxName = '';

    for (final bin in bins) {
      final fill = await _fetchBinFillLevel(bin['id'] as String);
      if (fill > maxFill) {
        maxFill = fill;
        maxName = (bin['name'] as String?) ?? bin['id'] as String;
      }
    }

    if (maxFill < 0) return "No fill level data available.";
    return "The most full bin is $maxName at $maxFill% capacity.";
  }

  Future<String> _getSafetyAlerts(String? alertType) async {
    if (FirestoreService.isDemoMode) {
      final typeLabel = alertType == 'BATTERY_DETECTED'
          ? 'battery'
          : alertType == 'HARMFUL_GAS'
              ? 'harmful gas'
              : alertType == 'MOISTURE_DETECTED'
                  ? 'moisture'
                  : 'safety';
      return "No active $typeLabel alerts in demo mode. All clear.";
    }

    final binsSnapshot = await FirebaseFirestore.instance.collection('bins').get();
    const safetyTypes = {'BATTERY_DETECTED', 'HARMFUL_GAS', 'MOISTURE_DETECTED'};

    int totalCount = 0;
    final details = <String>[];

    for (final bin in binsSnapshot.docs) {
      var query = FirebaseFirestore.instance
          .collection('bins')
          .doc(bin.id)
          .collection('alerts')
          .where('isResolved', isEqualTo: false);

      final alertsSnapshot = await query.get();

      for (final alert in alertsSnapshot.docs) {
        final data = alert.data();
        final type = (data['alertType'] as String?) ?? '';
        if (alertType != null ? type == alertType : safetyTypes.contains(type)) {
          final label = type == 'BATTERY_DETECTED'
              ? 'battery'
              : type == 'HARMFUL_GAS'
                  ? 'harmful gas'
                  : 'moisture';
          final binName = (bin.data()['name'] as String?) ?? bin.id;
          details.add("$binName: $label");
          totalCount++;
        }
      }
    }

    if (totalCount == 0) {
      final typeLabel = alertType == 'BATTERY_DETECTED'
          ? 'battery'
          : alertType == 'HARMFUL_GAS'
              ? 'harmful gas'
              : alertType == 'MOISTURE_DETECTED'
                  ? 'moisture'
                  : 'safety';
      return "No active $typeLabel alerts. All clear.";
    }

    final typeLabel = alertType == 'BATTERY_DETECTED'
        ? 'battery'
        : alertType == 'HARMFUL_GAS'
            ? 'harmful gas'
            : alertType == 'MOISTURE_DETECTED'
                ? 'moisture'
                : 'safety';

    return "There ${totalCount == 1 ? 'is' : 'are'} $totalCount active $typeLabel "
        "${totalCount == 1 ? 'alert' : 'alerts'}: ${details.join('; ')}.";
  }

  Future<String> _getActiveAlerts() async {
    if (FirestoreService.isDemoMode) {
      return "No active alerts in demo mode. All systems normal.";
    }

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
        final binName = (bin.data()['name'] as String?) ?? bin.id;
        alertsByBin[binName] = alertsSnapshot.docs.length;
        totalAlerts += alertsSnapshot.docs.length;
      }
    }

    if (totalAlerts == 0) return "There are no active alerts. All systems normal.";

    final binDetails = alertsByBin.entries
        .map((e) => "${e.key}: ${e.value} ${e.value == 1 ? 'alert' : 'alerts'}")
        .join(', ');

    return "There ${totalAlerts == 1 ? 'is' : 'are'} $totalAlerts active "
        "${totalAlerts == 1 ? 'alert' : 'alerts'} across ${alertsByBin.length} "
        "${alertsByBin.length == 1 ? 'bin' : 'bins'}. $binDetails.";
  }

  Future<String> _getAnalytics(String cmd) async {
    final filter = _detectTimeFilter(cmd);
    final askingMost = _hasIntent(cmd, ['most common', 'top waste', 'most collected', 'most']);

    try {
      final data = await _firestoreService.getAllBinsPieceCount(filter).first;
      final total = data.values.fold(0, (sum, v) => sum + v);

      final timeLabel = filter == TimeFilter.day
          ? 'today'
          : filter == TimeFilter.week
              ? 'this week'
              : 'this month';

      if (total == 0) return "No items collected $timeLabel.";

      final sorted = data.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

      if (askingMost) {
        final top = sorted.first;
        return "The most collected waste type $timeLabel is ${top.key} with ${top.value} items.";
      }

      final top3 = sorted
          .where((e) => e.value > 0)
          .take(3)
          .map((e) => "${e.key}: ${e.value}")
          .join(', ');

      return "$total items collected $timeLabel. Top categories: $top3.";
    } catch (e) {
      return "Unable to fetch collection statistics.";
    }
  }

  // ---------------------------------------------------------------------------
  // Text normalization
  // ---------------------------------------------------------------------------

  String _normalizeText(String text) {
    String n = text.toLowerCase().trim();

    final corrections = <String, String>{
      // bin / bins
      r'\bbeans?\b': 'bins',
      r'\bbeen\b': 'bin',
      r'\bben\b': 'bin',
      r'\bpin\b': 'bin',
      r'\bbun\b': 'bin',
      r'\bbing\b': 'bin',

      // fill
      r'\bfeel\b': 'fill',
      r'\bfin\b': 'fill',
      r'\bfile\b': 'fill',
      r'\bfield\b': 'fill',
      r'\bphil\b': 'fill',
      r'\bfell\b': 'fill',
      r'\bfilm\b': 'fill',
      r'\bfull level\b': 'fill level',

      // status
      r'\bstadiums?\b': 'status',
      r'\bstattus\b': 'status',

      // alert / safety
      r'\balarms?\b': 'alert',
      r'\bsaftey\b': 'safety',
      r'\bsafty\b': 'safety',

      // waste types
      r'\bplastik\b': 'plastic',
      r'\bplastick\b': 'plastic',
      r'\bpapper\b': 'paper',
      r'\borgenik\b': 'organic',

      // safety alert terms
      r'\bbatter\b': 'battery',
      r'\bgass\b': 'gas',
      r'\bmoister\b': 'moisture',

      // cans
      r'\bchance\b': 'cans',
      r'\bkanz\b': 'cans',
      r'\bkans\b': 'cans',

      // number words that conflict with vocabulary
      r'\bwon\b': 'one',
      r'\btoo\b': 'two',
      r'\btree\b': 'three',

      // online / offline spacing
      r'\bon line\b': 'online',
      r'\boff line\b': 'offline',
    };

    corrections.forEach((pattern, replacement) {
      n = n.replaceAll(RegExp(pattern, caseSensitive: false), replacement);
    });

    return n;
  }

  // ---------------------------------------------------------------------------
  // Dispose
  // ---------------------------------------------------------------------------

  void dispose() {
    stopListening();
    stopSpeaking();
  }
}
