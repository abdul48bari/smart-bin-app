import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:permission_handler/permission_handler.dart';
import '../utils/app_colors.dart';
import '../services/voice_assistant_service_stub.dart';

class VoiceAssistantModal extends StatefulWidget {
  const VoiceAssistantModal({super.key});

  @override
  State<VoiceAssistantModal> createState() => _VoiceAssistantModalState();
}

class _VoiceAssistantModalState extends State<VoiceAssistantModal>
    with SingleTickerProviderStateMixin {
  final _voiceService = createVoiceAssistantService();

  bool _isInitialized = false;
  bool _isListening = false;
  bool _isProcessing = false;
  String _transcribedText = '';
  String _response = '';

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.28).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Do NOT initialize the voice service here — lazy init on first tap.
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _voiceService.stopListening();
    _voiceService.stopSpeaking();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Voice service initialization
  // ---------------------------------------------------------------------------

  Future<bool> _initializeVoiceService() async {
    final result = await _voiceService.initialize();

    if (!result['success']) {
      if (mounted) {
        setState(() {
          _response = result['message'] as String? ?? 'Initialization failed.';
        });

        // Only offer app settings on non-web platforms
        if (result['openSettings'] == true && !kIsWeb) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] as String? ?? ''),
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Settings',
                onPressed: () async => openAppSettings(),
              ),
            ),
          );
        }
      }
      return false;
    }

    _isInitialized = true;
    return true;
  }

  // ---------------------------------------------------------------------------
  // Listening controls
  // ---------------------------------------------------------------------------

  Future<void> _startListening() async {
    // Lazy initialization
    if (!_isInitialized) {
      final ok = await _initializeVoiceService();
      if (!ok) return;
    }

    setState(() {
      _isListening = true;
      _transcribedText = '';
      _response = '';
    });

    await _voiceService.startListening((String text, bool isFinal) async {
      // Handle special tokens — never pass them to processCommand
      if (text == '__MIC_BLOCKED__') {
        if (mounted) {
          setState(() {
            _isListening = false;
            _response = 'Microphone access blocked. Please allow microphone '
                'permissions in your browser settings.';
          });
        }
        return;
      }

      if (text == '__NO_SPEECH__') {
        if (mounted) {
          setState(() {
            _isListening = false;
            _response = 'No speech detected. Please try again.';
          });
        }
        return;
      }

      if (text == '__NOT_SUPPORTED__') {
        if (mounted) {
          setState(() {
            _isListening = false;
            _response = 'Speech recognition is not supported in this browser. '
                'Please use Chrome or Edge.';
          });
        }
        return;
      }

      // Live caption update for interim results
      if (!isFinal) {
        if (mounted && text.isNotEmpty) {
          setState(() {
            _transcribedText = text;
          });
        }
        return;
      }

      // Final result
      if (mounted) {
        setState(() {
          _isListening = false;
          if (text.isNotEmpty) _transcribedText = text;
        });
      }

      // Empty string after finalization
      if (text.isEmpty) {
        if (mounted) {
          setState(() {
            _response = 'No speech detected. Please try again.';
          });
        }
        return;
      }

      // Process the command
      if (mounted) {
        setState(() {
          _isProcessing = true;
        });
      }

      final response = await _voiceService.processCommand(text);

      if (mounted) {
        setState(() {
          _response = response;
          _isProcessing = false;
        });
        await _voiceService.speak(response);
      }
    });
  }

  Future<void> _stopListening() async {
    await _voiceService.stopListening();
    if (mounted) {
      setState(() {
        _isListening = false;
      });
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.accent(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textSecondary(context).withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(height: 24),

            // Title row
            Text(
              'Voice Assistant',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary(context),
              ),
            ),

            const SizedBox(height: 6),

            // Status label
            Text(
              _isListening
                  ? 'Listening...'
                  : _isProcessing
                      ? 'Processing...'
                      : 'Tap mic to speak',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary(context),
              ),
            ),

            const SizedBox(height: 28),

            // Microphone button
            GestureDetector(
              onTap: _isListening ? _stopListening : _startListening,
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _isListening ? _pulseAnimation.value : 1.0,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            accent,
                            accent.withOpacity(0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: accent.withOpacity(isDark ? 0.5 : 0.3),
                            blurRadius: _isListening ? 32 : 20,
                            spreadRadius: _isListening ? 6 : 0,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isListening ? Icons.mic : Icons.mic_none_rounded,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 28),

            // ---- Live caption box (always visible while listening) ----
            if (_isListening) ...[
              _LiveCaptionBox(
                transcribedText: _transcribedText,
                accent: accent,
              ),
              const SizedBox(height: 16),
            ],

            // ---- "You said" box (after final result) ----
            if (!_isListening && _transcribedText.isNotEmpty) ...[
              _TranscriptBox(
                text: _transcribedText,
                accent: accent,
                context: context,
              ),
              const SizedBox(height: 16),
            ],

            // ---- Processing indicator ----
            if (_isProcessing) ...[
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(accent),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ---- Response box ----
            if (_response.isNotEmpty && !_isProcessing) ...[
              _ResponseBox(
                text: _response,
                accent: accent,
                isDark: isDark,
                context: context,
              ),
              const SizedBox(height: 16),
            ],

            // ---- Help / example commands ----
            if (!_isListening && !_isProcessing && _response.isEmpty) ...[
              _HelpBox(accent: accent, isDark: isDark, context: context),
            ],

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _LiveCaptionBox extends StatefulWidget {
  final String transcribedText;
  final Color accent;

  const _LiveCaptionBox({
    required this.transcribedText,
    required this.accent,
  });

  @override
  State<_LiveCaptionBox> createState() => _LiveCaptionBoxState();
}

class _LiveCaptionBoxState extends State<_LiveCaptionBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _dotController;
  late Animation<double> _dotAnimation;

  @override
  void initState() {
    super.initState();
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
    _dotAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _dotController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.accent.withOpacity(0.35),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _dotAnimation,
                builder: (_, __) => Opacity(
                  opacity: _dotAnimation.value,
                  child: Icon(Icons.mic, color: widget.accent, size: 16),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Listening...',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: widget.accent,
                ),
              ),
            ],
          ),
          if (widget.transcribedText.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              widget.transcribedText,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary(context),
                height: 1.4,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TranscriptBox extends StatelessWidget {
  final String text;
  final Color accent;
  final BuildContext context;

  const _TranscriptBox({
    required this.text,
    required this.accent,
    required this.context,
  });

  @override
  Widget build(BuildContext _) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_rounded, color: accent, size: 18),
              const SizedBox(width: 8),
              Text(
                'You said:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary(context),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResponseBox extends StatelessWidget {
  final String text;
  final Color accent;
  final bool isDark;
  final BuildContext context;

  const _ResponseBox({
    required this.text,
    required this.accent,
    required this.isDark,
    required this.context,
  });

  @override
  Widget build(BuildContext _) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.06)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.smart_toy_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Assistant:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary(context),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpBox extends StatelessWidget {
  final Color accent;
  final bool isDark;
  final BuildContext context;

  const _HelpBox({
    required this.accent,
    required this.isDark,
    required this.context,
  });

  static const _examples = [
    "Fill level of plastic in bin 2",
    "What's the fill level of all bins?",
    "Which bin is most full?",
    "Which bins need emptying?",
    "Are there any safety alerts?",
    "How many items collected this week?",
    "What's the system health?",
    "Help",
  ];

  @override
  Widget build(BuildContext _) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Try these commands:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 12),
          ..._examples.map(
            (example) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 14,
                      color: accent,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      example,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
