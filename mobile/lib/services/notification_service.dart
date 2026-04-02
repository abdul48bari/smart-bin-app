import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Top-level background message handler — must be a top-level function
@pragma('vm:entry-point')
Future<void> _backgroundMessageHandler(RemoteMessage message) async {
  // FCM shows the notification automatically when app is terminated/background.
  // Nothing extra needed here.
}

class NotificationService {
  static final _messaging = FirebaseMessaging.instance;
  static final _localNotifications = FlutterLocalNotificationsPlugin();

  // Two channels: critical safety alerts and standard bin alerts
  static const _safetyChannel = AndroidNotificationChannel(
    'safety_alerts',
    'Safety Alerts',
    description: 'Battery, gas, moisture and hardware alerts',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  static const _binChannel = AndroidNotificationChannel(
    'bin_alerts',
    'Bin Alerts',
    description: 'Bin full notifications',
    importance: Importance.high,
    playSound: true,
  );

  static Future<void> initialize() async {
    if (kIsWeb) return;

    // Register background handler
    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);

    // Request permission (handles Android 13+ POST_NOTIFICATIONS automatically)
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Set foreground notification presentation options
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Init local notifications (for foreground display)
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _localNotifications.initialize(
      const InitializationSettings(android: androidInit),
    );

    // Create notification channels on Android
    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_safetyChannel);
    await androidPlugin?.createNotificationChannel(_binChannel);

    // Subscribe to the alerts topic — all alert types go here
    await _messaging.subscribeToTopic('bin_alerts');

    // Show notification when app is in foreground
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
  }

  static Future<void> _onForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final alertType = message.data['alertType'] ?? '';
    final isSafety = _isSafetyAlert(alertType);
    final channelId = isSafety ? 'safety_alerts' : 'bin_alerts';
    final channelName = isSafety ? 'Safety Alerts' : 'Bin Alerts';

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          importance: isSafety ? Importance.max : Importance.high,
          priority: isSafety ? Priority.max : Priority.high,
          color: _alertColor(alertType),
          enableVibration: isSafety,
        ),
      ),
    );
  }

  static bool _isSafetyAlert(String type) =>
      ['BATTERY_DETECTED', 'HARMFUL_GAS', 'MOISTURE_DETECTED', 'HARDWARE_ERROR'].contains(type);

  // Color tint on the notification icon per alert type
  static Color _alertColor(String type) {
    switch (type) {
      case 'HARMFUL_GAS':       return const Color(0xFFef4444);
      case 'BATTERY_DETECTED':  return const Color(0xFFf59e0b);
      case 'MOISTURE_DETECTED': return const Color(0xFF3b82f6);
      case 'HARDWARE_ERROR':    return const Color(0xFFf97316);
      case 'BIN_FULL':          return const Color(0xFF22c55e);
      default:                  return const Color(0xFF6366f1);
    }
  }
}
