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
        title: 'التزامنا بالخصوصية',
        content:
            'نولي في "حصة وقود كركوك" أهمية قصوى لخصوصية مستخدمينا. نحن نلتزم بتطبيق أعلى معايير الأمان والخصوصية العالمية لضمان حماية بياناتكم الشخصية ومعلوماتكم.',
      ),
      _PolicySection(
        theme: theme,
        title: 'أمن المعلومات',
        content:
            'نحرص على استخدام بروتوكولات أمان متقدمة ومتوافقة مع المعايير القياسية لحماية جميع البيانات المدخلة في التطبيق. يتم تشفير المعلومات ومعالجتها بطرق آمنة تضمن سريتها التامة وعدم الوصول إليها من قبل أي أطراف غير مصرح لها.',
      ),
      _PolicySection(
        theme: theme,
        title: 'جمع واستخدام البيانات',
        content:
            'يقتصر استخدامنا للبيانات على ما هو ضروري لتقديم خدمات التطبيق بكفاءة عالية. نحن نتبع سياسة "الحد الأدنى من البيانات" ولا نقوم بجمع أو معالجة أي معلومات لا تخدم الغرض الأساسي للتطبيق والمتمثل في إدارة حصص الوقود.',
      ),
      _PolicySection(
        theme: theme,
        title: 'حقوق المستخدم',
        content:
            'إيماناً منا بمبدأ الشفافية، نؤكد أن لكم الحق الكامل في التحكم ببياناتكم. تصميم التطبيق يضمن لكم القدرة على إدارة معلوماتكم ومراجعتها في أي وقت، بما يتوافق مع حقوق المستخدم الرقمية.',
      ),
      _PolicySection(
        theme: theme,
        title: 'التواصل والدعم',
        content:
            'في حال وجود أي استفسارات حول سياسة الخصوصية أو معايير الأمان المتبعة، لا تترددوا في التواصل معنا. فريقنا جاهز للإجابة على تساؤلاتكم لضمان تجربة آمنة وموثوقة.',
      ),
    ];
  }

  List<Widget> _buildEnglishContent(ThemeData theme) {
    return [
      _PolicySection(
        theme: theme,
        title: 'Our Commitment to Privacy',
        content:
            'At "Kirkuk Fuel Quota", we prioritize the privacy of our users. We are committed to implementing the highest global security and privacy standards to ensure the protection of your personal data and information.',
      ),
      _PolicySection(
        theme: theme,
        title: 'Information Security',
        content:
            'We ensure the use of advanced security protocols that comply with standard industry practices to protect all data entered into the application. Information is encrypted and processed in secure ways to ensure complete confidentiality and prevent unauthorized access.',
      ),
      _PolicySection(
        theme: theme,
        title: 'Data Collection & Usage',
        content:
            'Our data usage is strictly limited to what is necessary to deliver the application services efficiently. We follow a "Data Minimization" policy and do not collect or process any information that does not serve the core purpose of managing fuel quotas.',
      ),
      _PolicySection(
        theme: theme,
        title: 'User Rights',
        content:
            'Believing in the principle of transparency, we affirm that you have full control over your data. The application design ensures your ability to manage and review your information at any time, in compliance with digital user rights.',
      ),
      _PolicySection(
        theme: theme,
        title: 'Contact & Support',
        content:
            'If you have any inquiries regarding our privacy policy or the security standards we follow, please do not hesitate to contact us. Our team is ready to answer your questions to ensure a secure and reliable experience.',
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
