import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/kirkuk_quota_system.dart';
import '../../data/models/vehicle.dart';
import '../../logic/vehicle_controller.dart';

/// لوحة التحكم الرئيسية - Dashboard (الأصلية)
class DashboardWidget extends StatelessWidget {
  const DashboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<VehicleController>(
      builder: (context, controller, _) {
        return Column(
          children: [
            // إحصائيات سريعة
            _QuickStatsRow(vehicles: controller.vehicles),

            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}

/// ويدجت الإحصائيات فقط (بدون العداد)
class DashboardStatsWidget extends StatelessWidget {
  const DashboardStatsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<VehicleController>(
      builder: (context, controller, _) {
        return Column(
          children: [
            const SizedBox(height: 16),
            _QuickStatsRow(vehicles: controller.vehicles),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}

/// صف الإحصائيات السريعة
class _QuickStatsRow extends StatelessWidget {
  final List<Vehicle> vehicles;

  const _QuickStatsRow({required this.vehicles});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentQuota = KirkukQuotaSystem.getCurrentQuota();
    final nextQuota = KirkukQuotaSystem.getNextQuota();
    final isActive = currentQuota.isActiveNow;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // كارت عدد السيارات
            Expanded(
              child: _UnifiedCard(
                title: l10n.translate('total_vehicles'),
                mainContent: vehicles.length.toString(),
                gradient: const [Color(0xFF1565C0), Color(0xFF1976D2)],
                icon: Icons.directions_car,
              ),
            ),
            const SizedBox(width: 8),
            // كارت الحصة الحالية
            Expanded(
              child: _UnifiedCard(
                title: l10n.currentQuota,
                mainContent:
                    '${currentQuota.start.day}/${currentQuota.start.month}/${currentQuota.start.year}',
                subContent:
                    '${currentQuota.end.day}/${currentQuota.end.month}/${currentQuota.end.year}',
                status: isActive ? l10n.open : l10n.closed,
                gradient: isActive
                    ? const [Color(0xFF2E7D32), Color(0xFF43A047)]
                    : const [Color(0xFFC62828), Color(0xFFD32F2F)],
              ),
            ),
            const SizedBox(width: 8),
            // كارت الحصة القادمة
            Expanded(
              child: _UnifiedCard(
                title: l10n.translate('next_quota'),
                mainContent:
                    '${nextQuota.start.day}/${nextQuota.start.month}/${nextQuota.start.year}',
                subContent:
                    '${nextQuota.end.day}/${nextQuota.end.month}/${nextQuota.end.year}',
                gradient: const [Color(0xFF7B1FA2), Color(0xFF9C27B0)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// كارت موحد للجميع - نفس الحجم
class _UnifiedCard extends StatelessWidget {
  final String title;
  final String mainContent;
  final String? subContent;
  final String? status;
  final List<Color> gradient;
  final IconData? icon;

  const _UnifiedCard({
    required this.title,
    required this.mainContent,
    this.subContent,
    this.status,
    required this.gradient,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: gradient[0].withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // العنوان في الأعلى
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),

          // المحتوى الرئيسي
          if (icon != null) ...[
            // كارت السيارات - أيقونة + رقم
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradient),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                mainContent,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: gradient[0],
                ),
              ),
            ),
          ] else ...[
            // كارت الحصة - التواريخ
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                mainContent,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: gradient[0],
                ),
              ),
            ),
            if (subContent != null) ...[
              Text(
                AppLocalizations.of(context).translate('to'),
                style: TextStyle(
                  fontSize: 9,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  subContent!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: gradient[0],
                  ),
                ),
              ),
            ],
          ],

          // الحالة (للحصة الحالية فقط)
          if (status != null) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: gradient[0].withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: gradient[0],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    status!,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: gradient[0],
                    ),
                  ),
                ],
              ),
            ),
          ] else if (icon == null) ...[
            // مساحة فارغة للحصة القادمة لتتساوى مع الحالية
            const SizedBox(height: 18),
          ],
        ],
      ),
    );
  }
}

/// ويدجت الترحيب
class WelcomeHeader extends StatelessWidget {
  const WelcomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final hour = DateTime.now().hour;

    String greeting;
    IconData greetingIcon;

    if (hour < 12) {
      greeting = l10n.translate('good_morning');
      greetingIcon = Icons.wb_sunny;
    } else if (hour < 17) {
      greeting = l10n.translate('good_afternoon');
      greetingIcon = Icons.wb_sunny_outlined;
    } else {
      greeting = l10n.translate('good_evening');
      greetingIcon = Icons.nights_stay;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFA726), Color(0xFFFF9800)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(greetingIcon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  l10n.translate('welcome_message'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          // أيقونة كركوك
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('🏛️', style: TextStyle(fontSize: 24)),
          ),
        ],
      ),
    );
  }
}

/// عنوان قسم السيارات
class VehiclesSectionHeader extends StatelessWidget {
  final int vehicleCount;
  final VoidCallback onAddTap;

  const VehiclesSectionHeader({
    super.key,
    required this.vehicleCount,
    required this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.directions_car, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                l10n.translate('my_vehicles'),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  vehicleCount.toString(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          TextButton.icon(
            onPressed: onAddTap,
            icon: const Icon(Icons.add, size: 20),
            label: Text(l10n.add),
          ),
        ],
      ),
    );
  }
}
