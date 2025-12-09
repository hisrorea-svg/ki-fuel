import 'package:flutter/material.dart';

/// نظام الترجمة للتطبيق
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'ar': {
      // عام
      'app_title': 'Ki Fuel',
      'refresh': 'تحديث',
      'cancel': 'إلغاء',
      'delete': 'حذف',
      'edit': 'تعديل',
      'save': 'حفظ',
      'add': 'إضافة',
      'retry': 'إعادة المحاولة',
      'optional': 'اختياري',
      'required': 'مطلوب',
      'error': 'خطأ',
      'success': 'نجح',
      'loading': 'جاري التحميل...',
      'exit_app': 'الخروج من التطبيق',
      'exit_app_confirm': 'هل تريد الخروج من التطبيق؟',
      'exit': 'خروج',

      // Dashboard والترحيب
      'good_morning': 'صباح الخير ☀️',
      'good_afternoon': 'مساء الخير 🌤️',
      'good_evening': 'مساء الخير 🌙',
      'welcome_message': 'تابع حصص الوقود الخاصة بسياراتك',
      'my_vehicles': 'سياراتي',
      'total_vehicles': 'سياراتي',
      'quota_status': 'حالة الحصة',
      'next_quota': 'الحصة القادمة',
      'remaining': 'متبقي',
      'waiting_to_start': 'في انتظار البدء',

      // الوقت
      'to': 'إلى',
      'day_short': 'ي',
      'seconds': 'ثانية',
      'day': 'يوم',
      'days': 'أيام',
      'hour': 'ساعة',
      'hours': 'ساعات',
      'minute': 'دقيقة',
      'minutes': 'دقائق',
      'ended': 'انتهت',

      // الصفحة الرئيسية
      'no_vehicles_yet': 'لا توجد سيارات بعد',
      'add_first_vehicle_hint': 'أضف سيارتك الأولى لبدء متابعة حصص الوقود',
      'add_first_vehicle': 'أضف سيارتك الأولى',
      'add_vehicle': 'إضافة سيارة',
      'error_loading_vehicles': 'خطأ في تحميل السيارات',

      // صفحة إضافة/تعديل السيارة
      'edit_vehicle': 'تعديل السيارة',
      'vehicle_name': 'اسم السيارة',
      'vehicle_name_hint': 'مثال: سيارتي، سيارة العائلة',
      'leave_empty_auto_name': 'اتركه فارغاً للاسم التلقائي',
      'vehicle_type': 'نوع السيارة',
      'select_vehicle_type': 'اختر نوع السيارة',
      'quota_system_info': 'معلومات نظام الحصص',
      'app_subtitle': 'الحصة الوقودية لمدينة كركوك',
      'quota_repeats_every_5_days': 'الحصة تتكرر كل 5 أيام',
      'current_quota': 'الحصة الحالية',
      'currently_open': 'مفتوحة الآن',
      'currently_closed': 'مغلقة الآن',
      'quota_auto_message':
          'جدول الحصص تلقائي ويطبق على جميع السيارات بالتساوي',
      'save_changes': 'حفظ التغييرات',
      'vehicle_added': 'تمت إضافة السيارة',
      'vehicle_updated': 'تم تحديث السيارة',

      // أنواع السيارات
      'sedan': 'سيدان',
      'suv': 'دفع رباعي',
      'pickup': 'بيكب',
      'van': 'فان',
      'motorcycle': 'دراجة نارية',
      'taxi': 'تاكسي',
      'truck': 'شاحنة',
      'bus': 'باص',

      // بطاقة السيارة
      'quota_number': 'الحصة',
      'ends_in': 'تنتهي خلال',
      'opens_in': 'تفتح خلال',
      'open': 'مفتوحة',
      'closed': 'مغلقة',
      'fueled': 'تم التعبئة ✅',
      'not_fueled': 'لم يتم التعبئة',
      'next_quota_starts': 'الحصة القادمة تبدأ بعد',
      'you_are_fueled': 'أنت مفول 👍',

      // صفحة تفاصيل السيارة
      'quota_timeline': 'جدول الحصص',
      'fuel_logs': 'سجل التزود',
      'entries': 'سجلات',
      'add_fuel_log': 'إضافة تزود',
      'quota_is_open': 'الحصة مفتوحة',
      'quota_is_closed': 'الحصة مغلقة',
      'start': 'البداية',
      'end': 'النهاية',
      'now': 'الآن',
      'current': 'الحالية',
      'past': 'سابقة',
      'upcoming': 'قادمة',

      // سجل الوقود
      'no_fuel_logs_yet': 'لا توجد سجلات تزود بعد',
      'tap_to_add_first_entry': 'اضغط الزر أدناه لإضافة أول سجل',
      'fuel_log_deleted': 'تم حذف سجل التزود',
      'record_fuel_refill': 'سجّل تزودك بالوقود',
      'record_fuel': 'تسجيل التزود بالوقود',
      'date_time': 'التاريخ والوقت',
      'when_refuel': 'متى تزودت بالوقود؟',
      'date': 'التاريخ',
      'time': 'الوقت',
      'set_to_now': 'الآن',
      'note': 'ملاحظة',
      'note_hint': 'مثال: محطة الشركة، بنزين ممتاز...',
      'notes': 'ملاحظات',
      'notes_hint': 'مثال: محطة الشركة، بنزين ممتاز',
      'notes_helper': 'اختياري - أضف أي ملاحظات',
      'add_entry': 'إضافة السجل',
      'save_fuel_log': 'حفظ التزود',
      'fuel_log_added': 'تمت إضافة سجل التزود',
      'future_date_error': 'لا يمكن اختيار تاريخ في المستقبل',
      'already_fueled_in_quota': 'تم التعبئة في هذه الحصة',
      'already_fueled_in_quota_message':
          'لقد سجلت تعبئة لهذه السيارة في الحصة الحالية. انتظر الحصة القادمة لإضافة تعبئة جديدة.',
      'next_quota_info': 'الحصة القادمة تبدأ:',

      // حذف السيارة
      'delete_vehicle': 'حذف السيارة',
      'delete_vehicle_confirm':
          'هل أنت متأكد من حذف "{{name}}"؟ سيتم حذف جميع سجلات التزود لهذه السيارة أيضاً.',
      'vehicle_deleted': 'تم حذف السيارة',

      // شريط التنقل
      'home': 'الرئيسية',
      'maps': 'الخرائط',
      'notifications': 'الإشعارات',
      'settings': 'الإعدادات',
      'maps_coming_soon': 'خريطة محطات الوقود قادمة قريباً',

      // خريطة المحطات
      'loading_fuel_stations': 'جارِ تحميل محطات الوقود...',
      'error_loading_stations': 'حدث خطأ أثناء جلب محطات الوقود',
      'no_fuel_stations': 'لا توجد محطات وقود في المنطقة المحددة',
      'open_in_maps': 'فتح في الخرائط',
      'open_in_waze': 'فتح في Waze',
      'navigate_to_station': 'الانتقال إلى المحطة',

      // صفحة الإعدادات
      'app_description': 'تطبيق لمتابعة حصص الوقود في كركوك',
      'version': 'الإصدار',
      'updates': 'التحديثات',
      'check_for_updates': 'التحقق من التحديثات',
      'update_available': 'يوجد تحديث جديد',
      'check_for_new_version': 'تحقق من وجود إصدار جديد',
      'app_up_to_date': 'التطبيق محدث لآخر إصدار',
      'update_check_failed': 'فشل التحقق من التحديثات',
      'new_version': 'الإصدار الجديد',
      'current_version': 'الإصدار الحالي',
      'whats_new': 'ما الجديد',
      'later': 'لاحقاً',
      'download_update': 'تحميل التحديث',
      'update_required': 'تحديث مطلوب',
      'update_required_message': 'يرجى تحديث التطبيق للاستمرار في استخدامه',
      'latest_version': 'أحدث إصدار',
      'support': 'الدعم',
      'contact_support': 'تواصل معنا',
      'cannot_open_email': 'لا يمكن فتح البريد الإلكتروني',
      'legal': 'القانونية',
      'privacy_policy': 'سياسة الخصوصية',
      'privacy_policy_subtitle': 'كيف نحمي بياناتك',
      'developed_by_historea': 'تطوير فريق Historea ❤️',
      'last_updated': 'آخر تحديث: ديسمبر 2025',
      'contact_us': 'تواصل معنا',
      'privacy_contact_message':
          'إذا كان لديك أي استفسار حول سياسة الخصوصية، لا تتردد في التواصل معنا عبر historea@proton.me',

      // الإشعارات
      'your_vehicle': 'سيارتك',
      'notification_quota_open': 'الحصة مفتوحة!',
      'notification_quota_open_body':
          'حصة وقود {{name}} مفتوحة الآن. حان وقت التزود!',
      'notification_quota_open_now': 'الحصة مفتوحة الآن!',
      'notification_quota_open_now_body': 'حصة وقود {{name}} مفتوحة حالياً!',
      'notification_quota_ending': 'الحصة تنتهي قريباً!',
      'notification_quota_ending_body':
          'حصة وقود {{name}} تغلق بعد 6 ساعات. لا تفوّتها!',

      // صفحة الإشعارات
      'notifications_page_title': 'الإشعارات',
      'mark_all_read': 'تحديد الكل كمقروء',
      'clear_all': 'مسح الكل',
      'no_notifications': 'لا توجد إشعارات حالياً',
      'clear_all_notifications': 'مسح جميع الإشعارات؟',
      'clear_all_notifications_confirm':
          'هل أنت متأكد من حذف سجل الإشعارات بالكامل؟',
      'clear': 'مسح',

      // البلاغات
      'reports': 'البلاغات',
      'reports_subtitle': 'الإبلاغ عن مشاكل المحطات',
      'reports_disabled': 'البلاغات غير متاحة حالياً',
      'reports_disabled_message':
          'تم تعطيل نظام البلاغات مؤقتاً، يرجى المحاولة لاحقاً',
      'report_problem': 'الإبلاغ عن مشكلة',
      'report_description':
          'ساعدنا في تحسين الخدمة بالإبلاغ عن مشاكل محطات الوقود',
      'report_type': 'نوع البلاغ',
      'report_details': 'تفاصيل البلاغ',
      'station_name': 'اسم المحطة',
      'station_name_hint': 'مثال: محطة الكرامة',
      'location': 'الموقع',
      'location_hint': 'مثال: شارع أطلس، كركوك',
      'additional_details': 'تفاصيل إضافية',
      'additional_details_hint': 'اكتب أي معلومات إضافية تساعدنا...',
      'station_closed': 'محطة مغلقة',
      'station_crowded': 'ازدحام شديد',
      'out_of_fuel': 'نفاد الوقود',
      'price_issue': 'مشكلة في السعر',
      'other_issue': 'أخرى',
      'send_report': 'إرسال البلاغ',
      'sending': 'جارِ الإرسال...',
      'report_note': 'سيتم مراجعة البلاغ والتعامل معه في أقرب وقت',
      'please_fill_details': 'يرجى ملء بعض التفاصيل',
      'fuel_report': 'بلاغ وقود',
      'sent_from_app': 'تم الإرسال من تطبيق Ki Fuel',
      'report_opened_in_email': 'تم فتح البلاغ في تطبيق البريد',
      'report_sent_successfully': 'تم إرسال البلاغ بنجاح ✓',
      'error_sending_report': 'حدث خطأ في إرسال البلاغ',
      'no_internet_connection': 'لا يوجد اتصال بالإنترنت',
      'permission_denied_error': 'ليس لديك صلاحية لإرسال البلاغ',
      'network_error': 'خطأ في الشبكة، يرجى المحاولة لاحقاً',
      'timeout_error': 'انتهت مهلة الاتصال، يرجى المحاولة مجدداً',
      'report_will_send_when_online': 'سيتم إرسال البلاغ عند عودة الاتصال',
      'report_pending_offline': 'بلاغ معلق - سيرسل عند عودة الاتصال',

      // اللغة
      'language': 'اللغة',
      'language_subtitle': 'تغيير لغة التطبيق',
      'arabic': 'العربية',
      'english': 'English',
      'select_language': 'اختر اللغة',

      // المظهر
      'appearance': 'المظهر',
      'dark_mode': 'الوضع الداكن',
      'dark_mode_on': 'مفعّل',
      'dark_mode_off': 'معطّل',
    },
    'en': {
      // General
      'app_title': 'Ki Fuel',
      'refresh': 'Refresh',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'edit': 'Edit',
      'save': 'Save',
      'add': 'Add',
      'retry': 'Retry',
      'optional': 'Optional',
      'required': 'Required',
      'error': 'Error',
      'success': 'Success',
      'loading': 'Loading...',
      'exit_app': 'Exit App',
      'exit_app_confirm': 'Do you want to exit the app?',
      'exit': 'Exit',

      // Dashboard and Welcome
      'good_morning': 'Good Morning ☀️',
      'good_afternoon': 'Good Afternoon 🌤️',
      'good_evening': 'Good Evening 🌙',
      'welcome_message': 'Track your vehicles fuel quota',
      'my_vehicles': 'My Vehicles',
      'total_vehicles': 'Vehicles',
      'quota_status': 'Quota Status',
      'next_quota': 'Next Quota',
      'remaining': 'Remaining',
      'waiting_to_start': 'Waiting to start',

      // Time
      'to': 'to',
      'day_short': 'd',
      'seconds': 'sec',
      'day': 'day',
      'days': 'days',
      'hour': 'hour',
      'hours': 'hours',
      'minute': 'minute',
      'minutes': 'minutes',
      'ended': 'Ended',

      // Home page
      'no_vehicles_yet': 'No Vehicles Yet',
      'add_first_vehicle_hint':
          'Add your first vehicle to start tracking fuel quota periods.',
      'add_first_vehicle': 'Add Your First Vehicle',
      'add_vehicle': 'Add Vehicle',
      'error_loading_vehicles': 'Error loading vehicles',

      // Add/Edit vehicle page
      'edit_vehicle': 'Edit Vehicle',
      'vehicle_name': 'Vehicle Name',
      'vehicle_name_hint': 'e.g., My Car, Family Car',
      'leave_empty_auto_name': 'Leave empty for auto-generated name',
      'vehicle_type': 'Vehicle Type',
      'select_vehicle_type': 'Select vehicle type',
      'quota_system_info': 'Quota System Info',
      'app_subtitle': 'Kirkuk City Fuel Quota',
      'quota_repeats_every_5_days': 'Quota repeats every 5 days',
      'current_quota': 'Current: Quota',
      'currently_open': 'Currently OPEN',
      'currently_closed': 'Currently CLOSED',
      'quota_auto_message':
          'The quota schedule is automatic and applies to all vehicles equally.',
      'save_changes': 'Save Changes',
      'vehicle_added': 'Vehicle added',
      'vehicle_updated': 'Vehicle updated',

      // Vehicle types
      'sedan': 'Sedan',
      'suv': 'SUV',
      'pickup': 'Pickup',
      'van': 'Van',
      'motorcycle': 'Motorcycle',
      'taxi': 'Taxi',
      'truck': 'Truck',
      'bus': 'Bus',

      // Vehicle card
      'quota_number': 'Quota',
      'ends_in': 'Ends in',
      'opens_in': 'Opens in',
      'open': 'OPEN',
      'closed': 'CLOSED',
      'fueled': 'Fueled ✅',
      'not_fueled': 'Not Fueled',
      'next_quota_starts': 'Next quota starts in',
      'you_are_fueled': 'You are fueled 👍',

      // Vehicle detail page
      'quota_timeline': 'Quota Timeline',
      'fuel_logs': 'Fuel Logs',
      'entries': 'entries',
      'add_fuel_log': 'Add Fuel Log',
      'quota_is_open': 'Quota is OPEN',
      'quota_is_closed': 'Quota is CLOSED',
      'start': 'Start',
      'end': 'End',
      'now': 'NOW',
      'current': 'CURRENT',
      'past': 'Past',
      'upcoming': 'Upcoming',

      // Fuel logs
      'no_fuel_logs_yet': 'No fuel logs yet',
      'tap_to_add_first_entry': 'Tap the button below to add your first entry',
      'fuel_log_deleted': 'Fuel log deleted',
      'record_fuel_refill': 'Record your fuel refill',
      'record_fuel': 'Record Fuel Refill',
      'date_time': 'Date & Time',
      'when_refuel': 'When did you refuel?',
      'date': 'Date',
      'time': 'Time',
      'set_to_now': 'Now',
      'note': 'Note',
      'note_hint': 'e.g., Gas station name, fuel type...',
      'notes': 'Notes',
      'notes_hint': 'e.g., Gas station name, fuel type',
      'notes_helper': 'Optional - Add any notes',
      'add_entry': 'Add Entry',
      'save_fuel_log': 'Save Fuel Log',
      'fuel_log_added': 'Fuel log added',
      'future_date_error': 'Cannot select a future date',
      'already_fueled_in_quota': 'Already fueled in this quota',
      'already_fueled_in_quota_message':
          'You have already recorded a fueling for this vehicle in the current quota. Wait for the next quota to add a new entry.',
      'next_quota_info': 'Next quota starts:',

      // Delete vehicle
      'delete_vehicle': 'Delete Vehicle',
      'delete_vehicle_confirm':
          'Are you sure you want to delete "{{name}}"? This will also delete all fuel logs for this vehicle.',
      'vehicle_deleted': 'deleted',

      // Navigation
      'home': 'Home',
      'maps': 'Maps',
      'notifications': 'Notifications',
      'settings': 'Settings',
      'maps_coming_soon': 'Fuel stations map coming soon',

      // Fuel stations map
      'loading_fuel_stations': 'Loading fuel stations...',
      'error_loading_stations': 'Error loading fuel stations',
      'no_fuel_stations': 'No fuel stations in this area',
      'open_in_maps': 'Open in Maps',
      'open_in_waze': 'Open in Waze',
      'navigate_to_station': 'Navigate to station',

      // Settings page
      'app_description': 'Track fuel quotas in Kirkuk',
      'version': 'Version',
      'updates': 'Updates',
      'check_for_updates': 'Check for Updates',
      'update_available': 'Update Available',
      'check_for_new_version': 'Check for a new version',
      'app_up_to_date': 'App is up to date',
      'update_check_failed': 'Failed to check for updates',
      'new_version': 'New Version',
      'current_version': 'Current Version',
      'whats_new': 'What\'s New',
      'later': 'Later',
      'download_update': 'Download Update',
      'update_required': 'Update Required',
      'update_required_message': 'Please update the app to continue using it',
      'latest_version': 'Latest Version',
      'support': 'Support',
      'contact_support': 'Contact Us',
      'cannot_open_email': 'Cannot open email app',
      'legal': 'Legal',
      'privacy_policy': 'Privacy Policy',
      'privacy_policy_subtitle': 'How we protect your data',
      'developed_by_historea': 'Developed by Historea ❤️',
      'last_updated': 'Last updated: December 2025',
      'contact_us': 'Contact Us',
      'privacy_contact_message':
          'If you have any questions about the privacy policy, feel free to contact us at historea@proton.me',

      // Notifications
      'your_vehicle': 'Your vehicle',
      'notification_quota_open': 'Quota Open!',
      'notification_quota_open_body':
          '{{name}}\'s fuel quota is now open. Time to refuel!',
      'notification_quota_open_now': 'Quota Open Now!',
      'notification_quota_open_now_body':
          '{{name}}\'s fuel quota is currently open!',
      'notification_quota_ending': 'Quota Ending Soon!',
      'notification_quota_ending_body':
          '{{name}}\'s fuel quota closes in 6 hours. Don\'t miss it!',

      // Notifications Page
      'notifications_page_title': 'Notifications',
      'mark_all_read': 'Mark all as read',
      'clear_all': 'Clear all',
      'no_notifications': 'No notifications yet',
      'clear_all_notifications': 'Clear all notifications?',
      'clear_all_notifications_confirm':
          'Are you sure you want to delete all notifications?',
      'clear': 'Clear',

      // Reports
      'reports': 'Reports',
      'reports_subtitle': 'Report station problems',
      'reports_disabled': 'Reports Unavailable',
      'reports_disabled_message':
          'The reports system is temporarily disabled, please try again later',
      'report_problem': 'Report a Problem',
      'report_description': 'Help us improve by reporting fuel station issues',
      'report_type': 'Report Type',
      'report_details': 'Report Details',
      'station_name': 'Station Name',
      'station_name_hint': 'e.g., Al-Karama Station',
      'location': 'Location',
      'location_hint': 'e.g., Atlas Street, Kirkuk',
      'additional_details': 'Additional Details',
      'additional_details_hint': 'Write any additional information...',
      'station_closed': 'Station Closed',
      'station_crowded': 'Very Crowded',
      'out_of_fuel': 'Out of Fuel',
      'price_issue': 'Price Issue',
      'other_issue': 'Other',
      'send_report': 'Send Report',
      'sending': 'Sending...',
      'report_note':
          'The report will be reviewed and handled as soon as possible',
      'please_fill_details': 'Please fill in some details',
      'fuel_report': 'Fuel Report',
      'sent_from_app': 'Sent from Ki Fuel app',
      'report_opened_in_email': 'Report opened in email app',
      'report_sent_successfully': 'Report sent successfully ✓',
      'error_sending_report': 'Error sending report',
      'no_internet_connection': 'No internet connection',
      'permission_denied_error': 'You don\'t have permission to send report',
      'network_error': 'Network error, please try again later',
      'timeout_error': 'Connection timed out, please try again',
      'report_will_send_when_online': 'Report will be sent when back online',
      'report_pending_offline': 'Report pending - will send when online',

      // Language
      'language': 'Language',
      'language_subtitle': 'Change app language',
      'arabic': 'العربية',
      'english': 'English',
      'select_language': 'Select Language',

      // Appearance
      'appearance': 'Appearance',
      'dark_mode': 'Dark Mode',
      'dark_mode_on': 'Enabled',
      'dark_mode_off': 'Disabled',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  String translateWithArgs(String key, Map<String, String> args) {
    String text = translate(key);
    args.forEach((argKey, value) {
      text = text.replaceAll('{{$argKey}}', value);
    });
    return text;
  }

  // Getters للوصول السريع
  String get appTitle => translate('app_title');
  String get refresh => translate('refresh');
  String get cancel => translate('cancel');
  String get delete => translate('delete');
  String get edit => translate('edit');
  String get save => translate('save');
  String get add => translate('add');
  String get retry => translate('retry');
  String get optional => translate('optional');
  String get required => translate('required');

  String get noVehiclesYet => translate('no_vehicles_yet');
  String get addFirstVehicleHint => translate('add_first_vehicle_hint');
  String get addFirstVehicle => translate('add_first_vehicle');
  String get addVehicle => translate('add_vehicle');
  String get errorLoadingVehicles => translate('error_loading_vehicles');

  String get editVehicle => translate('edit_vehicle');
  String get vehicleName => translate('vehicle_name');
  String get vehicleNameHint => translate('vehicle_name_hint');
  String get leaveEmptyAutoName => translate('leave_empty_auto_name');
  String get quotaSystemInfo => translate('quota_system_info');
  String get appSubtitle => translate('app_subtitle');
  String get quotaRepeatsEvery5Days => translate('quota_repeats_every_5_days');
  String get currentQuota => translate('current_quota');
  String get currentlyOpen => translate('currently_open');
  String get currentlyClosed => translate('currently_closed');
  String get quotaAutoMessage => translate('quota_auto_message');
  String get saveChanges => translate('save_changes');
  String get vehicleAdded => translate('vehicle_added');
  String get vehicleUpdated => translate('vehicle_updated');

  String get quotaNumber => translate('quota_number');
  String get endsIn => translate('ends_in');
  String get opensIn => translate('opens_in');
  String get open => translate('open');
  String get closed => translate('closed');

  String get quotaTimeline => translate('quota_timeline');
  String get fuelLogs => translate('fuel_logs');
  String get entries => translate('entries');
  String get addFuelLog => translate('add_fuel_log');
  String get quotaIsOpen => translate('quota_is_open');
  String get quotaIsClosed => translate('quota_is_closed');
  String get start => translate('start');
  String get end => translate('end');
  String get now => translate('now');
  String get current => translate('current');
  String get past => translate('past');
  String get upcoming => translate('upcoming');

  String get noFuelLogsYet => translate('no_fuel_logs_yet');
  String get tapToAddFirstEntry => translate('tap_to_add_first_entry');
  String get fuelLogDeleted => translate('fuel_log_deleted');
  String get recordFuelRefill => translate('record_fuel_refill');
  String get dateTime => translate('date_time');
  String get whenRefuel => translate('when_refuel');
  String get date => translate('date');
  String get time => translate('time');
  String get notes => translate('notes');
  String get notesHint => translate('notes_hint');
  String get notesHelper => translate('notes_helper');
  String get addEntry => translate('add_entry');
  String get fuelLogAdded => translate('fuel_log_added');

  String get deleteVehicle => translate('delete_vehicle');
  String deleteVehicleConfirm(String name) =>
      translateWithArgs('delete_vehicle_confirm', {'name': name});
  String get vehicleDeleted => translate('vehicle_deleted');

  String get day => translate('day');
  String get days => translate('days');
  String get hour => translate('hour');
  String get hours => translate('hours');
  String get minute => translate('minute');
  String get minutes => translate('minutes');
  String get ended => translate('ended');

  // تنسيق المدة
  String formatDuration(Duration duration) {
    if (duration.isNegative) {
      return ended;
    }

    final d = duration.inDays;
    final h = duration.inHours.remainder(24);
    final m = duration.inMinutes.remainder(60);

    if (locale.languageCode == 'ar') {
      if (d > 0) {
        return '$d ${d == 1 ? day : days}، $h ${h == 1 ? hour : hours}';
      } else if (h > 0) {
        return '$h ${h == 1 ? hour : hours}، $m ${m == 1 ? minute : minutes}';
      } else {
        return '$m ${m == 1 ? minute : minutes}';
      }
    } else {
      if (d > 0) {
        return '${d}d ${h}h';
      } else if (h > 0) {
        return '${h}h ${m}m';
      } else {
        return '${m}m';
      }
    }
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['ar', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
