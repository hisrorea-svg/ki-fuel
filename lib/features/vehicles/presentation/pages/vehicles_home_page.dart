import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../logic/vehicle_controller.dart';
import '../widgets/countdown_timer_widget.dart';
import '../widgets/dashboard_widget.dart';
import '../widgets/vehicle_card.dart';
import 'add_edit_vehicle_page.dart';
import 'vehicle_detail_page.dart';

/// Home page displaying all vehicles with their quota status
class VehiclesHomePage extends StatefulWidget {
  const VehiclesHomePage({super.key});

  @override
  State<VehiclesHomePage> createState() => _VehiclesHomePageState();
}

class _VehiclesHomePageState extends State<VehiclesHomePage> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    // Refresh the UI every second for live countdown
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  /// تأكيد الخروج من التطبيق
  Future<bool> _onWillPop() async {
    final l10n = AppLocalizations.of(context);
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.translate('exit_app')),
        content: Text(l10n.translate('exit_app_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.translate('exit')),
          ),
        ],
      ),
    );

    if (shouldExit == true) {
      SystemNavigator.pop();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _onWillPop();
        }
      },
      child: Scaffold(
        body: Consumer<VehicleController>(
          builder: (context, controller, child) {
            if (controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.error != null) {
              return _buildErrorState(context, controller, l10n, theme);
            }

            return RefreshIndicator(
              onRefresh: () => controller.loadVehicles(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // Header الرئيسي مع العداد - يحتاج تحديث كل ثانية
                  SliverToBoxAdapter(
                    child: CountdownTimerWidget(
                      key: ValueKey(DateTime.now().second),
                    ),
                  ),

                  // إحصائيات سريعة
                  SliverToBoxAdapter(
                    child: DashboardStatsWidget(
                      key: ValueKey(DateTime.now().second),
                    ),
                  ),

                  // عنوان قسم السيارات
                  SliverToBoxAdapter(
                    child: VehiclesSectionHeader(
                      vehicleCount: controller.vehicles.length,
                      onAddTap: () => _navigateToAdd(context),
                    ),
                  ),

                  // قائمة السيارات أو الحالة الفارغة
                  if (controller.vehicles.isEmpty)
                    SliverToBoxAdapter(child: _buildEmptyState(context, l10n))
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final vehicle = controller.vehicles[index];
                        final isFueled = controller
                            .isVehicleFueledInCurrentQuota(vehicle.id);
                        return VehicleCard(
                          vehicle: vehicle,
                          displayName: controller.getDisplayName(vehicle),
                          isFueledInCurrentQuota: isFueled,
                          onTap: () =>
                              _navigateToDetail(context, vehicle, controller),
                          onEdit: () => _navigateToEdit(context, vehicle),
                          onDelete: () => _confirmDelete(
                            context,
                            vehicle,
                            controller,
                            l10n,
                          ),
                        );
                      }, childCount: controller.vehicles.length),
                    ),

                  // مساحة في الأسفل
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    VehicleController controller,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
          const SizedBox(height: 16),
          Text(l10n.errorLoadingVehicles, style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            controller.error!,
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              controller.clearError();
              controller.loadVehicles();
            },
            icon: const Icon(Icons.refresh),
            label: Text(l10n.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.directions_car_outlined,
              size: 32,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.noVehiclesYet,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.addFirstVehicleHint,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: () => _navigateToAdd(context),
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  void _navigateToAdd(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const AddEditVehiclePage()));
  }

  void _navigateToEdit(BuildContext context, vehicle) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditVehiclePage(vehicle: vehicle),
      ),
    );
  }

  void _navigateToDetail(
    BuildContext context,
    vehicle,
    VehicleController controller,
  ) {
    controller.selectVehicle(vehicle);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VehicleDetailPage(vehicle: vehicle),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    vehicle,
    VehicleController controller,
    AppLocalizations l10n,
  ) {
    final displayName = controller.getDisplayName(vehicle);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteVehicle),
        content: Text(l10n.deleteVehicleConfirm(displayName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              controller.deleteVehicle(vehicle.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$displayName ${l10n.vehicleDeleted}'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}
