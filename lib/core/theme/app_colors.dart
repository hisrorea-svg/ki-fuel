import 'package:flutter/material.dart';

/// الألوان المركزية للتطبيق
/// استخدم هذه الألوان في كل مكان لتسهيل التعديل لاحقاً
class AppColors {
  AppColors._();

  /// اللون الأساسي للتنقل والأزرار الرئيسية
  static const Color primary = Color(0xFF00897B);

  /// اللون الأساسي الفاتح
  static const Color primaryLight = Color(0xFF4DB6AC);

  /// اللون الأساسي الداكن
  static const Color primaryDark = Color(0xFF00695C);

  /// لون النجاح
  static const Color success = Color(0xFF4CAF50);

  /// لون التحذير
  static const Color warning = Color(0xFFFF9800);

  /// لون الخطأ
  static const Color error = Color(0xFFE53935);

  /// لون المعلومات
  static const Color info = Color(0xFF2196F3);

  /// لون الخلفية الفاتح
  static const Color backgroundLight = Color(0xFFF5F5F5);

  /// لون الخلفية الداكن
  static const Color backgroundDark = Color(0xFF121212);

  /// لون محطات الوقود على الخريطة
  static const Color fuelStation = Color(0xFF4CAF50);

  /// لون موقع المستخدم على الخريطة
  static const Color userLocation = Color(0xFF2196F3);
}
