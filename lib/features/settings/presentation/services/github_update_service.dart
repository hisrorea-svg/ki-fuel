import 'dart:convert';
import 'package:http/http.dart' as http;

/// معلومات التحديث
class UpdateInfo {
  final bool hasUpdate;
  final String? latestVersion;
  final String? downloadUrl;
  final String? releaseNotes;

  UpdateInfo({
    required this.hasUpdate,
    this.latestVersion,
    this.downloadUrl,
    this.releaseNotes,
  });
}

/// خدمة التحقق من التحديثات عبر GitHub
class GitHubUpdateService {
  // رابط المستودع: https://github.com/hisrorea-svg/ki-fuel
  static const String _owner = 'hisrorea-svg';
  static const String _repo = 'ki-fuel';

  /// التحقق من وجود تحديث جديد
  static Future<UpdateInfo> checkForUpdate({
    required String currentVersion,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse(
              'https://api.github.com/repos/$_owner/$_repo/releases/latest',
            ),
            headers: {'Accept': 'application/vnd.github.v3+json'},
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        final latestVersion =
            (data['tag_name'] as String?)?.replaceAll('v', '') ?? '';
        final releaseNotes = data['body'] as String?;

        // البحث عن رابط APK في الـ assets
        String? downloadUrl;
        final assets = data['assets'] as List<dynamic>?;
        if (assets != null && assets.isNotEmpty) {
          for (final asset in assets) {
            final name = (asset['name'] as String?)?.toLowerCase() ?? '';
            if (name.endsWith('.apk')) {
              downloadUrl = asset['browser_download_url'] as String?;
              break;
            }
          }
        }

        // إذا لم يوجد APK، استخدم صفحة الإصدار
        downloadUrl ??= data['html_url'] as String?;

        final hasUpdate = _isNewerVersion(latestVersion, currentVersion);

        return UpdateInfo(
          hasUpdate: hasUpdate,
          latestVersion: latestVersion,
          downloadUrl: downloadUrl,
          releaseNotes: releaseNotes,
        );
      } else if (response.statusCode == 404) {
        // لا يوجد إصدارات بعد
        return UpdateInfo(hasUpdate: false);
      } else {
        throw Exception('فشل في جلب معلومات التحديث');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// مقارنة الإصدارات (1.0.0 < 1.0.1)
  static bool _isNewerVersion(String latest, String current) {
    try {
      final latestParts = latest.split('.').map(int.parse).toList();
      final currentParts = current.split('.').map(int.parse).toList();

      // التأكد من أن كلاهما لهما نفس الطول
      while (latestParts.length < 3) {
        latestParts.add(0);
      }
      while (currentParts.length < 3) {
        currentParts.add(0);
      }

      for (int i = 0; i < 3; i++) {
        if (latestParts[i] > currentParts[i]) return true;
        if (latestParts[i] < currentParts[i]) return false;
      }

      return false; // نفس الإصدار
    } catch (e) {
      return false;
    }
  }
}
