import 'package:hive/hive.dart';

part 'fuel_log_entry.g.dart';

/// Lightweight fuel log entry - just tracks when fuel was obtained
@HiveType(typeId: 1)
class FuelLogEntry extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String vehicleId;

  @HiveField(2)
  final DateTime dateTime;

  @HiveField(3)
  final String? note;

  FuelLogEntry({
    required this.id,
    required this.vehicleId,
    required this.dateTime,
    this.note,
  });

  /// Create a new fuel log entry with auto-generated ID
  factory FuelLogEntry.create({
    required String vehicleId,
    DateTime? dateTime,
    String? note,
  }) {
    return FuelLogEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      vehicleId: vehicleId,
      dateTime: dateTime ?? DateTime.now(),
      note: note?.isNotEmpty == true ? note : null,
    );
  }

  /// Create a copy with updated fields
  FuelLogEntry copyWith({
    String? id,
    String? vehicleId,
    DateTime? dateTime,
    String? note,
  }) {
    return FuelLogEntry(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      dateTime: dateTime ?? this.dateTime,
      note: note ?? this.note,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'dateTime': dateTime.toIso8601String(),
      'note': note,
    };
  }

  /// Create from JSON map
  factory FuelLogEntry.fromJson(Map<String, dynamic> json) {
    return FuelLogEntry(
      id: json['id'] as String,
      vehicleId: json['vehicleId'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      note: json['note'] as String?,
    );
  }

  @override
  String toString() {
    return 'FuelLogEntry(id: $id, vehicleId: $vehicleId, dateTime: $dateTime, note: $note)';
  }
}
