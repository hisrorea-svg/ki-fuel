import 'dart:async';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../localization/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../connectivity_service.dart';
import '../remote_config_service.dart';

/// Widget للتحقق من Remote Config (صيانة، تحديث، إعلانات)
class RemoteConfigChecker extends StatefulWidget {
  final Widget child;

  const RemoteConfigChecker({super.key, required this.child});

  @override
  State<RemoteConfigChecker> createState() => _RemoteConfigCheckerState();
}

class _RemoteConfigCheckerState extends State<RemoteConfigChecker> {
  final _remoteConfig = RemoteConfigService();
  final _connectivity = ConnectivityService();

  bool _isChecking = true;
  bool _showMaintenance = false;
  bool _showForceUpdate = false;
  bool _announcementDismissed = false;
  bool _isOffline = false;

  StreamSubscription<bool>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _checkRemoteConfig();
    _listenToConnectivity();

    // Timeout safety - فتح التطبيق بعد 5 ثواني بأي حال
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _isChecking) {
        debugPrint('RemoteConfigChecker: Timeout - opening app anyway');
        setState(() => _isChecking = false);
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  /// الاستماع لتغييرات الاتصال
  void _listenToConnectivity() {
    _connectivitySubscription = _connectivity.connectionStream.listen((
      isConnected,
    ) {
      if (isConnected && _isOffline) {
        // عاد الاتصال - إعادة المحاولة
        setState(() => _isOffline = false);
        _checkRemoteConfig();
      }
    });
  }

  Future<void> _checkRemoteConfig() async {
    try {
      // التحقق من الاتصال أولاً
      final isConnected = await _connectivity.checkConnectivity();
      if (!isConnected) {
        // بدون إنترنت - نفتح التطبيق عادي مع القيم الافتراضية
        if (mounted) {
          setState(() {
            _isOffline = true;
            _isChecking = false;
          });
        }
        return;
      }

      // هناك اتصال - نجلب الإعدادات
      if (mounted) setState(() => _isOffline = false);

      await _remoteConfig.fetch();

      if (!mounted) return;

      // التحقق من وضع الصيانة
      if (_remoteConfig.isMaintenanceMode) {
        setState(() {
          _showMaintenance = true;
          _isChecking = false;
        });
        return;
      }

      // التحقق من التحديث الإجباري
      if (_remoteConfig.forceUpdate) {
        final packageInfo = await PackageInfo.fromPlatform();
        final currentVersion = packageInfo.version;
        final minVersion = _remoteConfig.minAppVersion;

        if (_isVersionLower(currentVersion, minVersion)) {
          setState(() {
            _showForceUpdate = true;
            _isChecking = false;
          });
          return;
        }
      }

      if (mounted) setState(() => _isChecking = false);
    } catch (e) {
      // في حالة أي خطأ - نفتح التطبيق عادي
      debugPrint('RemoteConfigChecker error: $e');
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  bool _isVersionLower(String current, String minimum) {
    final currentParts = current.split('.').map(int.parse).toList();
    final minParts = minimum.split('.').map(int.parse).toList();

    for (int i = 0; i < minParts.length; i++) {
      if (i >= currentParts.length) return true;
      if (currentParts[i] < minParts[i]) return true;
      if (currentParts[i] > minParts[i]) return false;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // شاشة الصيانة (فقط إذا هناك إنترنت وتم تفعيل الصيانة)
    if (_showMaintenance) {
      return _MaintenanceScreen(message: _remoteConfig.maintenanceMessage);
    }

    // شاشة التحديث الإجباري (فقط إذا هناك إنترنت)
    if (_showForceUpdate) {
      return _ForceUpdateScreen(latestVersion: _remoteConfig.latestAppVersion);
    }

    // عرض التطبيق مع شريط إعلان إذا كان مفعلاً
    return Stack(
      children: [
        widget.child,
        if (_remoteConfig.showAnnouncement &&
            _remoteConfig.announcementMessage.isNotEmpty &&
            !_announcementDismissed)
          _AnnouncementBanner(
            message: _remoteConfig.announcementMessage,
            onDismiss: () => setState(() => _announcementDismissed = true),
          ),
      ],
    );
  }
}

/// شاشة الصيانة
class _MaintenanceScreen extends StatelessWidget {
  final String message;

  const _MaintenanceScreen({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.construction_rounded,
                  size: 80,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'التطبيق تحت الصيانة',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}

/// شاشة التحديث الإجباري
class _ForceUpdateScreen extends StatelessWidget {
  final String latestVersion;

  const _ForceUpdateScreen({required this.latestVersion});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.system_update_rounded,
                  size: 80,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                l10n.translate('update_required'),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.translate('update_required_message'),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '${l10n.translate('latest_version')}: $latestVersion',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: () => _openStore(),
                  icon: const Icon(Icons.download_rounded),
                  label: Text(l10n.translate('download_update')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openStore() async {
    // رابط المتجر أو GitHub releases
    const url = 'https://github.com/hisrorea-svg/ki-fuel/releases';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }
}

/// بانر الإعلان
class _AnnouncementBanner extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;

  const _AnnouncementBanner({required this.message, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 16,
      right: 16,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primary.withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.campaign_rounded, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              IconButton(
                onPressed: onDismiss,
                icon: const Icon(Icons.close, color: Colors.white),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
