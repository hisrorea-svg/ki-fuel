import 'package:hive_flutter/hive_flutter.dart';
import '../models/vehicle.dart';
import '../models/fuel_log_entry.dart';

/// Repository for managing vehicle and fuel log data persistence
class VehicleRepository {
  static const String _vehiclesBoxName = 'vehicles';
  static const String _fuelLogsBoxName = 'fuel_logs';

  late Box<Vehicle> _vehiclesBox;
  late Box<FuelLogEntry> _fuelLogsBox;

  /// Initialize the repository and open Hive boxes
  Future<void> initialize() async {
    // Register adapters if not already registered
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(VehicleAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(FuelLogEntryAdapter());
    }

    // Open boxes with error handling for schema migration
    try {
      _vehiclesBox = await Hive.openBox<Vehicle>(_vehiclesBoxName);
    } catch (e) {
      // إذا فشل فتح الـ box بسبب تغيير في الـ schema، نحذفه ونفتحه من جديد
      await Hive.deleteBoxFromDisk(_vehiclesBoxName);
      _vehiclesBox = await Hive.openBox<Vehicle>(_vehiclesBoxName);
    }

    try {
      _fuelLogsBox = await Hive.openBox<FuelLogEntry>(_fuelLogsBoxName);
    } catch (e) {
      await Hive.deleteBoxFromDisk(_fuelLogsBoxName);
      _fuelLogsBox = await Hive.openBox<FuelLogEntry>(_fuelLogsBoxName);
    }
  }

  // ============ VEHICLE OPERATIONS ============

  /// Get all vehicles sorted by creation date
  List<Vehicle> getAllVehicles() {
    final vehicles = _vehiclesBox.values.toList();
    vehicles.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return vehicles;
  }

  /// Get a vehicle by ID
  Vehicle? getVehicleById(String id) {
    try {
      return _vehiclesBox.values.firstWhere((v) => v.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Add a new vehicle
  Future<void> addVehicle(Vehicle vehicle) async {
    await _vehiclesBox.put(vehicle.id, vehicle);
  }

  /// Update an existing vehicle
  Future<void> updateVehicle(Vehicle vehicle) async {
    await _vehiclesBox.put(vehicle.id, vehicle);
  }

  /// Delete a vehicle and its associated fuel logs
  Future<void> deleteVehicle(String id) async {
    // Delete associated fuel logs first
    final logsToDelete = _fuelLogsBox.values
        .where((log) => log.vehicleId == id)
        .map((log) => log.id)
        .toList();

    for (final logId in logsToDelete) {
      await _fuelLogsBox.delete(logId);
    }

    // Delete the vehicle
    await _vehiclesBox.delete(id);
  }

  /// Get the count of vehicles (for auto-naming)
  int getVehicleCount() {
    return _vehiclesBox.length;
  }

  /// Watch vehicles for changes (returns a listenable)
  Box<Vehicle> get vehiclesBox => _vehiclesBox;

  // ============ FUEL LOG OPERATIONS ============

  /// Get all fuel logs for a specific vehicle, sorted by date (newest first)
  List<FuelLogEntry> getFuelLogsForVehicle(String vehicleId) {
    final logs = _fuelLogsBox.values
        .where((log) => log.vehicleId == vehicleId)
        .toList();
    logs.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return logs;
  }

  /// Get a fuel log by ID
  FuelLogEntry? getFuelLogById(String id) {
    try {
      return _fuelLogsBox.values.firstWhere((log) => log.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Add a new fuel log entry
  Future<void> addFuelLog(FuelLogEntry entry) async {
    await _fuelLogsBox.put(entry.id, entry);
  }

  /// Update an existing fuel log
  Future<void> updateFuelLog(FuelLogEntry entry) async {
    await _fuelLogsBox.put(entry.id, entry);
  }

  /// Delete a fuel log entry
  Future<void> deleteFuelLog(String id) async {
    await _fuelLogsBox.delete(id);
  }

  /// Watch fuel logs for changes (returns a listenable)
  Box<FuelLogEntry> get fuelLogsBox => _fuelLogsBox;

  /// Close all boxes
  Future<void> close() async {
    await _vehiclesBox.close();
    await _fuelLogsBox.close();
  }

  /// Clear all data (for testing/reset purposes)
  Future<void> clearAll() async {
    await _vehiclesBox.clear();
    await _fuelLogsBox.clear();
  }
}
