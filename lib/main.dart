import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'core/localization/app_localizations.dart';
import 'core/localization/locale_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/crashlytics_service.dart';
import 'core/services/firebase_messaging_service.dart';
import 'core/services/remote_config_service.dart';
import 'features/notifications/data/models/notification_model.dart';
import 'features/notifications/data/repositories/notification_repository.dart';
import 'features/notifications/logic/notifications_controller.dart';
import 'features/notifications/notification_service.dart';
import 'features/splash/presentation/pages/splash_page.dart';
import 'features/vehicles/data/repositories/vehicle_repository.dart';
import 'features/vehicles/logic/vehicle_controller.dart';

/// Handler for background messages (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Crashlytics (يجب أن يكون بعد Firebase مباشرة)
  try {
    final crashlytics = CrashlyticsService();
    await crashlytics.initialize();
  } catch (e) {
    debugPrint('Crashlytics init error: $e');
  }

  // Initialize Remote Config (Background)
  _initializeRemoteConfig();

  // Initialize Connectivity Service (Background)
  _initializeConnectivity();

  // Setup Firebase Messaging
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize Hive
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(NotificationModelAdapter());
  }

  // Initialize Locale Provider
  final localeProvider = LocaleProvider();
  await localeProvider.initialize();

  // Initialize Repositories
  final repository = VehicleRepository();
  await repository.initialize();

  final notificationRepository = NotificationRepository();
  await notificationRepository.initialize();

  // Initialize Local Notifications Service
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Initialize Firebase Cloud Messaging (Background)
  _initializeFCM();

  // Create Controllers
  final notificationsController = NotificationsController(
    repository: notificationRepository,
  );
  // Load saved notifications (Background)
  notificationsController.loadNotifications();

  final vehicleController = VehicleController(
    repository: repository,
    notificationService: notificationService,
    notificationsController: notificationsController,
  );
  // Load initial data (Background)
  vehicleController.loadVehicles();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: localeProvider),
        ChangeNotifierProvider.value(value: vehicleController),
        ChangeNotifierProvider.value(value: notificationsController),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return MaterialApp(
          title: 'Ki Fuel',
          debugShowCheckedModeBanner: false,

          // إعدادات اللغة
          locale: localeProvider.locale,
          supportedLocales: const [Locale('ar'), Locale('en')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          // الثيم
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,

          home: const SplashPage(),
        );
      },
    );
  }
}

Future<void> _initializeRemoteConfig() async {
  try {
    final remoteConfig = RemoteConfigService();
    await remoteConfig.initialize();
  } catch (e) {
    debugPrint('RemoteConfig init error: $e');
  }
}

Future<void> _initializeConnectivity() async {
  try {
    final connectivityService = ConnectivityService();
    await connectivityService.initialize();
  } catch (e) {
    debugPrint('Connectivity init error: $e');
  }
}

Future<void> _initializeFCM() async {
  try {
    final firebaseMessaging = FirebaseMessagingService();
    await firebaseMessaging.initialize();
    // Subscribe to general topic for all users
    await firebaseMessaging.subscribeToTopic('all_users');
  } catch (e) {
    debugPrint('FCM init error: $e');
  }
}
