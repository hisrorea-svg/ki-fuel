import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'vehicle.g.dart';

/// أنواع السيارات المتاحة
enum VehicleType {
  private, // خصوصي
  public, // عمومي
  taxi, // تكسي
}

/// إضافة للحصول على أيقونة ولون كل نوع
extension VehicleTypeExtension on VehicleType {
  IconData get icon {
    switch (this) {
      case VehicleType.private:
        return Icons.directions_car;
      case VehicleType.public:
        return Icons.directions_bus;
      case VehicleType.taxi:
        return Icons.local_taxi;
    }
  }

  Color get color {
    switch (this) {
      case VehicleType.private:
        return const Color(0xFF1565C0); // أزرق
      case VehicleType.public:
        return const Color(0xFF2E7D32); // أخضر
      case VehicleType.taxi:
        return const Color(0xFFF9A825); // أصفر
    }
  }

  String getLocalizedName(String languageCode) {
    if (languageCode == 'ar') {
      switch (this) {
        case VehicleType.private:
          return 'خصوصي';
        case VehicleType.public:
          return 'عمومي';
        case VehicleType.taxi:
          return 'تكسي';
      }
    } else {
      switch (this) {
        case VehicleType.private:
          return 'Private';
        case VehicleType.public:
          return 'Public';
        case VehicleType.taxi:
          return 'Taxi';
      }
    }
  }
}

/// Vehicle model representing a car with fuel quota tracking
@HiveType(typeId: 0)
class Vehicle extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String? name;

  @HiveField(2)
  final DateTime firstQuotaStart;

  @HiveField(3)
  final int quotaLengthDays;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final DateTime updatedAt;

  @HiveField(6, defaultValue: 0)
  final int vehicleTypeIndex;

  Vehicle({
    required this.id,
    this.name,
    required this.firstQuotaStart,
    this.quotaLengthDays = 5,
    required this.createdAt,
    required this.updatedAt,
    this.vehicleTypeIndex = 0,
  });

  /// الحصول على نوع السيارة
  VehicleType get vehicleType => VehicleType.values[vehicleTypeIndex];

  /// Create a new vehicle with auto-generated ID
  /// Note: firstQuotaStart and quotaLengthDays are kept for backward compatibility
  /// but the app now uses KirkukQuotaSystem for all quota calculations
  factory Vehicle.create({
    String? name,
    VehicleType type = VehicleType.private,
  }) {
    final now = DateTime.now();
    return Vehicle(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      // Default values for backward compatibility with existing database
      firstQuotaStart: DateTime(2025, 12, 1, 0, 0, 0),
      quotaLengthDays: 5,
      createdAt: now,
      updatedAt: now,
      vehicleTypeIndex: type.index,
    );
  }

  /// Get display name (auto-generated if null)
  String getDisplayName(int index) {
    return name?.isNotEmpty == true ? name! : 'My Car ${index + 1}';
  }

  /// Create a copy with updated fields
  Vehicle copyWith({
    String? id,
    String? name,
    DateTime? firstQuotaStart,
    int? quotaLengthDays,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? vehicleTypeIndex,
  }) {
    return Vehicle(
      id: id ?? this.id,
      name: name ?? this.name,
      firstQuotaStart: firstQuotaStart ?? this.firstQuotaStart,
      quotaLengthDays: quotaLengthDays ?? this.quotaLengthDays,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      vehicleTypeIndex: vehicleTypeIndex ?? this.vehicleTypeIndex,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'firstQuotaStart': firstQuotaStart.toIso8601String(),
      'quotaLengthDays': quotaLengthDays,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'vehicleTypeIndex': vehicleTypeIndex,
    };
  }

  /// Create from JSON map
  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] as String,
      name: json['name'] as String?,
      firstQuotaStart: DateTime.parse(json['firstQuotaStart'] as String),
      quotaLengthDays: json['quotaLengthDays'] as int? ?? 5,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      vehicleTypeIndex: json['vehicleTypeIndex'] as int? ?? 0,
    );
  }

  @override
  String toString() {
    return 'Vehicle(id: $id, name: $name, type: $vehicleType)';
  }
}
