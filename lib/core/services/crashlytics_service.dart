import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// خدمة Firebase Crashlytics لتتبع الأخطاء والـ crashes
class CrashlyticsService {
  static final CrashlyticsService _instance = CrashlyticsService._internal();
  factory CrashlyticsService() => _instance;
  CrashlyticsService._internal();

  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  /// تهيئة خدمة Crashlytics
  Future<void> initialize() async {
    // تفعيل جمع التقارير التلقائي
    await _crashlytics.setCrashlyticsCollectionEnabled(true);

    // التقاط أخطاء Flutter
    FlutterError.onError = (errorDetails) {
      _crashlytics.recordFlutterFatalError(errorDetails);
    };

    // التقاط الأخطاء غير المعالجة في Dart
    PlatformDispatcher.instance.onError = (error, stack) {
      _crashlytics.recordError(error, stack, fatal: true);
      return true;
    };

    debugPrint('Crashlytics initialized successfully');
  }

  /// تسجيل خطأ يدوياً
  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  }) async {
    await _crashlytics.recordError(
      exception,
      stack,
      reason: reason,
      fatal: fatal,
    );
  }

  /// تسجيل رسالة للسجل (Log)
  Future<void> log(String message) async {
    await _crashlytics.log(message);
  }

  /// تعيين معرف المستخدم (لتتبع المستخدم المتأثر)
  Future<void> setUserIdentifier(String userId) async {
    await _crashlytics.setUserIdentifier(userId);
  }

  /// تعيين مفتاح مخصص (معلومات إضافية)
  Future<void> setCustomKey(String key, dynamic value) async {
    await _crashlytics.setCustomKey(key, value.toString());
  }

  /// اختبار Crash (للتطوير فقط)
  void testCrash() {
    _crashlytics.crash();
  }
}
