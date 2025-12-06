import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/services/remote_config_service.dart';
import '../../../../core/theme/app_colors.dart';

/// صفحة البلاغات - للإبلاغ عن مشاكل محطات الوقود
class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final _formKey = GlobalKey<FormState>();
  final _stationNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _detailsController = TextEditingController();
  final _remoteConfig = RemoteConfigService();
  final _connectivity = ConnectivityService();

  ReportType _selectedType = ReportType.stationClosed;
  bool _isSubmitting = false;
  bool _isOffline = false;
  bool _hasPendingReport = false;

  StreamSubscription<bool>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _listenToConnectivity();
  }

  @override
  void dispose() {
    _stationNameController.dispose();
    _locationController.dispose();
    _detailsController.dispose();
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  /// التحقق من الاتصال
  Future<void> _checkConnectivity() async {
    final isConnected = await _connectivity.checkConnectivity();
    if (mounted) {
      setState(() => _isOffline = !isConnected);
    }
  }

  /// الاستماع لتغييرات الاتصال
  void _listenToConnectivity() {
    _connectivitySubscription = _connectivity.connectionStream.listen((
      isConnected,
    ) {
      if (mounted) {
        setState(() => _isOffline = !isConnected);

        // إذا عاد الاتصال وهناك بلاغ معلق
        if (isConnected && _hasPendingReport) {
          _submitReport();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    // التحقق من تفعيل البلاغات
    if (!_remoteConfig.enableReports) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.translate('reports')),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.block_rounded,
                  size: 80,
                  color: theme.colorScheme.outline,
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.translate('reports_disabled'),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.translate('reports_disabled_message'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.translate('reports')), centerTitle: true),
      body: Column(
        children: [
          // شريط عدم الاتصال
          if (_isOffline)
            _OfflineBanner(hasPendingReport: _hasPendingReport, l10n: l10n),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // وصف الصفحة
                    _InfoCard(l10n: l10n),

                    const SizedBox(height: 24),

                    // نوع البلاغ
                    Text(
                      l10n.translate('report_type'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ReportTypeSelector(
                      selectedType: _selectedType,
                      onTypeSelected: (type) {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedType = type);
                      },
                      l10n: l10n,
                    ),

                    const SizedBox(height: 24),

                    // تفاصيل البلاغ
                    Text(
                      l10n.translate('report_details'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // اسم المحطة
                    TextFormField(
                      controller: _stationNameController,
                      decoration: InputDecoration(
                        labelText: l10n.translate('station_name'),
                        hintText: l10n.translate('station_name_hint'),
                        prefixIcon: const Icon(Icons.local_gas_station),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      textInputAction: TextInputAction.next,
                    ),

                    const SizedBox(height: 16),

                    // الموقع
                    TextFormField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        labelText: l10n.translate('location'),
                        hintText: l10n.translate('location_hint'),
                        prefixIcon: const Icon(Icons.location_on),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      textInputAction: TextInputAction.next,
                    ),

                    const SizedBox(height: 16),

                    // تفاصيل إضافية
                    TextFormField(
                      controller: _detailsController,
                      decoration: InputDecoration(
                        labelText: l10n.translate('additional_details'),
                        hintText: l10n.translate('additional_details_hint'),
                        prefixIcon: const Icon(Icons.description),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 4,
                      textInputAction: TextInputAction.done,
                    ),

                    const SizedBox(height: 32),

                    // زر الإرسال
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton.icon(
                        onPressed: _isSubmitting ? null : _submitReport,
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.send_rounded),
                        label: Text(
                          _isSubmitting
                              ? l10n.translate('sending')
                              : l10n.translate('send_report'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ملاحظة
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              l10n.translate('report_note'),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitReport() async {
    HapticFeedback.lightImpact();

    final l10n = AppLocalizations.of(context);

    // التحقق من إدخال بيانات كافية
    if (_stationNameController.text.isEmpty &&
        _locationController.text.isEmpty &&
        _detailsController.text.isEmpty) {
      _showErrorSnackBar(l10n.translate('please_fill_details'));
      return;
    }

    // التحقق من الاتصال بالإنترنت
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      if (!mounted) return;

      // حفظ البلاغ كمعلق وإظهار رسالة
      setState(() {
        _hasPendingReport = true;
        _isOffline = true;
      });

      _showPendingSnackBar(l10n);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _hasPendingReport = false;
    });

    try {
      // إنشاء نموذج البلاغ
      final report = ReportModel(
        reportType: _selectedType.name,
        stationName: _stationNameController.text,
        location: _locationController.text,
        details: _detailsController.text,
        createdAt: DateTime.now(),
      );

      // إرسال البلاغ إلى Firestore
      final firestoreService = FirestoreService();
      final reportId = await firestoreService.submitReport(report);

      if (!mounted) return;

      if (reportId != null) {
        // مسح الحقول بعد الإرسال الناجح
        _stationNameController.clear();
        _locationController.clear();
        _detailsController.clear();
        setState(() => _selectedType = ReportType.stationClosed);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.translate('report_sent_successfully')),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Failed to submit report');
      }
    } on Exception catch (e) {
      if (!mounted) return;

      String errorMessage;
      if (e.toString().contains('PERMISSION_DENIED')) {
        errorMessage = l10n.translate('permission_denied_error');
      } else if (e.toString().contains('UNAVAILABLE') ||
          e.toString().contains('network')) {
        errorMessage = l10n.translate('network_error');
        // حفظ كمعلق للإرسال لاحقاً
        setState(() => _hasPendingReport = true);
      } else if (e.toString().contains('TIMEOUT') ||
          e.toString().contains('deadline')) {
        errorMessage = l10n.translate('timeout_error');
        setState(() => _hasPendingReport = true);
      } else {
        errorMessage = l10n.translate('error_sending_report');
      }

      _showErrorSnackBar(errorMessage);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showPendingSnackBar(AppLocalizations l10n) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.schedule, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(l10n.translate('report_will_send_when_online')),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.orange.shade700,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
}

/// أنواع البلاغات
enum ReportType { stationClosed, crowded, outOfFuel, priceIssue, other }

/// شريط عدم الاتصال في صفحة البلاغات
class _OfflineBanner extends StatelessWidget {
  final bool hasPendingReport;
  final AppLocalizations l10n;

  const _OfflineBanner({required this.hasPendingReport, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      color: hasPendingReport ? Colors.orange.shade700 : Colors.red.shade700,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasPendingReport ? Icons.schedule : Icons.wifi_off_rounded,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              hasPendingReport
                  ? l10n.translate('report_pending_offline')
                  : l10n.translate('no_internet_connection'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// بطاقة المعلومات
class _InfoCard extends StatelessWidget {
  final AppLocalizations l10n;

  const _InfoCard({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.primary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.campaign_rounded,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.translate('report_problem'),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.translate('report_description'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// اختيار نوع البلاغ
class _ReportTypeSelector extends StatelessWidget {
  final ReportType selectedType;
  final Function(ReportType) onTypeSelected;
  final AppLocalizations l10n;

  const _ReportTypeSelector({
    required this.selectedType,
    required this.onTypeSelected,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ReportType.values.map((type) {
        final isSelected = type == selectedType;
        return _ReportTypeChip(
          type: type,
          isSelected: isSelected,
          onTap: () => onTypeSelected(type),
          l10n: l10n,
        );
      }).toList(),
    );
  }
}

/// شريحة نوع البلاغ
class _ReportTypeChip extends StatelessWidget {
  final ReportType type;
  final bool isSelected;
  final VoidCallback onTap;
  final AppLocalizations l10n;

  const _ReportTypeChip({
    required this.type,
    required this.isSelected,
    required this.onTap,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? _getTypeColor(type)
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? _getTypeColor(type)
                  : theme.colorScheme.outline.withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getTypeIcon(type),
                size: 18,
                color: isSelected
                    ? Colors.white
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                _getTypeLabel(type),
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getTypeIcon(ReportType type) {
    switch (type) {
      case ReportType.stationClosed:
        return Icons.block_rounded;
      case ReportType.crowded:
        return Icons.groups_rounded;
      case ReportType.outOfFuel:
        return Icons.local_gas_station_outlined;
      case ReportType.priceIssue:
        return Icons.attach_money_rounded;
      case ReportType.other:
        return Icons.more_horiz_rounded;
    }
  }

  Color _getTypeColor(ReportType type) {
    switch (type) {
      case ReportType.stationClosed:
        return Colors.red.shade600;
      case ReportType.crowded:
        return Colors.orange.shade600;
      case ReportType.outOfFuel:
        return Colors.purple.shade600;
      case ReportType.priceIssue:
        return Colors.blue.shade600;
      case ReportType.other:
        return Colors.grey.shade600;
    }
  }

  String _getTypeLabel(ReportType type) {
    switch (type) {
      case ReportType.stationClosed:
        return l10n.translate('station_closed');
      case ReportType.crowded:
        return l10n.translate('station_crowded');
      case ReportType.outOfFuel:
        return l10n.translate('out_of_fuel');
      case ReportType.priceIssue:
        return l10n.translate('price_issue');
      case ReportType.other:
        return l10n.translate('other_issue');
    }
  }
}
