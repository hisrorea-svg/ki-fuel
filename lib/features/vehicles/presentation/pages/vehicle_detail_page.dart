import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/date_extensions.dart';
import '../../../../core/utils/kirkuk_quota_system.dart';
import '../../data/models/vehicle.dart';
import '../../logic/vehicle_controller.dart';
import '../widgets/quota_status_chip.dart';
import '../widgets/fuel_log_list.dart';
import 'add_edit_vehicle_page.dart';
import 'add_fuel_log_page.dart';

/// Detail page showing vehicle information and fuel logs
class VehicleDetailPage extends StatefulWidget {
  final Vehicle vehicle;

  const VehicleDetailPage({super.key, required this.vehicle});

  @override
  State<VehicleDetailPage> createState() => _VehicleDetailPageState();
}

class _VehicleDetailPageState extends State<VehicleDetailPage> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    // Refresh the UI every minute to update countdowns
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Consumer<VehicleController>(
      builder: (context, controller, child) {
        // Get the latest version of the vehicle
        final vehicle = controller.vehicles.firstWhere(
          (v) => v.id == widget.vehicle.id,
          orElse: () => widget.vehicle,
        );

        final displayName = controller.getDisplayName(vehicle);

        // استخدام نظام كركوك الموحد للحصص
        final currentQuota = KirkukQuotaSystem.getCurrentQuota();
        final quotaList = KirkukQuotaSystem.getQuotaList();
        final isActive = currentQuota.isActiveNow;

        return Scaffold(
          appBar: AppBar(
            title: Text(displayName),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => _navigateToEdit(context, vehicle),
                tooltip: l10n.edit,
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await controller.loadFuelLogsForVehicle(vehicle.id);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current Quota Status Card
                  _CurrentQuotaCard(
                    quota: currentQuota,
                    isActive: isActive,
                    l10n: l10n,
                  ),

                  const SizedBox(height: 24),

                  // Quota Timeline Section
                  Text(
                    l10n.quotaTimeline,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _QuotaTimeline(
                    quotas: quotaList,
                    currentQuota: currentQuota,
                    l10n: l10n,
                  ),

                  const SizedBox(height: 24),

                  // Fuel Logs Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.fuelLogs,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${controller.currentVehicleLogs.length} ${l10n.entries}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  FuelLogList(
                    logs: controller.currentVehicleLogs,
                    onDelete: (log) {
                      controller.deleteFuelLog(log.id, vehicle.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.fuelLogDeleted),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),

                  // Bottom spacing for FAB
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          floatingActionButton: Builder(
            builder: (context) {
              final isFueled = controller.isVehicleFueledInCurrentQuota(
                vehicle.id,
              );

              return FloatingActionButton.extended(
                onPressed: () {
                  if (isFueled) {
                    _showAlreadyFueledDialog(context, l10n);
                  } else {
                    _navigateToAddFuelLog(context, vehicle.id);
                  }
                },
                icon: Icon(isFueled ? Icons.check : Icons.add),
                label: Text(
                  isFueled
                      ? l10n.translate('already_fueled_in_quota')
                      : l10n.addFuelLog,
                ),
                backgroundColor: isFueled ? Colors.grey : null,
              );
            },
          ),
        );
      },
    );
  }

  void _navigateToEdit(BuildContext context, Vehicle vehicle) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditVehiclePage(vehicle: vehicle),
      ),
    );
  }

  void _navigateToAddFuelLog(BuildContext context, String vehicleId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddFuelLogPage(vehicleId: vehicleId),
      ),
    );
  }

  void _showAlreadyFueledDialog(BuildContext context, AppLocalizations l10n) {
    final nextQuota = KirkukQuotaSystem.getNextQuota();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.info_outline, color: Colors.orange, size: 48),
        title: Text(l10n.translate('already_fueled_in_quota')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.translate('already_fueled_in_quota_message'),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.schedule, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${l10n.translate('next_quota_info')} ${nextQuota.start.day}/${nextQuota.start.month}/${nextQuota.start.year}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.translate('cancel')),
          ),
        ],
      ),
    );
  }
}

/// Card showing current quota status with countdown
class _CurrentQuotaCard extends StatelessWidget {
  final QuotaPeriod quota;
  final bool isActive;
  final AppLocalizations l10n;

  const _CurrentQuotaCard({
    required this.quota,
    required this.isActive,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final duration = isActive
        ? quota.timeUntilEnd()
        : KirkukQuotaSystem.getNextQuota().timeUntilStart();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // رقم الحصة
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                l10n.currentQuota,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isActive ? Icons.check_circle : Icons.schedule,
                  color: isActive ? Colors.green : colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  isActive ? l10n.quotaIsOpen : l10n.quotaIsClosed,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isActive ? Colors.green : colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            QuotaStatusChip(isActive: isActive, large: true),
            const SizedBox(height: 20),

            // Countdown
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.green.withValues(alpha: 0.1)
                    : colorScheme.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    isActive ? l10n.endsIn : l10n.opensIn,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.formatDuration(duration),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isActive ? Colors.green : colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Period dates
            Row(
              children: [
                Expanded(
                  child: _DateInfo(
                    label: l10n.start,
                    date: quota.start,
                    icon: Icons.play_arrow_rounded,
                  ),
                ),
                Container(
                  height: 40,
                  width: 1,
                  color: colorScheme.outlineVariant,
                ),
                Expanded(
                  child: _DateInfo(
                    label: l10n.end,
                    date: quota.end,
                    icon: Icons.stop_rounded,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Date info widget
class _DateInfo extends StatelessWidget {
  final String label;
  final DateTime date;
  final IconData icon;

  const _DateInfo({
    required this.label,
    required this.date,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: theme.colorScheme.primary),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${date.day}/${date.month}/${date.year}',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          date.toTime12Hour(),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Timeline showing past and future quota windows
class _QuotaTimeline extends StatelessWidget {
  final List<QuotaPeriod> quotas;
  final QuotaPeriod currentQuota;
  final AppLocalizations l10n;

  const _QuotaTimeline({
    required this.quotas,
    required this.currentQuota,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: quotas.map((quota) {
            final isCurrent = quota.number == currentQuota.number;
            final isPast = quota.isPast;
            final isActive = quota.isActiveNow;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  // Timeline indicator
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? (isActive ? Colors.green : colorScheme.primary)
                          : (isPast
                                ? colorScheme.outlineVariant
                                : colorScheme.primaryContainer),
                      shape: BoxShape.circle,
                      border: isCurrent
                          ? Border.all(
                              color: isActive
                                  ? Colors.green
                                  : colorScheme.primary,
                              width: 2,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Date range
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              quota.formattedDateRange,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: isCurrent
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isPast
                                    ? colorScheme.onSurfaceVariant
                                    : null,
                              ),
                            ),
                            if (isCurrent) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? Colors.green.withValues(alpha: 0.15)
                                      : colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  isActive ? l10n.now : l10n.current,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isActive
                                        ? Colors.green
                                        : colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (isPast)
                          Text(
                            l10n.past,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          )
                        else if (quota.isFuture)
                          Text(
                            l10n.upcoming,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.primary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
