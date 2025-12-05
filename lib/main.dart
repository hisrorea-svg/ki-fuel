import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'core/localization/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'features/notifications/data/models/notification_model.dart';
import 'features/notifications/data/repositories/notification_repository.dart';
import 'features/notifications/logic/notifications_controller.dart';
import 'features/notifications/notification_service.dart';
import 'features/splash/presentation/pages/splash_page.dart';
import 'features/vehicles/data/repositories/vehicle_repository.dart';
import 'features/vehicles/logic/vehicle_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(NotificationModelAdapter());
  }

  // Initialize Repositories
  final repository = VehicleRepository();
  await repository.initialize();

  final notificationRepository = NotificationRepository();
  await notificationRepository.initialize();

  // Initialize Local Notifications Service
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Create Controllers
  final notificationsController = NotificationsController(
    repository: notificationRepository,
  );
  // Load saved notifications
  await notificationsController.loadNotifications();

  final vehicleController = VehicleController(
    repository: repository,
    notificationService: notificationService,
    notificationsController: notificationsController,
  );
  // Load initial data
  await vehicleController.loadVehicles();

  runApp(
    MultiProvider(
      providers: [
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
    return MaterialApp(
      title: 'Ki Fuel',
      debugShowCheckedModeBanner: false,

      // إعدادات اللغة العربية
      locale: const Locale('ar'),
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
  }
}
