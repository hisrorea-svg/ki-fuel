import 'package:hive/hive.dart';

part 'notification_model.g.dart';

@HiveType(typeId: 2) // Using ID 2 (Vehicle is 0, FuelLog is 1)
class NotificationModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String body;

  @HiveField(3)
  final DateTime timestamp;

  @HiveField(4)
  bool isRead;

  @HiveField(5)
  final String? vehicleId;

  @HiveField(6)
  final String type; // 'quota_start', 'quota_end', 'fuel_log', 'system'

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
    this.vehicleId,
    this.type = 'system',
  });
}
