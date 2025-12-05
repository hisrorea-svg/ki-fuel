import 'package:flutter/foundation.dart';
import '../../../core/utils/kirkuk_quota_system.dart';
import '../data/models/vehicle.dart';
import '../data/models/fuel_log_entry.dart';
import '../data/repositories/vehicle_repository.dart';
import '../../notifications/notification_service.dart';

/// Controller for managing vehicle state and business logic
class VehicleController extends ChangeNotifier {
  final VehicleRepository _repository;
  final NotificationService _notificationService;

  List<Vehicle> _vehicles = [];
  List<FuelLogEntry> _currentVehicleLogs = [];
  Vehicle? _selectedVehicle;
  bool _isLoading = false;
  String? _error;

  VehicleController({
    required VehicleRepository repository,
    required NotificationService notificationService,
  }) : _repository = repository,
       _notificationService = notificationService;

  // ============ GETTERS ============

  List<Vehicle> get vehicles => _vehicles;
  List<FuelLogEntry> get currentVehicleLogs => _currentVehicleLogs;
  Vehicle? get selectedVehicle => _selectedVehicle;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Get display name for a vehicle at a specific index
  String getDisplayName(Vehicle vehicle) {
    final index = _vehicles.indexOf(vehicle);
    return vehicle.getDisplayName(index >= 0 ? index : 0);
  }

  /// Get the current quota (using Kirkuk system)
  QuotaPeriod getCurrentQuota() {
    return KirkukQuotaSystem.getCurrentQuota();
  }

  /// Get multiple quota periods for timeline view
  List<QuotaPeriod> getQuotaList({int pastPeriods = 2, int futurePeriods = 3}) {
    return KirkukQuotaSystem.getQuotaList(
      pastPeriods: pastPeriods,
      futurePeriods: futurePeriods,
    );
  }

  // ============ VEHICLE OPERATIONS ============

  /// Load all vehicles from storage
  Future<void> loadVehicles() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _vehicles = _repository.getAllVehicles();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load vehicles: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add a new vehicle (quota is automatic - no need for dates)
  Future<bool> addVehicle({
    String? name,
    VehicleType vehicleType = VehicleType.private,
  }) async {
    try {
      final vehicle = Vehicle.create(
        name: name?.trim().isEmpty == true ? null : name?.trim(),
        type: vehicleType,
      );

      await _repository.addVehicle(vehicle);
      await loadVehicles();

      // Schedule notifications for the new vehicle
      await _scheduleNotifications(vehicle);

      return true;
    } catch (e) {
      _error = 'Failed to add vehicle: $e';
      notifyListeners();
      return false;
    }
  }

  /// Update an existing vehicle
  Future<bool> updateVehicle({
    required String id,
    String? name,
    int? vehicleTypeIndex,
  }) async {
    try {
      final existing = _repository.getVehicleById(id);
      if (existing == null) {
        _error = 'Vehicle not found';
        notifyListeners();
        return false;
      }

      final updated = existing.copyWith(
        name: name?.trim().isEmpty == true ? null : name?.trim(),
        vehicleTypeIndex: vehicleTypeIndex,
      );

      await _repository.updateVehicle(updated);
      await loadVehicles();

      // Reschedule notifications
      await _notificationService.cancelNotificationsForVehicle(id);
      await _scheduleNotifications(updated);

      // Update selected vehicle if it was edited
      if (_selectedVehicle?.id == id) {
        _selectedVehicle = updated;
        notifyListeners();
      }

      return true;
    } catch (e) {
      _error = 'Failed to update vehicle: $e';
      notifyListeners();
      return false;
    }
  }

  /// Delete a vehicle
  Future<bool> deleteVehicle(String id) async {
    try {
      // Cancel notifications first
      await _notificationService.cancelNotificationsForVehicle(id);

      await _repository.deleteVehicle(id);
      await loadVehicles();

      // Clear selected vehicle if it was deleted
      if (_selectedVehicle?.id == id) {
        _selectedVehicle = null;
        _currentVehicleLogs = [];
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete vehicle: $e';
      notifyListeners();
      return false;
    }
  }

  /// Select a vehicle and load its fuel logs
  Future<void> selectVehicle(Vehicle vehicle) async {
    _selectedVehicle = vehicle;
    await loadFuelLogsForVehicle(vehicle.id);
    notifyListeners();
  }

  /// Clear the selected vehicle
  void clearSelectedVehicle() {
    _selectedVehicle = null;
    _currentVehicleLogs = [];
    notifyListeners();
  }

  // ============ FUEL LOG OPERATIONS ============

  /// Load fuel logs for a specific vehicle
  Future<void> loadFuelLogsForVehicle(String vehicleId) async {
    try {
      _currentVehicleLogs = _repository.getFuelLogsForVehicle(vehicleId);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load fuel logs: $e';
      notifyListeners();
    }
  }

  /// Add a new fuel log entry
  Future<bool> addFuelLog({
    required String vehicleId,
    DateTime? dateTime,
    String? note,
  }) async {
    try {
      final entry = FuelLogEntry.create(
        vehicleId: vehicleId,
        dateTime: dateTime ?? DateTime.now(),
        note: note,
      );

      await _repository.addFuelLog(entry);
      await loadFuelLogsForVehicle(vehicleId);

      return true;
    } catch (e) {
      _error = 'Failed to add fuel log: $e';
      notifyListeners();
      return false;
    }
  }

  /// Delete a fuel log entry
  Future<bool> deleteFuelLog(String id, String vehicleId) async {
    try {
      await _repository.deleteFuelLog(id);
      await loadFuelLogsForVehicle(vehicleId);
      return true;
    } catch (e) {
      _error = 'Failed to delete fuel log: $e';
      notifyListeners();
      return false;
    }
  }

  // ============ NOTIFICATION HELPERS ============

  /// Schedule notifications for a vehicle
  Future<void> _scheduleNotifications(Vehicle vehicle) async {
    try {
      await _notificationService.scheduleQuotaStartNotification(vehicle);
      await _notificationService.scheduleQuotaEndReminder(vehicle);
    } catch (e) {
      // تجاهل أخطاء الإشعارات - التطبيق يعمل بدونها
      debugPrint('Failed to schedule notifications: $e');
    }
  }

  /// Reschedule all notifications (call after app restart)
  Future<void> rescheduleAllNotifications() async {
    try {
      for (final vehicle in _vehicles) {
        await _notificationService.cancelNotificationsForVehicle(vehicle.id);
        await _scheduleNotifications(vehicle);
      }
    } catch (e) {
      debugPrint('Failed to reschedule notifications: $e');
    }
  }

  // ============ ERROR HANDLING ============

  /// Clear the current error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// التحقق إذا السيارة تعبأت في الحصة الحالية
  bool isVehicleFueledInCurrentQuota(String vehicleId) {
    final currentQuota = KirkukQuotaSystem.getCurrentQuota();
    final logs = _repository.getFuelLogsForVehicle(vehicleId);

    return logs.any((log) {
      return log.dateTime.isAfter(currentQuota.start) &&
          log.dateTime.isBefore(
            currentQuota.end.add(const Duration(seconds: 1)),
          );
    });
  }

  /// الحصول على سجلات التعبئة لسيارة معينة
  List<FuelLogEntry> getFuelLogsForVehicle(String vehicleId) {
    return _repository.getFuelLogsForVehicle(vehicleId);
  }
}
