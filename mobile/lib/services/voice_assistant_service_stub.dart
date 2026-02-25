// Stub file for conditional imports
import 'voice_assistant_service.dart'
    if (dart.library.html) 'voice_assistant_service_web.dart'
    as voice_service;

// Export the appropriate implementation based on platform
voice_service.VoiceAssistantService createVoiceAssistantService() {
  return voice_service.VoiceAssistantService();
}
