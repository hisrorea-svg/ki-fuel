import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// خدمة إشعارات Firebase Cloud Messaging
class FirebaseMessagingService {
  static final FirebaseMessagingService _instance =
      FirebaseMessagingService._internal();
  factory FirebaseMessagingService() => _instance;
  FirebaseMessagingService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  /// تهيئة خدمة الإشعارات
  Future<void> initialize() async {
    // طلب إذن الإشعارات
    await _requestPermission();

    // الحصول على FCM Token
    await _getToken();

    // الاستماع لتحديث التوكن
    _messaging.onTokenRefresh.listen((token) {
      _fcmToken = token;
      debugPrint('FCM Token refreshed: $token');
    });

    // إعداد قناة الإشعارات للـ Android
    await _setupNotificationChannel();

    // الاستماع للإشعارات عندما يكون التطبيق في المقدمة
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // الاستماع عند فتح التطبيق من إشعار
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // التحقق من الإشعار الذي فتح التطبيق
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }
  }

  /// طلب إذن الإشعارات
  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint('FCM Permission status: ${settings.authorizationStatus}');
  }

  /// الحصول على FCM Token
  Future<void> _getToken() async {
    try {
      _fcmToken = await _messaging.getToken();
      debugPrint('FCM Token: $_fcmToken');
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
    }
  }

  /// إعداد قناة الإشعارات للـ Android
  Future<void> _setupNotificationChannel() async {
    const androidChannel = AndroidNotificationChannel(
      'ki_fuel_notifications',
      'Ki Fuel Notifications',
      description: 'إشعارات تطبيق حصة وقود كركوك',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidChannel);
  }

  /// معالجة الإشعارات في المقدمة
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('Foreground message received: ${message.messageId}');

    final notification = message.notification;
    if (notification != null) {
      // عرض الإشعار كـ Local Notification
      await _showLocalNotification(
        title: notification.title ?? 'Ki Fuel',
        body: notification.body ?? '',
        payload: message.data.toString(),
      );
    }
  }

  /// معالجة فتح التطبيق من إشعار
  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('App opened from notification: ${message.messageId}');
  }

  /// عرض إشعار محلي
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'ki_fuel_notifications',
      'Ki Fuel Notifications',
      channelDescription: 'إشعارات تطبيق حصة وقود كركوك',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  /// الاشتراك في موضوع معين
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    debugPrint('Subscribed to topic: $topic');
  }

  /// إلغاء الاشتراك من موضوع
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    debugPrint('Unsubscribed from topic: $topic');
  }
}
