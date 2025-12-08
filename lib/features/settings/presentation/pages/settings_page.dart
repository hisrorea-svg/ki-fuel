import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../reports/presentation/pages/reports_page.dart';
import '../services/github_update_service.dart';
import 'privacy_policy_page.dart';

/// صفحة الإعدادات وحول التطبيق
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  PackageInfo? _packageInfo;
  bool _checkingUpdate = false;
  UpdateInfo? _updateInfo;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() => _packageInfo = info);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('settings')),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // معلومات التطبيق
          _AppInfoCard(packageInfo: _packageInfo),

          const SizedBox(height: 16),

          // التحقق من التحديثات
          _SettingsCard(
            title: l10n.translate('updates'),
            children: [
              _SettingsTile(
                icon: Icons.system_update,
                iconColor: Colors.blue,
                title: l10n.translate('check_for_updates'),
                subtitle: _updateInfo != null && _updateInfo!.hasUpdate
                    ? l10n.translate('update_available')
                    : l10n.translate('check_for_new_version'),
                trailing: _checkingUpdate
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : _updateInfo != null && _updateInfo!.hasUpdate
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _updateInfo!.latestVersion ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      )
                    : const Icon(Icons.chevron_left),
                onTap: _checkForUpdates,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // اللغة
          _SettingsCard(
            title: l10n.translate('language'),
            children: [
              Consumer<LocaleProvider>(
                builder: (context, localeProvider, _) => _SettingsTile(
                  icon: Icons.language_rounded,
                  iconColor: Colors.purple,
                  title: l10n.translate('language'),
                  subtitle: localeProvider.isArabic
                      ? l10n.translate('arabic')
                      : l10n.translate('english'),
                  trailing: const Icon(Icons.chevron_left),
                  onTap: () => _showLanguageDialog(context),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // المظهر
          _SettingsCard(
            title: l10n.translate('appearance'),
            children: [
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, _) => _SettingsTile(
                  icon: themeProvider.isDarkMode
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                  iconColor: themeProvider.isDarkMode
                      ? Colors.indigo
                      : Colors.amber,
                  title: l10n.translate('dark_mode'),
                  subtitle: themeProvider.isDarkMode
                      ? l10n.translate('dark_mode_on')
                      : l10n.translate('dark_mode_off'),
                  trailing: Switch(
                    value: themeProvider.isDarkMode,
                    onChanged: (value) {
                      HapticFeedback.lightImpact();
                      themeProvider.setDarkMode(value);
                    },
                  ),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    themeProvider.toggleTheme();
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          _SettingsCard(
            title: l10n.translate('reports'),
            children: [
              _SettingsTile(
                icon: Icons.campaign_rounded,
                iconColor: Colors.orange,
                title: l10n.translate('reports'),
                subtitle: l10n.translate('reports_subtitle'),
                trailing: const Icon(Icons.chevron_left),
                onTap: () => _openReportsPage(context),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // الدعم
          _SettingsCard(
            title: l10n.translate('support'),
            children: [
              _SettingsTile(
                icon: Icons.email_rounded,
                iconColor: Colors.blue,
                title: l10n.translate('contact_support'),
                subtitle: 'historea@proton.me',
                onTap: _contactSupport,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // القانونية
          _SettingsCard(
            title: l10n.translate('legal'),
            children: [
              _SettingsTile(
                icon: Icons.privacy_tip_rounded,
                iconColor: AppColors.primary,
                title: l10n.translate('privacy_policy'),
                subtitle: l10n.translate('privacy_policy_subtitle'),
                onTap: () => _openPrivacyPolicy(context),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // حقوق النشر
          Center(
            child: Text(
              '© 2025 Historea',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),

          const SizedBox(height: 8),

          Center(
            child: Text(
              l10n.translate('developed_by_historea'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _checkForUpdates() async {
    HapticFeedback.lightImpact();

    setState(() => _checkingUpdate = true);

    try {
      final updateInfo = await GitHubUpdateService.checkForUpdate(
        currentVersion: _packageInfo?.version ?? '1.0.0',
      );

      setState(() {
        _updateInfo = updateInfo;
        _checkingUpdate = false;
      });

      if (!mounted) return;

      if (updateInfo.hasUpdate) {
        _showUpdateDialog(updateInfo);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).translate('app_up_to_date'),
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _checkingUpdate = false);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).translate('update_check_failed'),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _showUpdateDialog(UpdateInfo updateInfo) {
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.system_update, color: Colors.green),
            const SizedBox(width: 8),
            Text(l10n.translate('update_available')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${l10n.translate('new_version')}: ${updateInfo.latestVersion}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${l10n.translate('current_version')}: ${_packageInfo?.version}',
            ),
            if (updateInfo.releaseNotes != null) ...[
              const SizedBox(height: 16),
              Text(
                l10n.translate('whats_new'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                updateInfo.releaseNotes!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.translate('later')),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              if (updateInfo.downloadUrl != null) {
                launchUrl(
                  Uri.parse(updateInfo.downloadUrl!),
                  mode: LaunchMode.externalApplication,
                );
              }
            },
            child: Text(l10n.translate('download_update')),
          ),
        ],
      ),
    );
  }

  Future<void> _contactSupport() async {
    HapticFeedback.lightImpact();

    final emailUri = Uri(
      scheme: 'mailto',
      path: 'historea@proton.me',
      query: 'subject=دعم تطبيق حصة وقود كركوك',
    );

    try {
      await launchUrl(emailUri);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).translate('cannot_open_email'),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _openPrivacyPolicy(BuildContext context) {
    HapticFeedback.lightImpact();

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()),
    );
  }

  void _openReportsPage(BuildContext context) {
    HapticFeedback.lightImpact();

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ReportsPage()),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    HapticFeedback.lightImpact();
    final l10n = AppLocalizations.of(context);
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.translate('select_language')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Text('🇮🇶', style: TextStyle(fontSize: 24)),
              title: Text(l10n.translate('arabic')),
              trailing: localeProvider.isArabic
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                localeProvider.setLocale(const Locale('ar'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Text('🇺🇸', style: TextStyle(fontSize: 24)),
              title: Text(l10n.translate('english')),
              trailing: !localeProvider.isArabic
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                localeProvider.setLocale(const Locale('en'));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// بطاقة معلومات التطبيق
class _AppInfoCard extends StatelessWidget {
  final PackageInfo? packageInfo;

  const _AppInfoCard({this.packageInfo});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // أيقونة التطبيق
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primary],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.local_gas_station_rounded,
                size: 48,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 16),

            // اسم التطبيق
            Text(
              l10n.translate('app_title'),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            // الوصف
            Text(
              l10n.translate('app_description'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // رقم الإصدار
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${l10n.translate('version')} ${packageInfo?.version ?? '...'}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// بطاقة إعدادات
class _SettingsCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 4, bottom: 8),
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(children: children),
        ),
      ],
    );
  }
}

/// عنصر إعداد
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_left),
      onTap: onTap,
    );
  }
}
