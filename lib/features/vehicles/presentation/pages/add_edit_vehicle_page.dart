import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/kirkuk_quota_system.dart';
import '../../data/models/vehicle.dart';
import '../../logic/vehicle_controller.dart';

/// Page for adding or editing a vehicle
class AddEditVehiclePage extends StatefulWidget {
  final Vehicle? vehicle;

  const AddEditVehiclePage({super.key, this.vehicle});

  @override
  State<AddEditVehiclePage> createState() => _AddEditVehiclePageState();
}

class _AddEditVehiclePageState extends State<AddEditVehiclePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late VehicleType _selectedType;
  bool _isSubmitting = false;

  bool get isEditing => widget.vehicle != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.vehicle?.name ?? '');
    _selectedType = widget.vehicle?.vehicleType ?? VehicleType.private;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final currentQuota = KirkukQuotaSystem.getCurrentQuota();

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? l10n.editVehicle : l10n.addVehicle),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // اختيار نوع السيارة
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.category, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          l10n.translate('vehicle_type'),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _VehicleTypeSelector(
                      selectedType: _selectedType,
                      onChanged: (type) {
                        setState(() => _selectedType = type);
                      },
                      languageCode: l10n.locale.languageCode,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Name field
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(_selectedType.icon, color: _selectedType.color),
                        const SizedBox(width: 8),
                        Text(
                          l10n.vehicleName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            l10n.optional,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: l10n.vehicleNameHint,
                        helperText: l10n.leaveEmptyAutoName,
                        prefixIcon: Icon(
                          _selectedType.icon,
                          color: _selectedType.color,
                        ),
                      ),
                      textCapitalization: TextCapitalization.words,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // نظام الحصص التلقائي - معلومات فقط
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          l10n.quotaSystemInfo,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withValues(
                          alpha: 0.3,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.translate('app_subtitle'),
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _InfoRow(
                            icon: Icons.repeat,
                            text: l10n.quotaRepeatsEvery5Days,
                          ),
                          const SizedBox(height: 4),
                          _InfoRow(
                            icon: Icons.calendar_today,
                            text: l10n.currentQuota,
                          ),
                          const SizedBox(height: 4),
                          _InfoRow(
                            icon: Icons.date_range,
                            text: currentQuota.formattedDateRange,
                          ),
                          const SizedBox(height: 4),
                          _InfoRow(
                            icon: currentQuota.isActiveNow
                                ? Icons.check_circle
                                : Icons.schedule,
                            text: currentQuota.isActiveNow
                                ? l10n.currentlyOpen
                                : l10n.currentlyClosed,
                            color: currentQuota.isActiveNow
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.quotaAutoMessage,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Submit button
            FilledButton(
              onPressed: _isSubmitting ? null : _submit,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: _selectedType.color,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_selectedType.icon),
                        const SizedBox(width: 8),
                        Text(
                          isEditing ? l10n.saveChanges : l10n.addVehicle,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final controller = context.read<VehicleController>();
    final l10n = AppLocalizations.of(context);
    bool success;

    if (isEditing) {
      success = await controller.updateVehicle(
        id: widget.vehicle!.id,
        name: _nameController.text,
        vehicleTypeIndex: _selectedType.index,
      );
    } else {
      success = await controller.addVehicle(
        name: _nameController.text,
        vehicleType: _selectedType,
      );
    }

    setState(() => _isSubmitting = false);

    if (success && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? l10n.vehicleUpdated : l10n.vehicleAdded),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.error ?? 'حدث خطأ'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}

/// محدد نوع السيارة
class _VehicleTypeSelector extends StatelessWidget {
  final VehicleType selectedType;
  final ValueChanged<VehicleType> onChanged;
  final String languageCode;

  const _VehicleTypeSelector({
    required this.selectedType,
    required this.onChanged,
    required this.languageCode,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.85,
      ),
      itemCount: VehicleType.values.length,
      itemBuilder: (context, index) {
        final type = VehicleType.values[index];
        final isSelected = type == selectedType;
        final isDisabled =
            type == VehicleType.taxi || type == VehicleType.public;

        return GestureDetector(
          onTap: () {
            if (isDisabled) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    languageCode == 'ar' ? 'سيتوفر قريباً' : 'Coming Soon',
                  ),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              return;
            }
            onChanged(type);
          },
          child: Opacity(
            opacity: isDisabled ? 0.5 : 1.0,
            child: Stack(
              fit: StackFit.expand,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? type.color.withValues(alpha: 0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? type.color
                          : isDisabled
                          ? Colors.grey.withValues(alpha: 0.1)
                          : Colors.grey.withValues(alpha: 0.3),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? type.color
                              : isDisabled
                              ? Colors.grey.withValues(alpha: 0.1)
                              : Colors.grey.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          type.icon,
                          color: isSelected
                              ? Colors.white
                              : isDisabled
                              ? Colors.grey
                              : Colors.grey,
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        type.getLocalizedName(languageCode),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? type.color
                              : isDisabled
                              ? Colors.grey
                              : Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (isDisabled)
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Soon',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;

  const _InfoRow({required this.icon, required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: color ?? theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: color ?? theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
