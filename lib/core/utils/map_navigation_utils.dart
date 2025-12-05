import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> openInMapsOrWaze({
  required double lat,
  required double lon,
  required String name,
  BuildContext? context,
}) async {
  final wazeUrl = Uri.parse('waze://?ll=$lat,$lon&navigate=yes');
  final googleMapsUrl = Uri.parse(
    'https://www.google.com/maps/dir/?api=1&destination=$lat,$lon&travelmode=driving',
  );

  // جرّب Waze أولاً
  if (await canLaunchUrl(wazeUrl)) {
    await launchUrl(wazeUrl, mode: LaunchMode.externalApplication);
    return;
  }

  // بعدها Google Maps
  if (await canLaunchUrl(googleMapsUrl)) {
    await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    return;
  }

  // لو ماكو ولا واحد، عرض رسالة للمستخدم
  if (context != null && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'لا يوجد تطبيق خرائط متاح. يرجى تثبيت Google Maps أو Waze',
        ),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
      ),
    );
  }
}
