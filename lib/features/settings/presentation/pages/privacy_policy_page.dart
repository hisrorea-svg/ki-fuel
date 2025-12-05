import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';

/// صفحة سياسة الخصوصية
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isArabic = l10n.locale.languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('privacy_policy')),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // الهيدر
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.privacy_tip_rounded,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                l10n.translate('privacy_policy'),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Center(
              child: Text(
                l10n.translate('last_updated'),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // المحتوى
            if (isArabic)
              ..._buildArabicContent(theme)
            else
              ..._buildEnglishContent(theme),

            const SizedBox(height: 32),

            // التواصل
            Card(
              color: theme.colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.email_outlined,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.translate('contact_us'),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.translate('privacy_contact_message'),
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      'historea@proton.me',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // فريق التطوير
            Center(
              child: Text(
                '© 2025 Historea',
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

  List<Widget> _buildArabicContent(ThemeData theme) {
    return [
      _PolicySection(
        theme: theme,
        title: 'مقدمة',
        content:
            'مرحباً بك في تطبيق "حصة وقود كركوك". نحن نحترم خصوصيتك ونلتزم بحماية بياناتك الشخصية. توضح سياسة الخصوصية هذه كيفية جمع واستخدام وحماية معلوماتك.',
      ),
      _PolicySection(
        theme: theme,
        title: 'البيانات التي نجمعها',
        content: '''• معلومات السيارات: الأسماء والأنواع التي تدخلها
• سجلات التزود بالوقود: التواريخ والملاحظات
• بيانات الموقع: فقط عند استخدام خاصية الخرائط (بإذنك)

ملاحظة: جميع هذه البيانات تُخزن محلياً على جهازك فقط ولا تُرسل إلى أي خادم خارجي.''',
      ),
      _PolicySection(
        theme: theme,
        title: 'كيف نستخدم بياناتك',
        content: '''• لتتبع حصص الوقود الخاصة بسياراتك
• لعرض محطات الوقود القريبة على الخريطة
• لإرسال إشعارات تذكير بمواعيد الحصص
• لتحسين تجربة المستخدم''',
      ),
      _PolicySection(
        theme: theme,
        title: 'تخزين البيانات',
        content:
            'جميع بياناتك تُخزن محلياً على جهازك باستخدام تقنية Hive. لا نقوم بإرسال أي بيانات شخصية إلى خوادم خارجية. يمكنك حذف جميع بياناتك في أي وقت عن طريق إلغاء تثبيت التطبيق.',
      ),
      _PolicySection(
        theme: theme,
        title: 'الأذونات المطلوبة',
        content: '''• الموقع: لعرض موقعك على خريطة المحطات (اختياري)
• الإشعارات: لتذكيرك بمواعيد الحصص (اختياري)
• الإنترنت: لتحميل بيانات محطات الوقود من OpenStreetMap''',
      ),
      _PolicySection(
        theme: theme,
        title: 'خدمات الطرف الثالث',
        content: '''• OpenStreetMap: لعرض الخرائط ومواقع المحطات
• Overpass API: لجلب بيانات محطات الوقود

هذه الخدمات لها سياسات خصوصية خاصة بها.''',
      ),
      _PolicySection(
        theme: theme,
        title: 'حقوقك',
        content: '''• الوصول إلى بياناتك المخزنة
• تعديل أو حذف بياناتك في أي وقت
• إلغاء الأذونات من إعدادات الجهاز
• إلغاء تثبيت التطبيق لحذف جميع البيانات''',
      ),
      _PolicySection(
        theme: theme,
        title: 'التحديثات',
        content:
            'قد نقوم بتحديث سياسة الخصوصية هذه من وقت لآخر. سنعلمك بأي تغييرات جوهرية من خلال التطبيق.',
      ),
    ];
  }

  List<Widget> _buildEnglishContent(ThemeData theme) {
    return [
      _PolicySection(
        theme: theme,
        title: 'Introduction',
        content:
            'Welcome to "Kirkuk Fuel Quota" app. We respect your privacy and are committed to protecting your personal data. This privacy policy explains how we collect, use, and protect your information.',
      ),
      _PolicySection(
        theme: theme,
        title: 'Data We Collect',
        content: '''• Vehicle information: Names and types you enter
• Fuel log records: Dates and notes
• Location data: Only when using the maps feature (with your permission)

Note: All this data is stored locally on your device only and is not sent to any external server.''',
      ),
      _PolicySection(
        theme: theme,
        title: 'How We Use Your Data',
        content: '''• To track your vehicles' fuel quotas
• To display nearby fuel stations on the map
• To send reminder notifications for quota periods
• To improve user experience''',
      ),
      _PolicySection(
        theme: theme,
        title: 'Data Storage',
        content:
            'All your data is stored locally on your device using Hive technology. We do not send any personal data to external servers. You can delete all your data at any time by uninstalling the app.',
      ),
      _PolicySection(
        theme: theme,
        title: 'Required Permissions',
        content:
            '''• Location: To show your location on the stations map (optional)
• Notifications: To remind you of quota periods (optional)
• Internet: To load fuel station data from OpenStreetMap''',
      ),
      _PolicySection(
        theme: theme,
        title: 'Third-Party Services',
        content: '''• OpenStreetMap: For displaying maps and station locations
• Overpass API: For fetching fuel station data

These services have their own privacy policies.''',
      ),
      _PolicySection(
        theme: theme,
        title: 'Your Rights',
        content: '''• Access your stored data
• Modify or delete your data at any time
• Revoke permissions from device settings
• Uninstall the app to delete all data''',
      ),
      _PolicySection(
        theme: theme,
        title: 'Updates',
        content:
            'We may update this privacy policy from time to time. We will notify you of any material changes through the app.',
      ),
    ];
  }
}

class _PolicySection extends StatelessWidget {
  final ThemeData theme;
  final String title;
  final String content;

  const _PolicySection({
    required this.theme,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
          ),
        ],
      ),
    );
  }
}
