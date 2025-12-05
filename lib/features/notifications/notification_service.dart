import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../vehicles/data/models/vehicle.dart';
import '../vehicles/data/models/quota_window.dart';

/// Service for managing local notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize timezone
    tz_data.initializeTimeZones();

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Combined initialization settings
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialize the plugin
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions on Android 13+
    await _requestPermissions();

    _isInitialized = true;
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    // Request Android permissions
    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    // Request iOS permissions
    await _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - could navigate to specific screen
    // Payload contains the vehicle ID if needed for navigation
    debugPrint('Notification tapped: ${response.payload}');
  }

  /// Schedule a notification for when a quota period starts
  Future<void> scheduleQuotaStartNotification(Vehicle vehicle) async {
    if (!_isInitialized) await initialize();

    // Check if we should notify immediately for the current window
    await checkAndNotifyIfQuotaActive(vehicle);

    // Schedule for the NEXT window
    // We always schedule for the next window regardless of current state
    // so the user is set for the future.
    final nextWindow = QuotaCalculator.getNextQuotaWindow(
      vehicle.firstQuotaStart,
      quotaLengthDays: vehicle.quotaLengthDays,
    );

    final vehicleName = vehicle.name ?? 'Your vehicle';

    await _scheduleNotification(
      id: _getStartNotificationId(vehicle.id),
      title: '⛽ Quota Open!',
      body: '$vehicleName\'s fuel quota is now open. Time to refuel!',
      scheduledTime: nextWindow.start,
      payload: 'quota_start_${vehicle.id}',
    );
  }

  /// Check if quota is currently active and notify if needed
  /// This is useful when adding a vehicle or opening the app during an active quota
  Future<void> checkAndNotifyIfQuotaActive(Vehicle vehicle) async {
    if (!_isInitialized) await initialize();

    final quotaWindow = QuotaCalculator.getCurrentQuotaWindow(
      vehicle.firstQuotaStart,
      quotaLengthDays: vehicle.quotaLengthDays,
    );

    if (quotaWindow.isActiveNow) {
      final vehicleName = vehicle.name ?? 'Your vehicle';

      // Show immediate notification
      await _showImmediateNotification(
        id: _getStartNotificationId(
          vehicle.id,
        ), // Use same ID to avoid duplicates
        title: '⛽ Quota Open Now!',
        body: '$vehicleName\'s fuel quota is currently open!',
        payload: 'quota_active_${vehicle.id}',
      );
    }
  }

  /// Schedule a reminder notification 6 hours before quota ends
  Future<void> scheduleQuotaEndReminder(Vehicle vehicle) async {
    if (!_isInitialized) await initialize();

    final quotaWindow = QuotaCalculator.getCurrentQuotaWindow(
      vehicle.firstQuotaStart,
      quotaLengthDays: vehicle.quotaLengthDays,
    );

    // Calculate reminder time (6 hours before end)
    DateTime reminderTime = quotaWindow.end.subtract(const Duration(hours: 6));

    // If reminder time is in the past but quota is still active, skip
    // If quota is not active, use next window's end time
    if (reminderTime.isBefore(DateTime.now())) {
      if (!quotaWindow.isActiveNow) {
        final nextWindow = QuotaCalculator.getNextQuotaWindow(
          vehicle.firstQuotaStart,
          quotaLengthDays: vehicle.quotaLengthDays,
        );
        reminderTime = nextWindow.end.subtract(const Duration(hours: 6));
      } else {
        return; // Don't schedule if we're past the reminder time
      }
    }

    // Don't schedule if the time is in the past
    if (reminderTime.isBefore(DateTime.now())) {
      return;
    }

    final vehicleName = vehicle.name ?? 'Your vehicle';

    await _scheduleNotification(
      id: _getEndReminderNotificationId(vehicle.id),
      title: '⏰ Quota Ending Soon!',
      body: '$vehicleName\'s fuel quota closes in 6 hours. Don\'t miss it!',
      scheduledTime: reminderTime,
      payload: 'quota_reminder_${vehicle.id}',
    );
  }

  /// Cancel all notifications for a specific vehicle
  Future<void> cancelNotificationsForVehicle(String vehicleId) async {
    await _notifications.cancel(_getStartNotificationId(vehicleId));
    await _notifications.cancel(_getEndReminderNotificationId(vehicleId));
  }

  /// Cancel all scheduled notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Schedule a notification at a specific time
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'fuel_quota_channel',
        'Fuel Quota Notifications',
        channelDescription: 'Notifications for fuel quota periods',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: payload,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      // تجاهل أخطاء جدولة الإشعارات - التطبيق سيعمل بدونها
      debugPrint('Failed to schedule notification: $e');
    }
  }

  /// Generate a unique notification ID for quota start
  int _getStartNotificationId(String vehicleId) {
    return vehicleId.hashCode;
  }

  /// Generate a unique notification ID for quota end reminder
  int _getEndReminderNotificationId(String vehicleId) {
    return vehicleId.hashCode + 1000000;
  }

  /// Show an immediate notification
  Future<void> _showImmediateNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'fuel_quota_channel',
      'Fuel Quota Notifications',
      channelDescription: 'Notifications for fuel quota periods',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  /// Show an immediate notification (for testing)
  Future<void> showTestNotification() async {
    await _showImmediateNotification(
      id: 0,
      title: 'Test Notification',
      body: 'Notifications are working!',
    );
  }
}
