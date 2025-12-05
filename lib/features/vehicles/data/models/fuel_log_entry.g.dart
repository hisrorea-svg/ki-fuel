// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fuel_log_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FuelLogEntryAdapter extends TypeAdapter<FuelLogEntry> {
  @override
  final int typeId = 1;

  @override
  FuelLogEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FuelLogEntry(
      id: fields[0] as String,
      vehicleId: fields[1] as String,
      dateTime: fields[2] as DateTime,
      note: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, FuelLogEntry obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.vehicleId)
      ..writeByte(2)
      ..write(obj.dateTime)
      ..writeByte(3)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FuelLogEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
