import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

/// مفاتيح Remote Config
class RemoteConfigKeys {
  // رسائل
  static const String maintenanceMode = 'maintenance_mode';
  static const String maintenanceMessage = 'maintenance_message';
  static const String announcementMessage = 'announcement_message';
  static const String showAnnouncement = 'show_announcement';

  // إعدادات التطبيق
  static const String minAppVersion = 'min_app_version';
  static const String latestAppVersion = 'latest_app_version';
  static const String forceUpdate = 'force_update';

  // روابط
  static const String supportEmail = 'support_email';
  static const String privacyPolicyUrl = 'privacy_policy_url';

  // ميزات
  static const String enableReports = 'enable_reports';
  static const String enableNotifications = 'enable_notifications';

  // معلومات الوقود
  static const String fuelQuotaAmount = 'fuel_quota_amount';
  static const String quotaPeriodDays = 'quota_period_days';
}

/// خدمة Firebase Remote Config
class RemoteConfigService {
  static final RemoteConfigService _instance = RemoteConfigService._internal();
  factory RemoteConfigService() => _instance;
  RemoteConfigService._internal();

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  /// تهيئة Remote Config
  Future<void> initialize() async {
    try {
      // إعداد الفترة الزمنية لجلب التحديثات
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(hours: 1),
        ),
      );

      // القيم الافتراضية
      await _remoteConfig.setDefaults({
        // رسائل
        RemoteConfigKeys.maintenanceMode: false,
        RemoteConfigKeys.maintenanceMessage:
            'التطبيق تحت الصيانة، يرجى المحاولة لاحقاً',
        RemoteConfigKeys.announcementMessage: '',
        RemoteConfigKeys.showAnnouncement: false,

        // إعدادات التطبيق
        RemoteConfigKeys.minAppVersion: '1.0.0',
        RemoteConfigKeys.latestAppVersion: '1.0.0',
        RemoteConfigKeys.forceUpdate: false,

        // روابط
        RemoteConfigKeys.supportEmail: 'historea@proton.me',
        RemoteConfigKeys.privacyPolicyUrl: '',

        // ميزات
        RemoteConfigKeys.enableReports: true,
        RemoteConfigKeys.enableNotifications: true,

        // معلومات الوقود
        RemoteConfigKeys.fuelQuotaAmount: 50,
        RemoteConfigKeys.quotaPeriodDays: 10,
      });

      // جلب وتفعيل القيم
      await _remoteConfig.fetchAndActivate();

      // الاستماع للتحديثات في الوقت الحقيقي
      _remoteConfig.onConfigUpdated.listen((event) async {
        await _remoteConfig.activate();
        debugPrint('Remote Config updated: ${event.updatedKeys}');
      });

      debugPrint('Remote Config initialized successfully');
    } catch (e) {
      debugPrint('Error initializing Remote Config: $e');
    }
  }

  /// جلب التحديثات يدوياً
  Future<bool> fetch() async {
    try {
      final updated = await _remoteConfig.fetchAndActivate();
      return updated;
    } catch (e) {
      debugPrint('Error fetching Remote Config: $e');
      return false;
    }
  }

  // ==================== Getters ====================

  /// هل وضع الصيانة مفعل؟
  bool get isMaintenanceMode =>
      _remoteConfig.getBool(RemoteConfigKeys.maintenanceMode);

  /// رسالة الصيانة
  String get maintenanceMessage =>
      _remoteConfig.getString(RemoteConfigKeys.maintenanceMessage);

  /// هل يظهر إعلان؟
  bool get showAnnouncement =>
      _remoteConfig.getBool(RemoteConfigKeys.showAnnouncement);

  /// رسالة الإعلان
  String get announcementMessage =>
      _remoteConfig.getString(RemoteConfigKeys.announcementMessage);

  /// الحد الأدنى لإصدار التطبيق
  String get minAppVersion =>
      _remoteConfig.getString(RemoteConfigKeys.minAppVersion);

  /// أحدث إصدار للتطبيق
  String get latestAppVersion =>
      _remoteConfig.getString(RemoteConfigKeys.latestAppVersion);

  /// هل التحديث إجباري؟
  bool get forceUpdate => _remoteConfig.getBool(RemoteConfigKeys.forceUpdate);

  /// بريد الدعم
  String get supportEmail =>
      _remoteConfig.getString(RemoteConfigKeys.supportEmail);

  /// رابط سياسة الخصوصية
  String get privacyPolicyUrl =>
      _remoteConfig.getString(RemoteConfigKeys.privacyPolicyUrl);

  /// هل البلاغات مفعلة؟
  bool get enableReports =>
      _remoteConfig.getBool(RemoteConfigKeys.enableReports);

  /// هل الإشعارات مفعلة؟
  bool get enableNotifications =>
      _remoteConfig.getBool(RemoteConfigKeys.enableNotifications);

  /// كمية حصة الوقود (لتر)
  int get fuelQuotaAmount =>
      _remoteConfig.getInt(RemoteConfigKeys.fuelQuotaAmount);

  /// مدة فترة الحصة (أيام)
  int get quotaPeriodDays =>
      _remoteConfig.getInt(RemoteConfigKeys.quotaPeriodDays);

  /// جلب قيمة مخصصة
  String getString(String key) => _remoteConfig.getString(key);
  bool getBool(String key) => _remoteConfig.getBool(key);
  int getInt(String key) => _remoteConfig.getInt(key);
  double getDouble(String key) => _remoteConfig.getDouble(key);
}
